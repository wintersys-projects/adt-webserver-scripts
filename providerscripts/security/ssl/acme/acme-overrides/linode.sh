#!/usr/bin/bash
# shellcheck disable=SC2034
dns_linode_info='Linode.com (Old)
Deprecated. Use dns_linode_v4
Site: Linode.com
'


########  Public functions #####################
#
#Usage: add  _acme-challenge.www.domain.com   "XKrxpRBosdIKFzxW_CT3KLZNf6q0HG9i01zxXp5CPBs"
dns_linode_v4_add() {
  #if we are here presume we know we control the domain
  return 0
}

#fulldomain txtvalue
dns_linode_v4_rm() {
  #if we are here presume we know we control the domain
  return 0
}
