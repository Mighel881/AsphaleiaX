#import "ASCommon.h"
#include <sys/sysctl.h>
#import <objc/runtime.h>
#import "NSTimer+Blocks.h"
#import "ASPreferences.h"
#import "ASPasscodeHandler.h"
#import "ASAuthenticationController.h"
#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>

@interface ASCommon ()
- (void)authenticated:(BOOL)wasCancelled;
@end

void authenticationSuccessful(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    [[ASCommon sharedInstance] authenticated:NO];
}

void authenticationCancelled(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    [[ASCommon sharedInstance] authenticated:YES];
}

@implementation ASCommon

+ (instancetype)sharedInstance {
    static ASCommon *sharedCommonObj = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedCommonObj = [[self alloc] init];
        addObserver(authenticationSuccessful, "com.a3tweaks.asphaleia.xpc/AuthSucceeded");
        addObserver(authenticationCancelled, "com.a3tweaks.asphaleia.xpc/AuthCancelled");
    });

    return sharedCommonObj;
}

- (BOOL)displayingAuthAlert {
    CPDistributedMessagingCenter *centre = [CPDistributedMessagingCenter centerNamed:@"com.a3tweaks.asphaleia.xpc"];
    rocketbootstrap_distributedmessagingcenter_apply(centre);
    NSDictionary *reply = [centre sendMessageAndReceiveReplyName:@"com.a3tweaks.asphaleia.xpc/GetCurrentAuthAlert" userInfo:nil];
    return [reply[@"displayingAuthAlert"] boolValue];
}

- (BOOL)authenticateAppWithDisplayIdentifier:(NSString *)appIdentifier customMessage:(NSString *)customMessage dismissedHandler:(ASCommonAuthenticationHandler)handler {
    if (%c(ASAuthenticationController)) {
      return [[%c(ASAuthenticationController) sharedInstance] authenticateAppWithDisplayIdentifier:appIdentifier customMessage:customMessage dismissedHandler:handler];
    }

    CPDistributedMessagingCenter *centre = [CPDistributedMessagingCenter centerNamed:@"com.a3tweaks.asphaleia.xpc"];
    rocketbootstrap_distributedmessagingcenter_apply(centre);
    NSDictionary *reply = [centre sendMessageAndReceiveReplyName:@"com.a3tweaks.asphaleia.xpc/AuthenticateApp" userInfo:@{ @"appIdentifier" : appIdentifier, @"customMessage" : customMessage }];
    return [reply[@"isProtected"] boolValue];
}

- (BOOL)authenticateFunction:(ASAuthenticationAlertType)alertType dismissedHandler:(ASCommonAuthenticationHandler)handler {
    if (%c(ASAuthenticationController)) {
      return [[%c(ASAuthenticationController) sharedInstance] authenticateFunction:alertType dismissedHandler:handler];
    }

    authHandler = [handler copy];
    CPDistributedMessagingCenter *centre = [CPDistributedMessagingCenter centerNamed:@"com.a3tweaks.asphaleia.xpc"];
    rocketbootstrap_distributedmessagingcenter_apply(centre);
    NSDictionary *reply = [centre sendMessageAndReceiveReplyName:@"com.a3tweaks.asphaleia.xpc/AuthenticateFunction" userInfo:@{ @"alertType" : [NSNumber numberWithInt:alertType] }];
    return [reply[@"isProtected"] boolValue];
}

- (void)authenticated:(BOOL)wasCancelled {
    if (!authHandler) {
        return;
    }
    authHandler(wasCancelled);
    authHandler = nil;
}

@end
