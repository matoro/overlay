# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="User for www-apps/mattermost-server"
ACCT_USER_ID="19997"
ACCT_USER_GROUPS=( "${PN}" )
ACCT_USER_HOME="${EROOT}/var/lib/${PN}"
ACCT_USER_HOME_PERMS="0750"

acct-user_add_deps
