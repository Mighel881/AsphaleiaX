include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = AsphaleiaPrefs
AsphaleiaPrefs_FILES = $(wildcard *.m)
AsphaleiaPrefs_INSTALL_PATH = /Library/PreferenceBundles
AsphaleiaPrefs_FRAMEWORKS = UIKit CoreGraphics AudioToolbox Social
AsphaleiaPrefs_PRIVATE_FRAMEWORKS = Preferences
AsphaleiaPrefs_EXTRA_FRAMEWORKS = Cephei CepheiPrefs CydiaSubstrate
AsphaleiaPrefs_CFLAGS = -I../Headers
AsphaleiaPrefs_LDFLAGS = -L"../.theos/obj/debug"
AsphaleiaPrefs_LIBRARIES = asphaleiaui flipswitch mobilegestalt applist

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/AsphaleiaPrefs.plist$(ECHO_END)
