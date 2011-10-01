# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-terms/enterminus/enterminus-9999.ebuild,v 1.1 2005/09/07 03:52:46 vapier Exp $

EAPI="2"

ESVN_SUB_PROJECT="PROTO"
inherit enlightenment

DESCRIPTION="PAM compatible session manager, epigone of entrance"

DEPEND=">=dev-libs/ecore-1.0
	>=dev-libs/eet-1.4.0
	>=dev-libs/eina-1.0
	>=media-libs/edje-1.0
	>=media-libs/evas-1.0
	>=x11-libs/elementary-0.5"
RDEPEND="virtual/pam
		sys-auth/consolekit
		grub2? ( sys-boot/grub:2 )"

IUSE="grub2"

src_configure() {
	export MY_ECONF="
		$(use_enable grub2 grub2)
	"
	enlightenment_src_configure
}

pkg_postinst(){
	use grub2 && einfo "do not forget to add this line 'GRUB_DEFAULT=saved' to /etc/default/grub"
}
