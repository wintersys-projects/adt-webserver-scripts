#!/usr/bin/bash

# shellcheck disable=SC2034
dns_exoscale_info='Exoscale.com
Site: Exoscale.com
Docs: github.com/acmesh-official/acme.sh/wiki/dnsapi#dns_exoscale
'

########  Public functions #####################

# Usage: add  _acme-challenge.www.domain.com   "XKrxpRBosdIKFzxW_CT3KLZNf6q0HG9i01zxXp5CPBs"
# Used to add txt record
dns_exoscale_add() {
        #if we are here presume we know we control the domain
        return 0

}

# Usage: fulldomain txtvalue
# Used to remove the txt record after validation
dns_exoscale_rm() {
        #if we are here presume we know we control the domain
        return 0
}
