locals {
  oses = jsondecode(file("${path.module}/linux_os.json"))
  ami_name_filter = local.oses[var.linux_os]["ami_filter"]
  ami_owners = local.oses[var.linux_os]["owners"]
  merged_tags = merge(var.tags, var.sleep_tags)
}
