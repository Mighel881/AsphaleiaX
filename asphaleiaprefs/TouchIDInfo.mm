#import "TouchIDInfo.h"
#import <objc/runtime.h>
#import "../ASPreferences.h"

BOOL isTouchIDDevice(void) {
		return [ASPreferences isTouchIDDevice];
}
