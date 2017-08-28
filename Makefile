export TARGET = iphone:9.2

INSTALL_TARGET_PROCESSES = Preferences

ifeq ($(RESPRING),1)
INSTALL_TARGET_PROCESSES += SpringBoard
endif

ifeq ($(IPAD),1)
export THEOS_DEVICE_IP=192.168.254.1
export THEOS_DEVICE_PORT=22
endif

include $(THEOS)/makefiles/common.mk

LIBRARY_NAME = libasphaleiaui
libasphaleiaui_FILES = ASCommon.mm NSTimer+Blocks.m ASPreferences.mm
libasphaleiaui_FRAMEWORKS = UIKit
libasphaleiaui_INSTALL_PATH = /usr/lib
libasphaleiaui_LIBRARIES = rocketbootstrap
libasphaleiaui_CFLAGS = -fobjc-arc -flto=thin

TWEAK_NAME = Asphaleia
Asphaleia_FILES = Tweak.xm ASXPCHandler.xm ASTouchIDController.mm ASAuthenticationController.mm ASAuthenticationAlert.xm ASAlert.xm ASControlPanel.mm ASPasscodeHandler.mm ASTouchWindow.m ASActivatorListener.mm
Asphaleia_FRAMEWORKS = UIKit CoreGraphics AudioToolbox
Asphaleia_LDFLAGS = -L$(THEOS_OBJ_DIR)
Asphaleia_LIBRARIES = asphaleiaui rocketbootstrap
Asphaleia_CFLAGS = -fobjc-arc

BUNDLE_NAME = AsphaleiaAssets
AsphaleiaAssets_INSTALL_PATH = /Library/Application Support/Asphaleia

SUBPROJECTS = asphaleiaprefs asphaleiaphotosprotection asphaleiaflipswitch asphaleiasettingsprotection

include $(THEOS_MAKE_PATH)/library.mk
include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS)/makefiles/bundle.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
