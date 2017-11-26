resource "aws_security_group_rule" "ingress_security_groups" {
  count                    = "${var.ingress_rules_security_groups == "" ? 0 : length(split("\n", chomp(var.ingress_rules_security_groups)))}"
  security_group_id        = "${var.security_group_id}"
  type                     = "ingress"
  protocol                 = "${trimspace(element(split("|", element(split("\n", var.ingress_rules_security_groups), count.index)), 0))}"
  from_port                = "${trimspace(element(split("|", element(split("\n", var.ingress_rules_security_groups), count.index)), 1))}"
  to_port                  = "${trimspace(element(split("|", element(split("\n", var.ingress_rules_security_groups), count.index)), 2))}"
  source_security_group_id = "${trimspace(element(split("|", element(split("\n", var.ingress_rules_security_groups), count.index)), 3))}"
}

resource "aws_security_group_rule" "ingress_cidrs" {
  count             = "${var.ingress_rules_cidrs == "" ? 0 : length(split("\n", chomp(var.ingress_rules_cidrs)))}"
  security_group_id = "${var.security_group_id}"
  type              = "ingress"
  protocol          = "${trimspace(element(split("|", element(split("\n", var.ingress_rules_cidrs), count.index)), 0))}"
  from_port         = "${trimspace(element(split("|", element(split("\n", var.ingress_rules_cidrs), count.index)), 1))}"
  to_port           = "${trimspace(element(split("|", element(split("\n", var.ingress_rules_cidrs), count.index)), 2))}"
  cidr_blocks       = "${split(",", trimspace(element(split("|", element(split("\n", var.ingress_rules_cidrs), count.index)), 3)))}"
}

resource "aws_security_group_rule" "ingress_prefix_lists" {
  count             = "${var.ingress_rules_prefix_lists == "" ? 0 : length(split("\n", chomp(var.ingress_rules_prefix_lists)))}"
  security_group_id = "${var.security_group_id}"
  type              = "ingress"
  protocol          = "${trimspace(element(split("|", element(split("\n", var.ingress_rules_prefix_lists), count.index)), 0))}"
  from_port         = "${trimspace(element(split("|", element(split("\n", var.ingress_rules_prefix_lists), count.index)), 1))}"
  to_port           = "${trimspace(element(split("|", element(split("\n", var.ingress_rules_prefix_lists), count.index)), 2))}"
  prefix_list_ids   = "${split(",", trimspace(element(split("|", element(split("\n", var.ingress_rules_prefix_lists), count.index)), 3)))}"
}

resource "aws_security_group_rule" "egress_security_groups" {
  count                    = "${var.egress_rules_security_groups == "" ? 0 : length(split("\n", chomp(var.egress_rules_security_groups)))}"
  security_group_id        = "${var.security_group_id}"
  type                     = "egress"
  protocol                 = "${trimspace(element(split("|", element(split("\n", var.egress_rules_security_groups), count.index)), 0))}"
  from_port                = "${trimspace(element(split("|", element(split("\n", var.egress_rules_security_groups), count.index)), 1))}"
  to_port                  = "${trimspace(element(split("|", element(split("\n", var.egress_rules_security_groups), count.index)), 2))}"
  source_security_group_id = "${trimspace(element(split("|", element(split("\n", var.egress_rules_security_groups), count.index)), 3))}"
}

resource "aws_security_group_rule" "egress_cidrs" {
  count             = "${var.egress_rules_cidrs == "" ? 0 : length(split("\n", chomp(var.egress_rules_cidrs)))}"
  security_group_id = "${var.security_group_id}"
  type              = "egress"
  protocol          = "${trimspace(element(split("|", element(split("\n", var.egress_rules_cidrs), count.index)), 0))}"
  from_port         = "${trimspace(element(split("|", element(split("\n", var.egress_rules_cidrs), count.index)), 1))}"
  to_port           = "${trimspace(element(split("|", element(split("\n", var.egress_rules_cidrs), count.index)), 2))}"
  cidr_blocks       = "${split(",", trimspace(element(split("|", element(split("\n", var.egress_rules_cidrs), count.index)), 3)))}"
}

resource "aws_security_group_rule" "egress_prefix_lists" {
  count             = "${var.egress_rules_prefix_lists == "" ? 0 : length(split("\n", chomp(var.egress_rules_prefix_lists)))}"
  security_group_id = "${var.security_group_id}"
  type              = "egress"
  protocol          = "${trimspace(element(split("|", element(split("\n", var.egress_rules_prefix_lists), count.index)), 0))}"
  from_port         = "${trimspace(element(split("|", element(split("\n", var.egress_rules_prefix_lists), count.index)), 1))}"
  to_port           = "${trimspace(element(split("|", element(split("\n", var.egress_rules_prefix_lists), count.index)), 2))}"
  prefix_list_ids   = "${split(",", trimspace(element(split("|", element(split("\n", var.egress_rules_prefix_lists), count.index)), 3)))}"
}
