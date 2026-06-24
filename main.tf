resource "aws_vpc" "main" {
cidr_block = var.cidr_block
instance_tenancy = "default"
enable_dns_hostnames = true
tags = merge(
       var.vpc_tags,
       local.common_tags
    )

}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags =  merge(
       var.gw_tags,
       local.common_tags
    )

}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr[count.index]
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = true

  tags = merge(
       var.public_subnet_tags,
       local.common_tags,
       {
        Name = "${local.common_name}-public-${split("-",local.az_names[count.index])[2]}"
       }
    )
}
resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr[count.index]
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = false


  tags = merge(
       var.private_subnet_tags,
       local.common_tags,
       {
        Name = "${local.common_name}-private-${split("-",local.az_names[count.index])[2]}"
       }
    )
}

resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidr)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidr[count.index]
  availability_zone = local.az_names[count.index]
  map_public_ip_on_launch = false

  tags = merge(
       var.databse_subnet_tags,
       local.common_tags,
       {
        Name = "${local.common_name}-private-${split("-",local.az_names[count.index])[2]}"
       }

    )
}

resource "aws_route_table" "public" {

  vpc_id = aws_vpc.main.id


  tags = merge(
    var.public_route_tags,
    local.common_tags,
    {
        Name = "${local.common_name}-public"
    }
  )
  
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.private_route_tags,
    local.common_tags,
    {
        Name = "${local.common_name}-private"
    }
  )
  
}
resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.database_route_tags,
    local.common_tags,
    {
        Name = "${local.common_name}-database"
    }
  )
  
}
resource "aws_route_table_association" "public" {
 count = length(var.public_subnet_cidr)
 subnet_id = aws_subnet.public[count.index].id
 route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
 count = length(var.private_subnet_cidr)
 subnet_id = aws_subnet.private[count.index].id
 route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "database" {
 count = length(var.database_subnet_cidr)
 subnet_id = aws_subnet.database[count.index].id
 route_table_id = aws_route_table.database.id
}

resource "aws_eip" "lb" {

  domain   = "vpc"
  tags = merge(
    var.eip_tags,
    local.common_tags,
    {
        Name = "${local.common_name}-nat"
    }

  )
}
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.lb.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
        var.nat_tags,
        local.common_tags
    )
  

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.gw]
}
resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}
resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

resource "aws_route" "databse" {
  route_table_id            = aws_route_table.database.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}