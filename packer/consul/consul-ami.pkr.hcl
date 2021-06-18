# folder/sources.pkr.hcl
source "amazon-ebs" "amzn2-arm64" {
  ami_name = "consul-server-arm64-{{timestamp}}"
  region = var.region
  instance_type = var.instance_type["arm64"]
  ami_groups = ["all"]

  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name =  "amzn2-ami-hvm*"
      root-device-type = "ebs"
      architecture = "arm64"
    }
    owners = ["amazon"]
    most_recent = true
  }

  communicator = "ssh"
  ssh_username = "ec2-user"
}

source "amazon-ebs" "amzn2-amd64" {
  ami_name = "consul-server-amd64-{{timestamp}}"
  region = var.region
  instance_type = var.instance_type["amd64"]
  ami_groups = ["all"]

  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name =  "amzn2-ami-hvm*"
      root-device-type = "ebs"
      architecture = "x86_64"
    }
    owners = ["amazon"]
    most_recent = true
  }

  communicator = "ssh"
  ssh_username = "ec2-user"
}

# folder/build.pkr.hcl
# A build starts sources and runs provisioning steps on those sources.
build {
  sources = [
    # there can be multiple sources per build */
    "source.amazon-ebs.amzn2-arm64",
    "source.amazon-ebs.amzn2-amd64"
  ]

  provisioner "file" {
    source = "files/"
    destination = "/tmp"
  }

  provisioner "shell" {
    execute_command = "sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
    script = "scripts/install_consul.sh"
  }

  provisioner "shell-local" {
    inline = ["echo the address is: $PACKER_HTTP_ADDR and build name is: $PACKER_BUILD_NAME"]
  }
}