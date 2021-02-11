
/**
  Password value: password for heartbeat daemon
*/
output "random_password_value" {
  value = random_password.heartbeat_password.result
}