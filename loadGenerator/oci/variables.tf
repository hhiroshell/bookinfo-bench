variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "compartment_ocid" {}
variable "region" {}

variable "instance_image_ocid" {
    type = "map"
    default = {
         // See https://docs.us-phoenix-1.oraclecloud.com/images/
         // Oracle-provided image "Oracle-Linux-7.5-2018.10.16-0"
         us-phoenix-1   = "ocid1.image.oc1.phx.aaaaaaaaoqj42sokaoh42l76wsyhn3k2beuntrh5maj3gmgmzeyr55zzrwwa"
         us-ashburn-1   = "ocid1.image.oc1.iad.aaaaaaaageeenzyuxgia726xur4ztaoxbxyjlxogdhreu3ngfj2gji3bayda"
         eu-frankfurt-1 = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaitzn6tdyjer7jl34h2ujz74jwy5nkbukbh55ekp6oyzwrtfa4zma"
         uk-london-1    = "ocid1.image.oc1.uk-london-1.aaaaaaaa32voyikkkzfxyo4xbdmadc2dmvorfxxgdhpnk6dw64fa3l4jh7wa"
    }
}

variable "core_instance_availability_domain" {}
variable "core_instance_subnet_ocid" {}
variable "core_instance_name" {}
variable "core_instance_shape" {}
variable "core_instance_ssh_public_key_file" {}
variable "core_instance_ssh_private_key_file" {}
