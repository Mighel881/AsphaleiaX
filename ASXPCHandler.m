#import "ASXPCHandler.h"
#import "Asphaleia.h"
#import <objc/runtime.h>
#import "ASPreferences.h"
#import "ASAuthenticationController.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import <rocketbootstrap/rocketbootstrap.h>

@interface ASPreferences ()
@property (readwrite) BOOL asphaleiaDisabled;
@property (readwrite) BOOL itemSecurityDisabled;
@end

@implementation ASXPCHandler

+ (instancetype)sharedInstance {
	static ASXPCHandler *sharedInstance = nil;
	static dispatch_once_t token;
	dispatch_once(&token, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		_messagingServer = [CPDistributedMessagingCenter centerNamed:@"com.a3tweaks.asphaleia.xpc"];
		rocketbootstrap_distributedmessagingcenter_apply(_messagingServer);

		[_messagingServer runServerOnCurrentThread];

		[_messagingServer registerForMessageName:@"com.a3tweaks.asphaleia.xpc/CheckSlideUpControllerActive" target:self selector:@selector(handleMessageNamed:withUserInfo:)];
		[_messagingServer registerForMessageName:@"com.a3tweaks.asphaleia.xpc/SetAsphaleiaState" target:self selector:@selector(handleMessageNamed:withUserInfo:)];
		[_messagingServer registerForMessageName:@"com.a3tweaks.asphaleia.xpc/ReadAsphaleiaState" target:self selector:@selector(handleMessageNamed:withUserInfo:)];
		[_messagingServer registerForMessageName:@"com.a3tweaks.asphaleia.xpc/SetUserAuthorisedApp" target:self selector:@selector(handleMessageNamed:withUserInfo:)];
		[_messagingServer registerForMessageName:@"com.a3tweaks.asphaleia.xpc/AuthenticateApp" target:self selector:@selector(handleMessageNamed:withUserInfo:)];
		[_messagingServer registerForMessageName:@"com.a3tweaks.asphaleia.xpc/AuthenticateFunction" target:self selector:@selector(handleMessageNamed:withUserInfo:)];
		[_messagingServer registerForMessageName:@"com.a3tweaks.asphaleia.xpc/GetCurrentAuthAlert" target:self selector:@selector(handleMessageNamed:withUserInfo:)];
		[_messagingServer registerForMessageName:@"com.a3tweaks.asphaleia.xpc/GetCurrentTempUnlockedApp" target:self selector:@selector(handleMessageNamed:withUserInfo:)];
		[_messagingServer registerForMessageName:@"com.a3tweaks.asphaleia.xpc/IsTouchIDDevice" target:self selector:@selector(handleMessageNamed:withUserInfo:)];
	}

	return self;
}

- (NSDictionary *)handleMessageNamed:(NSString *)name withUserInfo:(NSDictionary *)userInfo {
	if ([name isEqualToString:@"com.a3tweaks.asphaleia.xpc/CheckSlideUpControllerActive"]) {
		return @{ @"active" : @(_slideUpControllerActive) };
	} else if ([name isEqualToString:@"com.a3tweaks.asphaleia.xpc/SetAsphaleiaState"]) {
		if (userInfo[@"asphaleiaDisabled"]) {
			[ASPreferences sharedInstance].asphaleiaDisabled = [userInfo[@"asphaleiaDisabled"] boolValue];
		}

		if (userInfo[@"itemSecurityDisabled"]) {
			[ASPreferences sharedInstance].itemSecurityDisabled = [userInfo[@"itemSecurityDisabled"] boolValue];
		}
	} else if ([name isEqualToString:@"com.a3tweaks.asphaleia.xpc/ReadAsphaleiaState"]) {
		return @{ @"asphaleiaDisabled" : @([ASPreferences sharedInstance].asphaleiaDisabled), @"itemSecurityDisabled" : @([ASPreferences sharedInstance].itemSecurityDisabled) };
	} else if ([name isEqualToString:@"com.a3tweaks.asphaleia.xpc/SetUserAuthorisedApp"]) {
		[ASAuthenticationController sharedInstance].appUserAuthorisedID = userInfo[@"appIdentifier"];
	} else if ([name isEqualToString:@"com.a3tweaks.asphaleia.xpc/AuthenticateApp"]) {
		BOOL isProtected = [[ASAuthenticationController sharedInstance] authenticateAppWithDisplayIdentifier:userInfo[@"appIdentifier"] customMessage:userInfo[@"customMessage"] dismissedHandler:^(BOOL wasCancelled) {
			NSString *name = wasCancelled ? @"com.a3tweaks.asphaleia.xpc/AuthCancelled" : @"com.a3tweaks.asphaleia.xpc/AuthSucceeded";
			[[NSDistributedNotificationCenter defaultCenter] postNotificationName:name object:nil];
		}];

		return @{ @"isProtected" : @(isProtected) };
	} else if ([name isEqualToString:@"com.a3tweaks.asphaleia.xpc/AuthenticateFunction"]) {
		BOOL isProtected = [[ASAuthenticationController sharedInstance] authenticateFunction:[userInfo[@"alertType"] intValue] dismissedHandler:^(BOOL wasCancelled) {
			NSString *name = wasCancelled ? @"com.a3tweaks.asphaleia.xpc/AuthCancelled" : @"com.a3tweaks.asphaleia.xpc/AuthSucceeded";
			[[NSDistributedNotificationCenter defaultCenter] postNotificationName:name object:nil];
		}];

		return @{ @"isProtected" : @(isProtected) };
	} else if ([name isEqualToString:@"com.a3tweaks.asphaleia.xpc/GetCurrentAuthAlert"]) {
		if ([ASAuthenticationController sharedInstance].currentAuthAlert) {
			return @{ @"displayingAuthAlert" : @YES };
		} else {
			return @{ @"displayingAuthAlert" : @NO };
		}
	} else if ([name isEqualToString:@"com.a3tweaks.asphaleia.xpc/GetCurrentTempUnlockedApp"]) {
		if ([ASAuthenticationController sharedInstance].temporarilyUnlockedAppBundleID) {
			return @{ @"bundleIdentifier" : [ASAuthenticationController sharedInstance].temporarilyUnlockedAppBundleID };
		} else {
			return @{ @"bundleIdentifier" : [NSNull null] };
		}
	} else if ([name isEqualToString:@"com.a3tweaks.asphaleia.xpc/IsTouchIDDevice"]) {
		return @{ @"isTouchIDDevice" : @([ASPreferences isTouchIDDevice]) };
	}

	return nil;
}

@end
