variable "ip_address" {}
variable "ssh_key" {}

resource "null_resource" "copy_files" {
  connection {
    user        = "ubuntu"
    host        = "${var.ip_address}"
    private_key = "${var.ssh_key}"
  }

  provisioner "file" {
    source      = "../../apps/"
    destination = "/home/ubuntu/apps"
  }
}

resource "null_resource" "provision_app" {
  depends_on = ["null_resource.copy_files"]

  connection {
    user        = "ubuntu"
    host        = "${var.ip_address}"
    private_key = "${var.ssh_key}"
  }

  provisioner "remote-exec" {
    inline = ["sudo bash /home/ubuntu/apps/bootstrap.sh"]
  }
}

output "public_ip" {
  value = "${null_resource.provision_app.id}"
}
