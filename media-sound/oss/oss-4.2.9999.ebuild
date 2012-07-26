# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: bar-overlay/media-sound/oss/oss-4.2.9999.ebuild,v 1.3 2012/07/27 00:43:44 -tclover Exp $

EAPI=4

inherit flag-o-matic libtool mercurial

filter-ldflags "-Wl,-O1"

EHG_REPO_URI="http://opensound.hg.sourceforge.net:8000/hgroot/opensound/opensound"

DESCRIPTION="OSSv4 portable, mixing-capable, high quality sound system for Unix"
HOMEPAGE="http://developer.opensound.com/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"

SOUND_CARDS="ali5455 atiaudio audigyls audioloop audiopci cmi878x cmpci cs4281
cs461x digi96 emu10k1x envy24 envy24ht fmedia geode hdaudio ich imux madi
midiloop midimix sblive sbpci sbxfi solo trident usb userdev via823x via97 ymf7xx"
for card in ${SOUND_CARDS}; do
	has ${card} ${OSS_CARDS} && IUSE_OSS_CARDS+=" +" || IUSE_OSS_CARDS+=" "
	IUSE_OSS_CARDS+=oss_cards_${card}
done

IUSE="${IUSE_OSS_CARDS} +midi"
REQUIRED_USE="oss_cards_midiloop? ( midi ) oss_cards_midimix? ( midi )"

DEPEND="sys-apps/gawk
	x11-libs/gtk+:2
	>=sys-kernel/linux-headers-2.6.11
	!media-sound/oss-devel"

RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}"

src_unpack() {
	mercurial_src_unpack
	mkdir build

	cp "${FILESDIR}"/oss ${PN}/setup/Linux/oss/etc/S89oss
}

src_prepare() {
	elibtoolize
}

src_configure() {
	local conf="--enable-timings \
		$(use midi && echo '--config-midi=YES' || echo '--config-midi=NO') \
		--only-drv=osscore"
	for card in ${SOUND_CARDS}; do
		use oss_cards_${card} && conf+=,oss_${card}
	done
	"${S}"/configure ${conf} || die "configure failed"
	sed -i -e 's/-D_KERNEL//' -i Makefile
}

src_compile() {
	cd ../build
	emake build || die "emake build failed"
}

src_install() {
	newinitd "${FILESDIR}"/oss oss
	cd ../build
	cp -R prototype/* "${D}"
}

pkg_postinst() {
	elog "To use ${P} for the first time you must run"
	elog "# /etc/init.d/oss start "
	elog ""
	elog "If you are upgrading, run"
	elog "# /etc/init.d/oss restart "
	elog ""
	elog "Enjoy OSSv4!"
}
