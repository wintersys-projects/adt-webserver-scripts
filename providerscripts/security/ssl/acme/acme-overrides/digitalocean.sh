#!/usr/bin/bash
# shellcheck disable=SC2034
dns_dgon_info='DigitalOcean.com
Site: DigitalOcean.com/help/api/
Docs: github.com/acmesh-official/acme.sh/wiki/dnsapi#dns_dgon
Options:
DO_API_KEY API Key
Author: <github@thewer.com>
'

#####################  Public functions  #####################

## Create the text record for validation.
## Usage: fulldomain txtvalue
## EG: "_acme-challenge.www.other.domain.com" "XKrxpRBosdq0HG9i01zxXp5CPBs"
dns_dgon_add() {
  #if we are here presume we know we control the domain
  return 0
}

## Remove the txt record after validation.
## Usage: fulldomain txtvalue
## EG: "_acme-challenge.www.other.domain.com" "XKrxpRBosdq0HG9i01zxXp5CPBs"
dns_dgon_rm() {
  #if we are here presume we know we control the domain
  return 0
}
