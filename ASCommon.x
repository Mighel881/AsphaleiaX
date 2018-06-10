#import "ASCommon.h"
#import "ASPreferences.h"
#import "ASPasscodeHandler.h"
#import "ASAuthenticationController.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import <rocketbootstrap/rocketbootstrap.h>

@interface ASCommon ()
- (void)authenticated:(BOOL)wasCancelled;
@end

@implementation ASCommon

+ (instancetype)sharedInstance {
    static ASCommon *sharedInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"com.a3tweaks.asphaleia.xpc/AuthSucceeded" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
            [self authenticated:NO];
        }];

        [[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"com.a3tweaks.asphaleia.xpc/AuthCancelled" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
            [self authenticated:YES];
        }];

        _centre = [CPDistributedMessagingCenter centerNamed:@"com.a3tweaks.asphaleia.xpc"];
        rocketbootstrap_distributedmessagingcenter_apply(_centre);
    }

    return self;
}

- (BOOL)displayingAuthAlert {
    NSDictionary *reply = [_centre sendMessageAndReceiveReplyName:@"com.a3tweaks.asphaleia.xpc/GetCurrentAuthAlert" userInfo:nil];
    return [reply[@"displayingAuthAlert"] boolValue];
}

- (BOOL)authenticateAppWithDisplayIdentifier:(NSString *)appIdentifier customMessage:(NSString *)customMessage dismissedHandler:(ASCommonAuthenticationHandler)handler {
    if (%c(ASAuthenticationController)) {
      return [[%c(ASAuthenticationController) sharedInstance] authenticateAppWithDisplayIdentifier:appIdentifier customMessage:customMessage dismissedHandler:handler];
    }

    NSDictionary *reply = [_centre sendMessageAndReceiveReplyName:@"com.a3tweaks.asphaleia.xpc/AuthenticateApp" userInfo:@{ @"appIdentifier" : appIdentifier, @"customMessage" : customMessage }];
    return [reply[@"isProtected"] boolValue];
}

- (BOOL)authenticateFunction:(ASAuthenticationAlertType)alertType dismissedHandler:(ASCommonAuthenticationHandler)handler {
    if (%c(ASAuthenticationController)) {
      return [[%c(ASAuthenticationController) sharedInstance] authenticateFunction:alertType dismissedHandler:handler];
    }

    authHandler = [handler copy];
    NSDictionary *reply = [_centre sendMessageAndReceiveReplyName:@"com.a3tweaks.asphaleia.xpc/AuthenticateFunction" userInfo:@{ @"alertType" : @(alertType) }];
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
