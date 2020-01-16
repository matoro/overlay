# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="An intuitive text editor for the terminal"
HOMEPAGE="https://os.ghalkes.nl/tilde.html"
SRC_URI="https://os.ghalkes.nl/dist/${P}.tar.bz2"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~arm"
IUSE="nls"
RESTRICT="mirror"

RDEPEND=">=dev-libs/libtranscript-0.2.0
		>=dev-libs/libt3widget-1.2.0
		>=dev-libs/libt3highlight-0.4.0
		>=dev-libs/libt3config-1.0.0"
DEPEND="sys-devel/libtool"
