#import "TouchIDInfo.h"
#import "../ASPreferences.h"

BOOL isTouchIDDevice() {
	return [ASPreferences isTouchIDDevice];
}
