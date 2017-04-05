#import "TouchIDInfo.h"
#import <objc/runtime.h>
#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import "../ASPreferences.h"

BOOL isTouchIDDevice(void) {
	return [ASPreferences isTouchIDDevice];
}
