#
# Simple top level makefile to avoid having to directory interact with
# the horrible cmake system!
#
# Sure it probably only works on Linux, doesn't support x-compile and it
# probably only exposes a small fraction of the configuration provided by the
# all power cmake.
# But that small fraction probably represents 90-99% of what most people
# actually want to do without requiring trawling forums!
#
# To build pvr.hts do the following (I'm assuming you already have the source
# and so have completed steps 1 and 2):
#
# make zip
#
# You should now have a zip file in the same directory as the Makefile that you
# can install on your kodi system
#

DIR       := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
BUILD_DIR ?= $(DIR)/build
EXTRA_DIR ?= $(BUILD_DIR)
XBMC_DIR  ?= $(EXTRA_DIR)/xbmc
ADDON_DIR ?= $(XBMC_DIR)/addons

CHDIR     ?= cd
GIT				?= git
MKDIR			?= mkdir -p
CMAKE     ?= cmake
ZIP       ?= zip

#
# Config
#
ifeq ($(RELEASE), 1)
CMAKE_BUILD ?= Release
else
CMAKE_BUILD ?= Debug
endif

#
# Phony rules
.PHONY: zip build setup cmake xbmc

#
# Default - build zip
#
default: zip

#
# Create build directory
#
$(BUILD_DIR):
	$(MKDIR) $(BUILD_DIR)

#
# Fetch XBMC source if not already
#
$(XBMC_DIR):
	$(GIT) clone https://github.com/xbmc/xbmc.git $(XBMC_DIR)

#
# Checkout XBMC branch
#
xbmc: $(XBMC_DIR)
	BRANCH=`$(GIT) rev-parse --abbrev-ref HEAD`;\
	$(CHDIR) $(XBMC_DIR); $(GIT) checkout $$BRANCH || $(GIT) checkout master

#
# Configure CMAKE
#
cmake:
	$(CHDIR) $(BUILD_DIR);\
	$(CMAKE) -DADDONS_TO_BUILD=pvr.hts -DADDON_SRC_PREFIX=$(DIR)/.. \
		-DCMAKE_BUILD_TYPE=$(CMAKE_BUILD) -DCMAKE_INSTALL_PREFIX=$(ADDON_DIR) \
	  -DPACKAGE_ZIP=ON $(XBMC_DIR)/project/cmake/addons

#
# Setup
#
setup: $(BUILD_DIR) xbmc cmake

#
# Build
#
build: setup
	make -C $(BUILD_DIR)

#
# Build zip
#
zip: build
	$(CHDIR) $(ADDON_DIR); $(ZIP) -r $(DIR)/pvr.hts.zip pvr.hts

