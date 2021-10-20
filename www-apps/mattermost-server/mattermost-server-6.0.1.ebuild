# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

# Change this when you update the ebuild
GIT_COMMIT="73c18e31c5fe312c624b5882f8e7327987c4def4"
WEBAPP_COMMIT="34861f3da00bc5fd7e777885783840c1353131a7"
EGO_PN="github.com/mattermost/${PN}"
WEBAPP_P="mattermost-webapp-${PV}"
MY_PV="${PV/_/-}"

if [[ "$ARCH" != "x86" && "$ARCH" != "amd64" ]]; then UNSUPPORTED_ARCH="1" ; fi
[[ -z "${UNSUPPORTED_ARCH}" ]] || INHERIT="autotools"
[[ "${ARCH}" == "ppc64" ]] && INHERIT="${INHERIT} flag-o-matic"
[[ -z "${UNSUPPORTED_ARCH}" ]] || DEPEND="media-libs/libpng:0"

inherit ${INHERIT} golang-vcs-snapshot-r1 systemd user

DESCRIPTION="Open source Slack-alternative in Golang and React (Team Edition)"
HOMEPAGE="https://mattermost.com"
SRC_URI="
	https://${EGO_PN}/archive/v${MY_PV}.tar.gz -> ${P}.tar.gz
	https://${EGO_PN/server/webapp}/archive/v${MY_PV}.tar.gz -> ${WEBAPP_P}.tar.gz
"
RESTRICT="mirror test"

LICENSE="AGPL-3"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~x86 ~ppc64" # Untested: arm64 x86
IUSE="+npm-audit debug pie static"

DEPEND="${DEPEND}
	>net-libs/nodejs-6[npm]
"
RDEPEND="!www-apps/mattermost-server-ee"

QA_PRESTRIPPED="usr/libexec/.*"

G="${WORKDIR}/${P}"
S="${G}/src/${EGO_PN}"

pkg_pretend() {
	if [[ "${MERGE_TYPE}" != binary ]]; then
		# shellcheck disable=SC2086
		if has network-sandbox ${FEATURES}; then
			ewarn
			ewarn "${CATEGORY}/${PN} requires 'network-sandbox' to be disabled in FEATURES"
			ewarn
			die "[network-sandbox] is enabled in FEATURES"
		fi

		if use npm-audit && [[ $(npm --version | cut -d "." -f 1) -lt 6 ]]; then
			ewarn
			ewarn "npm v6 is required to run 'npm audit', which is a new command that"
			ewarn "performs security reports and tries to fix known vulnerabilities"
			ewarn
		fi
	fi
}

pkg_setup() {
	enewgroup mattermost
	enewuser mattermost -1 -1 -1 mattermost
}

src_unpack() {
	golang-vcs-snapshot-r1_src_unpack
	cd "${S}" || die
	unpack "${WEBAPP_P}.tar.gz"
	mv "${WEBAPP_P/_/-}" client || die
}

src_prepare() {
	local datadir="${EPREFIX}/var/lib/mattermost"

	# Generate default config
	# From https://docs.mattermost.com/administration/config-settings.html
	# "On new installations starting in version 5.14, the default.json file
	# used to create the initial config.json has been removed from the binary
	# and replaced with a build step that generates a fresh config.json.  This
	# is to ensure the initial configuration file has all the correct defaults
	# provided in the server code.  Existing config.json files are not affected
	# by this change."
	emake config-reset
	mv config/config.json config/default.json || die

	# Disable developer settings, fix path, set to listen localhost
	# and disable diagnostics (call home) by default.
	# shellcheck disable=SC2086
	sed -i \
		-e 's|\("ListenAddress":\).*\(8065\).*|\1 "127.0.0.1:\2",|' \
		-e 's|\("ListenAddress":\).*\(8067\).*|\1 "127.0.0.1:\2"|' \
		-e 's|\("ConsoleLevel":\).*|\1 "INFO",|' \
		-e 's|\("EnableDiagnostics":\).*|\1 false|' \
		-e 's|\("Directory":\).*\(/data/\).*|\1 "'${datadir}'\2",|g' \
		-e 's|\("Directory":\).*\(/plugins\).*|\1 "'${datadir}'\2",|' \
		-e 's|\("ClientDirectory":\).*\(/client/plugins\).*|\1 "'${datadir}'\2",|' \
		-e 's|tcp(dockerhost:3306)|unix(/run/mysqld/mysqld.sock)|' \
		config/default.json || die

	# Reset email sending to original configuration
	sed -i \
		-e 's|\("SendEmailNotifications":\).*|\1 false,|' \
		-e 's|\("FeedbackEmail":\).*|\1 "",|' \
		-e 's|\("SMTPServer":\).*|\1 "",|' \
		-e 's|\("SMTPPort":\).*|\1 "",|' \
		config/default.json || die

	# shellcheck disable=SC1117
	# Remove the git call, as the tarball isn't a proper git repository
	sed -i \
		-E "s/^(\s*)COMMIT_HASH:(.*),$/\1COMMIT_HASH: JSON.stringify\(\"${WEBAPP_COMMIT}\)\"\),/" \
		client/webpack.config.js || die

	default
}

src_compile() {
	export GOPATH="${G}"
	export GOBIN="${S}"
	export CGO_CFLAGS="${CFLAGS}"
	export CGO_LDFLAGS="${LDFLAGS}"
	(use static && ! use pie) && export CGO_ENABLED=0
	(use static && use pie) && CGO_LDFLAGS+=" -static"

	local myldflags=(
		"$(usex !debug '-s -w' '')"
		-X "${EGO_PN}/model.BuildNumber=${PV}"
		-X "'${EGO_PN}/model.BuildDate=$(date -u)'"
		-X "${EGO_PN}/model.BuildHash=${GIT_COMMIT}"
		-X "${EGO_PN}/model.BuildHashEnterprise=none"
		-X "${EGO_PN}/model.BuildEnterpriseReady=false"
	)

	local mygoargs=(
		-v -work -x
		-buildmode "$(usex pie pie exe)"
		-asmflags "all=-trimpath=${S}"
		-gcflags "all=-trimpath=${S}"
		-ldflags "${myldflags[*]}"
		-tags "$(usex static 'netgo' '')"
		-installsuffix "$(usex static 'netgo' '')"
	)

	pushd client > /dev/null || die
	# https://git.powerel.org/powerel7/web/src/branch/master/SPECS/mattermost.spec
	npm install --save || die
	git clone --depth=1 "https://github.com/imagemin/optipng-bin" node_modules/optipng-bin || die
	sed 's/--with-system-zlib/--with-system-zlib --with-system-libpng/' -i node_modules/optipng-bin/lib/install.js || die
	npm rebuild || die
	npm install imagemin-optipng imagemin-gifsicle || die
	npm run build || die
	if use npm-audit && [[ $(npm --version | cut -d "." -f 1) -gt 5 ]]; then
		ebegin "Attempting to fix potential vulnerabilities"
		npm audit fix --package-lock-only || true
		eend $? || die
	fi
	popd > /dev/null || die

	go install "${mygoargs[@]}" ./cmd/mattermost || die
}

src_install() {
	exeinto /usr/libexec/mattermost/bin
	doexe mattermost
	use debug && dostrip -x /usr/libexec/mattermost/bin/mattermost

	newinitd "${FILESDIR}/${PN}.initd-r3" "${PN}"
	systemd_newunit "${FILESDIR}/${PN}.service-r2" "${PN}.service"

	insinto /etc/mattermost
	doins config/{README.md,default.json}
	newins config/default.json config.json
	fowners mattermost:mattermost /etc/mattermost/config.json
	fperms 600 /etc/mattermost/config.json

	insinto /usr/share/mattermost
	doins -r {fonts,i18n,templates}

	insinto /usr/share/mattermost/client
	doins -r client/dist/*

	diropts -o mattermost -g mattermost -m 0750
	keepdir /var/{lib,log}/mattermost
	keepdir /var/lib/mattermost/client

	dosym ../libexec/mattermost/bin/mattermost /usr/bin/mattermost
	dosym ../../../../etc/mattermost/config.json /usr/libexec/mattermost/config/config.json
	dosym ../../share/mattermost/fonts /usr/libexec/mattermost/fonts
	dosym ../../share/mattermost/i18n /usr/libexec/mattermost/i18n
	dosym ../../share/mattermost/templates /usr/libexec/mattermost/templates
	dosym ../../share/mattermost/client /usr/libexec/mattermost/client
	dosym ../../../var/log/mattermost /usr/libexec/mattermost/logs
}
