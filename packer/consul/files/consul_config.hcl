datacenter = "AWS_Kulpree"
node_name = "InstanceId"
advertise_addr = "PrivateIpAddress"
bind_addr = "PrivateIpAddress"
server = true
ui = true
leave_on_terminate = LEAVE_ON_TERMINATE
skip_leave_on_interrupt  = true
disable_update_check = true
log_level = "warn"
data_dir = "/opt/consul/data"
client_addr = "0.0.0.0"
bootstrap_expect = BOOTSTRAP_EXPECT
retry_join = [
  "provider=aws region=AWS_REGION tag_key=JOIN_EC2_TAG_KEY tag_value=JOIN_EC2_TAG"
]
addresses = {
  http = "0.0.0.0"
}
connect = {
  enabled = true
}
autopilot = {
  cleanup_dead_servers = true
  last_contact_threshold = "200ms"
  max_trailing_logs = 250
  server_stabilization_time = "10s"
}