#!/usr/bin/bash
# shellcheck disable=SC2034
dns_vultr_info='vultr.com
Site: vultr.com
Docs: github.com/acmesh-official/acme.sh/wiki/dnsapi2#dns_vultr
Options:
VULTR_API_KEY API Key
Issues: github.com/acmesh-official/acme.sh/issues/2374
'

########  Public functions #####################
#
#Usage: add  _acme-challenge.www.domain.com   "XKrxpRBosdIKFzxW_CT3KLZNf6q0HG9i01zxXp5CPBs"
dns_vultr_add() {
  #if we are here presume we know we control the domain
  return 0
}

#fulldomain txtvalue
dns_vultr_rm() {
  #if we are here presume we know we control the domain
  return 0
}
