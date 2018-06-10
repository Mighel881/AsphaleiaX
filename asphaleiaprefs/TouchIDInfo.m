#import <Foundation/Foundation.h>
#import "TouchIDInfo.h"
#import "../ASPreferences.h"

BOOL isTouchIDDevice() {
	return [ASPreferences isTouchIDDevice];
}
