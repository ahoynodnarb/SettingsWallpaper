PREFIX=$(THEOS)/toolchain/Xcode.xctoolchain/usr/bin/

INSTALL_TARGET_PROCESSES = SpringBoard


include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SettingsWallpaper

SettingsWallpaper_FILES = Tweak.xm
SettingsWallpaper_CFLAGS = -fobjc-arc
# SettingsWallpaper_FRAMEWORKS += SystemConfiguration
SettingsWallpaper_PRIVATE_FRAMEWORKS += AppSupport

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += settingswallpaperprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
