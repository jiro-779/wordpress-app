data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_launch_template" "wordpress" {
  name_prefix   = "${var.environment}-wp-"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.ec2_instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  # Require IMDSv2
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # Encrypted EC2 root disk
  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 20
      volume_type = "gp3"
      encrypted   = true
      kms_key_id  = data.terraform_remote_state.platform.outputs.kms_key_arn
    }
  }

  user_data = base64encode(<<-EOF
#!/bin/bash
set -e

# --------------------------------------------------
# 1. Update system and install packages
# --------------------------------------------------

dnf update -y

dnf install -y \
  httpd \
  php \
  php-fpm \
  php-mysqlnd \
  amazon-efs-utils \
  jq \
  wget \
  tar

# --------------------------------------------------
# 2. Start PHP and Apache
# --------------------------------------------------

systemctl enable php-fpm
systemctl start php-fpm

systemctl enable httpd
systemctl start httpd

# --------------------------------------------------
# 3. Mount EFS using TLS
# --------------------------------------------------

mkdir -p /mnt/efs

for i in {1..10}; do
  if mount -t efs -o tls ${aws_efs_file_system.wordpress.id}:/ /mnt/efs; then
    echo "EFS mounted successfully"
    break
  fi

  echo "EFS mount failed. Retrying in 15 seconds..."
  sleep 15
done

mountpoint -q /mnt/efs || exit 1

echo "${aws_efs_file_system.wordpress.id}:/ /mnt/efs efs _netdev,tls 0 0" >> /etc/fstab

# --------------------------------------------------
# 4. Download WordPress
# --------------------------------------------------

cd /tmp

wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz

rm -rf /var/www/html/*
cp -r /tmp/wordpress/* /var/www/html/

# --------------------------------------------------
# 5. Put wp-content on shared EFS
# --------------------------------------------------

mkdir -p /mnt/efs/wp-content

if [ -z "$(ls -A /mnt/efs/wp-content)" ]; then
  cp -r /var/www/html/wp-content/* /mnt/efs/wp-content/
fi

rm -rf /var/www/html/wp-content
ln -s /mnt/efs/wp-content /var/www/html/wp-content

# --------------------------------------------------
# 6. Get database credentials from Secrets Manager
# --------------------------------------------------

SECRET_JSON=$(aws secretsmanager get-secret-value \
  --secret-id ${aws_secretsmanager_secret.db.arn} \
  --region ${var.aws_region} \
  --query SecretString \
  --output text)

DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
DB_PASSWORD=$(echo "$SECRET_JSON" | jq -r '.password')

# --------------------------------------------------
# 7. Create WordPress configuration
# --------------------------------------------------

cat > /var/www/html/wp-config.php <<CONFIG
<?php

define('DB_NAME', 'wordpress');
define('DB_USER', '$DB_USER');
define('DB_PASSWORD', '$DB_PASSWORD');
define('DB_HOST', '${aws_db_instance.wordpress.address}');

define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');

/*
 * Connect WordPress/PHP to RDS using TLS.
 */
define('MYSQL_CLIENT_FLAGS', MYSQLI_CLIENT_SSL);

/*
 * WordPress authentication keys and salts
 */
define('AUTH_KEY',         '${random_password.wordpress_salts[0].result}');
define('SECURE_AUTH_KEY',  '${random_password.wordpress_salts[1].result}');
define('LOGGED_IN_KEY',    '${random_password.wordpress_salts[2].result}');
define('NONCE_KEY',        '${random_password.wordpress_salts[3].result}');
define('AUTH_SALT',        '${random_password.wordpress_salts[4].result}');
define('SECURE_AUTH_SALT', '${random_password.wordpress_salts[5].result}');
define('LOGGED_IN_SALT',   '${random_password.wordpress_salts[6].result}');
define('NONCE_SALT',       '${random_password.wordpress_salts[7].result}');

\$table_prefix = 'wp_';

define('WP_DEBUG', false);

if (!defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}

require_once ABSPATH . 'wp-settings.php';
CONFIG

# --------------------------------------------------
# 8. Permissions
# --------------------------------------------------

chown -R apache:apache /var/www/html
chown -R apache:apache /mnt/efs/wp-content

find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

# --------------------------------------------------
# 9. Restart services
# --------------------------------------------------

systemctl restart php-fpm
systemctl restart httpd

EOF
  )

  vpc_security_group_ids = [
    aws_security_group.ec2.id
  ]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.environment}-wp-ec2"
      Environment = var.environment
      Project     = "wordpress"
    }
  }
}