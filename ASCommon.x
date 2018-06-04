#import "ASCommon.h"
#import "ASPreferences.h"
#include <sys/sysctl.h>
#import <objc/runtime.h>
#import "ASPasscodeHandler.h"
#import "ASAuthenticationController.h"
#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>

@interface ASCommon ()
- (void)authenticated:(BOOL)wasCancelled;
@end

@implementation ASCommon

+ (instancetype)sharedInstance {
    static ASCommon *sharedCommonObj = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedCommonObj = [[self alloc] init];
    });

    return sharedCommonObj;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center addObserverForName:@"com.a3tweaks.asphaleia.xpc/AuthSucceeded" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
            [self authenticated:NO];
        }];
        [center addObserverForName:@"com.a3tweaks.asphaleia.xpc/AuthCancelled" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
            [self authenticated:YES];
        }];
    }

    return self;
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
