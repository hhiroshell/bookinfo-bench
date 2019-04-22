resource "oci_core_instance" "gatling" {
    compartment_id      = "${var.compartment_ocid}"
    availability_domain = "${var.core_instance_availability_domain}"
    display_name        = "${var.core_instance_name}"
    shape               = "${var.core_instance_shape}"

    create_vnic_details {
        subnet_id = "${var.core_instance_subnet_ocid}"
    }

    source_details {
        source_type = "image"
        source_id   = "${var.instance_image_ocid[var.region]}"
    }

    metadata = {
        ssh_authorized_keys = "${file(var.core_instance_ssh_public_key_file)}"
    }

    connection {
        type        = "ssh"
        host        = "${self.public_ip}"
        user        = "opc"
        private_key = "${file(var.core_instance_ssh_private_key_file)}"
    }

    provisioner "remote-exec" "install jdk & gatling" {
        inline = [
            #"sudo yum -y update",
            "sudo yum -y install java-1.8.0-openjdk",
            "wget https://repo1.maven.org/maven2/io/gatling/highcharts/gatling-charts-highcharts-bundle/3.0.1.1/gatling-charts-highcharts-bundle-3.0.1.1-bundle.zip -O /tmp/gatling-charts-highcharts-bundle-3.0.1.1-bundle.zip",
            "mkdir ~/gatling",
            "unzip /tmp/gatling-charts-highcharts-bundle-3.0.1.1-bundle.zip -d ~/gatling",
        ]
    }

    provisioner "remote-exec" "preparation for copying files" {
        inline = [
            "mkdir ~/gatling/gatling-charts-highcharts-bundle-3.0.1.1/user-files/simulations/bookinfo_bench",
        ]
    }

    provisioner "file" {
        source = "../gatling-home/simulations/bookinfo_bench/IncreaseAndDecreaseUsers.scala"
        destination = "/home/opc/gatling/gatling-charts-highcharts-bundle-3.0.1.1/user-files/simulations/bookinfo_bench/IncreaseAndDecreaseUsers.scala"
    }

    provisioner "file" {
        source = "../gatling-home/run.sh"
        destination = "/home/opc/gatling/gatling-charts-highcharts-bundle-3.0.1.1/run.sh"
    }

    provisioner "file" {
        source = "../gatling-home/endpoints.txt"
        destination = "/home/opc/gatling/gatling-charts-highcharts-bundle-3.0.1.1/endpoints.txt"
    }

    provisioner "remote-exec" "change file permission" {
        inline = [
            "chmod +x /home/opc/gatling/gatling-charts-highcharts-bundle-3.0.1.1/run.sh",
        ]
    }

    provisioner "remote-exec" "OS tuning - 1/2" {
        inline = [
            "sudo bash -c 'echo \"*       soft    nofile  65535\" >> /etc/security/limits.conf'",
            "sudo bash -c 'echo \"*       hard    nofile  65535\" >> /etc/security/limits.conf'",
            "sudo bash -c 'echo \"session required pam_limits.so\" >> /etc/pam.d/common-session'",
            "sudo bash -c 'echo \"session required pam_limits.so\" >> /etc/pam.d/sshd'",
            "sudo bash -c 'echo \"UseLogin yes\" >> /etc/ssh/sshd_config'",
            "sudo sysctl -w net.ipv4.ip_local_port_range=\"1025 65535\"",
            "echo 300000 | sudo tee /proc/sys/fs/nr_open",
            "echo 300000 | sudo tee /proc/sys/fs/file-max",
        ]
    }

    provisioner "remote-exec" "OS tuning - 2/2" {
        inline = [
            "sudo bash -c 'echo \"net.ipv4.tcp_max_syn_backlog = 40000\" >> /etc/sysctl.conf'",
            "sudo bash -c 'echo \"net.core.somaxconn = 40000\" >> /etc/sysctl.conf'",
            "sudo bash -c 'echo \"net.core.wmem_default = 8388608\" >> /etc/sysctl.conf'",
            "sudo bash -c 'echo \"net.core.rmem_default = 8388608\" >> /etc/sysctl.conf'",
            "sudo bash -c 'echo \"net.ipv4.tcp_sack = 1\" >> /etc/sysctl.conf'",
            "sudo bash -c 'echo \"net.ipv4.tcp_window_scaling = 1\" >> /etc/sysctl.conf'",
            "sudo bash -c 'echo \"net.ipv4.tcp_fin_timeout = 15\" >> /etc/sysctl.conf'",
            "sudo bash -c 'echo \"net.ipv4.tcp_keepalive_intvl = 30\" >> /etc/sysctl.conf'",
            "sudo bash -c 'echo \"net.ipv4.tcp_tw_reuse = 1\" >> /etc/sysctl.conf'",
            "sudo bash -c 'echo \"net.ipv4.tcp_moderate_rcvbuf = 1\" >> /etc/sysctl.conf'",
            "sudo bash -c 'echo \"net.core.rmem_max = 134217728\" >> /etc/sysctl.conf'",
            "sudo bash -c 'echo \"net.core.wmem_max = 134217728\" >> /etc/sysctl.conf'",
            "sudo bash -c 'echo \"net.ipv4.tcp_mem  = 134217728 134217728 134217728\" >> /etc/sysctl.conf'",
            "sudo bash -c 'echo \"net.ipv4.tcp_rmem = 4096 277750 134217728\" >> /etc/sysctl.conf'",
            "sudo bash -c 'echo \"net.ipv4.tcp_wmem = 4096 277750 134217728\" >> /etc/sysctl.conf'",
            "sudo bash -c 'echo \"net.core.netdev_max_backlog = 300000\" >> /etc/sysctl.conf'",
        ]
    }
}