import yaml
from netcfg import gen_env, gen_network

metadata = yaml.load(
    """
availability-zone: fsn1-dc14
hostname: nin3koo8
instance-id: 29018046
local-ipv4: ''
network-config:
  config:
  - mac_address: 96:00:01:ed:34:98
    name: eth0
    subnets:
    - ipv4: true
      type: dhcp
    - address: 2a01:4f8:c17:c6ba::1/64
      dns_nameservers:
      - 2a01:4ff:ff00::add:1
      - 2a01:4ff:ff00::add:2
      gateway: fe80::1
      ipv6: true
      type: static
    type: physical
  version: 1
public-ipv4: 159.69.113.107
region: eu-central
""",
    Loader=yaml.CLoader,
)

private_networks = yaml.load(
    """
- ip: 10.0.0.2
  alias_ips: []
  interface_num: 1
  mac_address: 86:00:00:38:b2:35
  network_id: 2542409
  network_name: nixos-cluster
  network: 10.0.0.0/16
  subnet: 10.0.0.0/16
  gateway: 10.0.0.1
""",
    Loader=yaml.CLoader,
)

metadata_no_private_networks = yaml.load(
    """
availability-zone: fsn1-dc14
hostname: franz-josef-oestrovsky
instance-id: 29790652
local-ipv4: ''
network-config:
  config:
  - mac_address: 96:00:01:fc:0c:93
    name: eth0
    subnets:
    - ipv4: true
      type: dhcp
    - address: 2a01:4f8:c012:3adc::1/64
      dns_nameservers:
      - 2a01:4ff:ff00::add:1
      - 2a01:4ff:ff00::add:2
      gateway: fe80::1
      ipv6: true
      type: static
    type: physical
  version: 1
public-ipv4: 162.55.47.78
region: eu-central
""",
    Loader=yaml.CLoader,
)

private_networks_no_private_networks = yaml.load(
    """
[]
""",
    Loader=yaml.CLoader,
)


def test_gen_network():
    assert (
        gen_network(metadata, no_ipv6_dns=False)
        == """# Generated by hcloud-netcfg
[Match]
MACAddress=96:00:01:ed:34:98

[Network]
Address=159.69.113.107/32
Address=2a01:4f8:c17:c6ba::1/64
DNS=185.12.64.1
DNS=185.12.64.2
DNS=2a01:4ff:ff00::add:1
DNS=2a01:4ff:ff00::add:2

[Route]
Destination=0.0.0.0/0
Gateway=172.31.1.1
GatewayOnLink=true

[Route]
Destination=::/0
Gateway=fe80::1
GatewayOnLink=true
"""
    )


# https://docs.hetzner.com/de/cloud/servers/static-configuration/
def test_gen_network_no_ipv6_dns():
    assert (
        gen_network(metadata, no_ipv6_dns=True)
        == """# Generated by hcloud-netcfg
[Match]
MACAddress=96:00:01:ed:34:98

[Network]
Address=159.69.113.107/32
Address=2a01:4f8:c17:c6ba::1/64
DNS=185.12.64.1
DNS=185.12.64.2

[Route]
Destination=0.0.0.0/0
Gateway=172.31.1.1
GatewayOnLink=true

[Route]
Destination=::/0
Gateway=fe80::1
GatewayOnLink=true
"""
    )


def test_gen_env():
    assert (
        gen_env(metadata, private_networks)
        == """# Generated by hcloud-netcfg
HETZNER_HOSTNAME=nin3koo8
HETZNER_INSTANCE_ID=29018046
HETZNER_PUBLIC_IPV4=159.69.113.107
HETZNER_PUBLIC_IPV6=2a01:4f8:c17:c6ba::1
HETZNER_AVAILABILITY_ZONE=fsn1-dc14
HETZNER_REGION=eu-central
HETZNER_PRIVATE_IPV4_0=10.0.0.2
"""
    )


def test_gen_env_no_private_networks():
    assert (
        gen_env(metadata_no_private_networks, private_networks_no_private_networks)
        == """# Generated by hcloud-netcfg
HETZNER_HOSTNAME=franz-josef-oestrovsky
HETZNER_INSTANCE_ID=29790652
HETZNER_PUBLIC_IPV4=162.55.47.78
HETZNER_PUBLIC_IPV6=2a01:4f8:c012:3adc::1
HETZNER_AVAILABILITY_ZONE=fsn1-dc14
HETZNER_REGION=eu-central
"""
    )
