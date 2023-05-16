# Copyright 2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

COMMIT="e0e2a9150cb0c7cea8b27ea126e1367b3f03b17e"

DESCRIPTION="Simple RFC-complient TELNET implementation"
HOMEPAGE="https://github.com/SDL-Hercules-390/telnet"
SRC_URI="https://github.com/SDL-Hercules-390/telnet/archive/${COMMIT}.tar.gz -> telnet-${COMMIT}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64 ~ppc64 ~x86"
PATCHES=( "${FILESDIR}/cmakefix.patch" )
S="${WORKDIR}/telnet-${COMMIT}"
