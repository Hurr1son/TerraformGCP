provider "google"{
    project = var.project
    region= var.region
    zone =  var.zone
}

resource "tls_private_key" "kk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
#resource "google_project_service" "api" { 
#    for_each = toset([
#    "cloudresourcemanager.googleapis.com",
#    "compute.googleapis.com"
#    ])
#    disable_on_destroy = false
#    serviсe            = each.value
#}

resource "google_compute_firewall" "webg"{
    name = var.fw_name
    network = var.network_name
    source_ranges = var.fw_rages
    allow{
        protocol = "tcp"
        ports = ["22", "80" , "443"]
    }
}
resource "google_compute_address" "static" {
  name = "${var.inst_name}-test"
  project = var.project
  region= var.region
  depends_on = [ google_compute_firewall.webg]
}
resource "google_compute_address" "static2" {
  name = "${var.inst_name}-prod"
  project = var.project
  region = var.region
  depends_on = [ google_compute_firewall.webg]
}
module "instance_test" {
    source = "./cpi"
    ins_name = "test"
    tls_key = "${tls_private_key.kk.public_key_openssh}"
    tls_private_key = "${tls_private_key.kk.private_key_pem}"
    static_ip = google_compute_address.static.address

   depends_on = [google_compute_firewall.webg] 
}
module "instance_prod" {
    source = "./cpi"
    ins_name = "prod"
    tls_key = "${tls_private_key.kk.public_key_openssh}"
    tls_private_key = "${tls_private_key.kk.private_key_pem}"
    static_ip = google_compute_address.static2.address

   depends_on = [google_compute_firewall.webg]
}
