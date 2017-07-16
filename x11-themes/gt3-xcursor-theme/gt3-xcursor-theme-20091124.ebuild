# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id: x11-themes/gt3-colors-theme/gt3-xcursor-theme-20091124.ebuild,v 1.1 2014/07/31 00:22:05 Exp $

EAPI=5

inherit gnome2-utils

DESCRIPTION="GT3 cursor themes ported to *nix."
HOMEPAGE="http://kde-look.org/content/show.php/GT3?content=106536"
SRC_URI="http://kde-look.org/CONTENT/content-files/106536-GT3-colors-pack.rar -> ${P}.rar"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="-minimal"

RDEPEND="minimal? ( !x11-themes/xcursor-themes )"
DEPEND="app-arch/unrar"

RESTRICT="binchecks strip"

S="${WORKDIR}"

src_install() {
	for pkg in GT3{,-azure,-bronze,-light,-red}; do
		unpack ./${pkg}.tar.gz
	done
	insinto /usr/share/icons
	doins -r GT3{,-azure,-bronze,-light,-red} || die
}

pkg_preinst() { gnome2_icon_savelist; }
pkg_postinst() { gnome2_icon_cache_update; }
pkg_postrm() { gnome2_icon_cache_update; }
