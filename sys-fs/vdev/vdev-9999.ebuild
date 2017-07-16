# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id: sys-fs/vdev/vdev-9999.ebuild,v 1.0 2015/08/01 Exp $

EAPI=5

case "${PV}" in
	(9999*)
		KEYWORDS=""
		VCS_ECLASS=git-2
		EGIT_REPO_URI="git://github.com/jcnelson/${PN}.git"
		EGIT_PROJECT="${PN}.git"
		;;
	(*)
		KEYWORDS="~amd64 ~arm ~hppa ~ia64 ~mips ~s390 ~x86 ~amd64-linux ~x86-linux"
		VCS_ECLASS=vcs-snapshot
		SRC_URI="https://github.com/jcnelson/${PN}/archive/r${PV}.tar.gz -> ${P}.tar.gz"
		;;
esac
inherit multilib-minimal toolchain-funcs ${VCS_ECLASS}


DESCRIPTION="Virtual device manager for UNIX"
HOMEPAGE="https://github.com/jcnelson/vdev"

LICENSE="|| ( ISC GPL-3+ ) udev? ( GPL-2 )"
SLOT="0"
IUSE="+udev vdevfs"

DEPEND="udev? ( sys-fs/squashfs-tools )
	vdevfs? (
		sys-libs/libpstat[${MULTILIB_USEDEP}]
		sys-fs/fskit[${MULTILIB_USEDEP},fuse]
	)"
RDEPEND="${DEPEND}"

DOCS=( CONTRIBUTORS README.md how-to-test.md )

src_prepare()
{
	sed -e 's,dash,sh,g' -i "${S}"/*/*.sh \
		"${S}"/*/*/{*.sh,daemonlet} || die
	epatch_user
	multilib_copy_sources
}

multilib_src_compile()
{
	MAKEOPTS="-j1" emake
	use udev? MAKEOPTS="-j1" emake -C libudev-compat
	use vdevfs MAKEOPTS="-j1" emake -C fs
}

multilib_src_install()
{
	emake DESTDIR="${ED}" PREFIX= LIBDIR="$(get_libdir)" SHAREDIR=/usr/share \
		PKGCONFIGDIR="/usr/$(get_libdir)/pkgconfig" install
	use udev && \
		emake -C libudev-compat DESTDIR="${ED}" PREFIX= LIBDIR="$(get_libdir)" SHAREDIR=/usr/share \
		PKGCONFIGDIR="/usr/$(get_libdir)/pkgconfig" install
	use vdevfs && \
		emake -C fs DESTDIR="${ED}" PREFIX= LIBDIR="$(get_libdir)" SHAREDIR=/usr/share \
		PKGCONFIGDIR="/usr/$(get_libdir)/pkgconfig" install

	rm -f "${ED}"/etc/{conf,init}.d/vdev*
	newinitd "${FILESDIR}"/vdevd.initd vdevd
	newconfd "${FILESDIR}"/vdevd.confd vdevd
}
