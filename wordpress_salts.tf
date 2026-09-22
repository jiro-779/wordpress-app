resource "random_password" "wordpress_salts" {
  count   = 8
  length  = 64
  special = true
}