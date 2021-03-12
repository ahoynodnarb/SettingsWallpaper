include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = SettingsWallpaperPrefs

SettingsWallpaperPrefs_FILES = SWPFRootListController.m
SettingsWallpaperPrefs_INSTALL_PATH = /Library/PreferenceBundles
SettingsWallpaperPrefs_FRAMEWORKS = UIKit
SettingsWallpaperPrefs_PRIVATE_FRAMEWORKS = Preferences
SettingsWallpaperPrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/SettingsWallpaperPrefs.plist$(ECHO_END)
