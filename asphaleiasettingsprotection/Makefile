INSTALL_TARGET_PROCESSES = Preferences

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AsphaleiaSettingsProtection
AsphaleiaSettingsProtection_FILES = Tweak.x  ../asphaleiaprefs/ASPINController.m
AsphaleiaSettingsProtection_FRAMEWORKS = UIKit
AsphaleiaSettingsProtection_PRIVATE_FRAMEWORKS = Preferences
AsphaleiaSettingsProtection_CFLAGS = -I../Headers
AsphaleiaSettingsProtection_LDFLAGS = -L"../.theos/obj/debug"
AsphaleiaSettingsProtection_LIBRARIES = asphaleiaui

include $(THEOS_MAKE_PATH)/tweak.mk
