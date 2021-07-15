resource "google_compute_instance" "web"{
    name = var.ins_name
    machine_type = "e2-micro"
    tags = ["webprod"]
    metadata = {
      ssh-keys = "ubuntu:${var.tls_key}"
    }
    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-9"
        }
    }
    network_interface{
    network = "default"
    access_config {
      nat_ip = var.static_ip
     }
    }
    provisioner "local-exec" {
    command = "echo '${var.tls_private_key}' > ./myKey.pem; chmod 600 ./myKey.pem"
    }
    provisioner "remote-exec" {
      inline = ["echo asd"]

    connection {
      host = var.static_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = "${var.tls_private_key}"
    }
  }

  provisioner "local-exec" {
    command = "ansible-playbook -u ubuntu -i '${var.static_ip},' --private-key ./myKey.pem create.yml"
  }
}
