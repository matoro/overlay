# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="A library for reading and writing configuration files"
HOMEPAGE="https://os.ghalkes.nl/t3/libt3config.html"
SRC_URI="https://os.ghalkes.nl/dist/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE="nls"
RESTRICT="mirror"

DEPEND="sys-devel/libtool"

src_configure() {
	local myeconfargs=(
				$(use_with nls gettext)
	)

	econf "${myeconfargs[@]}"
}
