resource "aws_vpc_peering_connection" "default" {
  count = var.is_peering_required ? 1: 0
  peer_vpc_id   = data.aws_vpc.default.id #acceptor
  auto_accept = true
  vpc_id        = aws_vpc.main.id 

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
  tags = merge(
    var.vpc_peering_tags,
    local.common_tags,
    {
        Name = "${local.common_name}-deafult"
    }
  )

}

resource "aws_route" "public_peering" {
    count = var.is_peering_required ? 1: 0
    route_table_id = aws_route_table.public.id
    destination_cidr_block = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id

}

resource "aws_route" "private_peering" {
    count = var.is_peering_required ? 1: 0
    route_table_id = aws_route_table.private.id
    destination_cidr_block = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id

}

resource "aws_route" "database_peering" {
    count = var.is_peering_required ? 1: 0
    route_table_id = aws_route_table.database.id
    destination_cidr_block = data.aws_vpc.default.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id

}

resource "aws_route" "default" {
    count = var.is_peering_required ? 1: 0
    route_table_id = data.aws_route_table.default.id
    destination_cidr_block = var.vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.default[count.index].id

}