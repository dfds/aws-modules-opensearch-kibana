resource "aws_security_group" "this" {
  count = var.create_security_group && var.vpc_opensearch ? 1 : 0

  name        = var.domain_name
  description = "SG for ${var.domain_name}"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "ingress" {
  for_each = (length(var.sg_ingress_rules) > 0) ? [var.sg_ingress_rules] : []

  from_port         = each.value.from_port
  protocol          = each.value.protocol
  security_group_id = aws_security_group.this[0].id
  to_port           = each.value.to_port
  cidr_blocks       = each.value.cidr_blocks
  type              = "ingress"
}