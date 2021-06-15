data "template_cloudinit_config" "config" {
  count = var.instances_desired > 0 ? 1 : 0

  gzip          = false
  base64_encode = true

  part {
    content_type = "text/x-shellscript"

    content = <<-EOT
      #!/bin/bash
      echo "ECS_CLUSTER=${aws_ecs_cluster.main.name}" >> /etc/ecs/ecs.config

      EOT
  }
  dynamic "part" {
    for_each = var.cloud_init_parts

    // as per https://www.terraform.io/docs/providers/template/d/cloudinit_config.html
    content {
      content_type = lookup(part.value, "content_type", "")
      content      = lookup(part.value, "content", "")
      filename     = lookup(part.value, "filename", "")
      merge_type   = lookup(part.value, "merge_type", "")
    }
  }
}

