package net

import (
    "net"
)

port: int & >=1 & <=65535
privilegedPort: port & <1024
nonPrivilegedPort: port & >=1024

ip: ipv4 | ipv6
ipv4: string & net.IPv4()
ipv6: string & net.IPv6()

ipCIDR: string & net.IPCIDR()
