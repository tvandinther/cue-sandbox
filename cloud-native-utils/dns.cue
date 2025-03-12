package dns

import (
    "strings"
    "net"
)

subdomainName: string & strings.MaxRunes(63) & =~"^[A-Za-z0-9](?:[A-Za-z0-9\\-]{0,61}[A-Za-z0-9])?$"
domainName: string & strings.MaxRunes(255) & =~"^[A-Za-z0-9](?:[A-Za-z0-9\\-]{0,61}[A-Za-z0-9])?(?:\\.[A-Za-z0-9](?:[A-Za-z0-9\\-]{0,61}[A-Za-z0-9]))+$"
