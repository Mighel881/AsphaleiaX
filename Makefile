export TARGET = iphone:11.2:10.0

INSTALL_TARGET_PROCESSES = Preferences

ifeq ($(RESPRING),1)
	INSTALL_TARGET_PROCESSES += SpringBoard
endif

ifeq ($(IPAD),1)
export THEOS_DEVICE_IP=192.168.254.1
export THEOS_DEVICE_PORT=22
endif

export ADDITIONAL_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = libasphaleiaui
libasphaleiaui_FILES = ASCommon.x ASPreferences.x
libasphaleiaui_FRAMEWORKS = UIKit SystemConfiguration
libasphaleiaui_PRIVATE_FRAMEWORKS = AppSupport
libasphaleiaui_EXTRA_FRAMEWORKS = CydiaSubstrate
libasphaleiaui_LIBRARIES = rocketbootstrap
libasphaleiaui_CFLAGS = -IHeaders
libasphaleiaui_INSTALL_PATH = /usr/lib

TWEAK_NAME = Asphaleia
Asphaleia_FILES = Tweak.x ASXPCHandler.m ASTouchIDController.x ASAuthenticationController.x ASAuthenticationAlert.x ASAlert.m ASControlPanel.x ASPasscodeHandler.m ASTouchWindow.m ASActivatorListener.x
Asphaleia_FRAMEWORKS = UIKit CoreGraphics AudioToolbox
Asphaleia_PRIVATE_FRAMEWORKS = AppSupport SpringBoardUI SpringBoardUIServices
Asphaleia_LDFLAGS = -L$(THEOS_OBJ_DIR)
Asphaleia_CFLAGS = -IHeaders
Asphaleia_LIBRARIES = asphaleiaui rocketbootstrap

BUNDLE_NAME = AsphaleiaAssets
AsphaleiaAssets_INSTALL_PATH = /Library/Application Support/Asphaleia

SUBPROJECTS = asphaleiaprefs asphaleiaphotosprotection asphaleiaflipswitch asphaleiasettingsprotection

include $(THEOS_MAKE_PATH)/library.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS)/makefiles/bundle.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
