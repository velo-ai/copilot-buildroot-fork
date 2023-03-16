################################################################################
#
# kmsxx
#
################################################################################

################################################################################
# Copilot specific
#
# 1. Build the python bindings.  In addition to enabling the option we have to
# override Buildroot's desire to disable subproject wraps.
# 2. The subproject wrap hits an https server for the pybind11 subproject and
# we need to tell it where the certs are.
################################################################################
KMSXX_VERSION = 824bbb1f4cd062d66b457faca50f904b34dfd96c
KMSXX_SITE = $(call github,tomba,kmsxx,$(KMSXX_VERSION))
KMSXX_LICENSE = MPL-2.0
KMSXX_LICENSE_FILES = LICENSE
KMSXX_INSTALL_STAGING = YES
KMSXX_DEPENDENCIES = fmt libdrm host-pkgconf python-pybind
#KMSXX_CONF_OPTS = \
	-Dkmscube=false \
	-Dpykms=disabled \
	-Domap=disabled \
	-Dsystem-pybind11=enabled
KMSXX_CONF_OPTS = \
	-Dkmscube=false \
	-Dpykms=enabled \
	-Domap=disabled \
	-Dsystem-pybind11=enabled \
	--wrap-mode=default

KMSXX_CONF_ENV += SSL_CERT_DIR=/etc/ssl/certs
################################################################################
# End Copilot specific
################################################################################

ifeq ($(BR2_TOOLCHAIN_HAS_GCC_BUG_85180),y)
KMSXX_CXXFLAGS += $(TARGET_CXXFLAGS) -O0
endif

ifeq ($(BR2_PACKAGE_KMSXX_INSTALL_TESTS),y)
KMSXX_CONF_OPTS += -Dutils=true
# extra handling for some utils not installed by default
KMSXX_EXTRA_UTILS = kmsview kmscapture omap-wbcap omap-wbm2m
ifeq ($(BR2_PACKAGE_LIBEVDEV),y)
KMSXX_DEPENDENCIES += libevdev
KMSXX_EXTRA_UTILS += kmstouch
endif
define KMSXX_INSTALL_EXTRA_UTILS
	$(foreach t,$(KMSXX_EXTRA_UTILS),\
		$(INSTALL) -D -m 0755 $(@D)/build/utils/$(t) \
			$(TARGET_DIR)/usr/bin/$(t)
	)
endef
KMSXX_POST_INSTALL_TARGET_HOOKS += KMSXX_INSTALL_EXTRA_UTILS
else
KMSXX_CONF_OPTS += -Dutils=false
endif

$(eval $(meson-package))
