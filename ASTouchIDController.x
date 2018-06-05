/* Modified from Sassoty's code
https://github.com/Sassoty/BioTesting */
#import "ASTouchIDController.h"
#import "ASActivatorListener.h"
#import "ASControlPanel.h"
#import "ASPreferences.h"


@interface ASTouchIDController ()
@property (readwrite) BOOL isMonitoring;
@property (readwrite) id lastMatchedFingerprint;
@end

@implementation ASTouchIDController

+ (instancetype)sharedInstance {
	// Setup instance for current class once
	static ASTouchIDController *sharedInstance = nil;
	static dispatch_once_t token;
	dispatch_once(&token, ^{
		sharedInstance = [[self alloc] init];
	});

	// Provide instance
	return sharedInstance;
}

- (instancetype)init {
	self = [super init];
	if (self) {
		NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
		[center addObserverForName:@"com.a3tweaks.asphaleia.startmonitoring" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			[self startMonitoring];
		}];

		[center addObserverForName:@"com.a3tweaks.asphaleia.stopmonitoring" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			[self stopMonitoring];
		}];
	}

	return self;
}

- (void)biometricKitInterface:(_SBUIBiometricKitInterface *)interface handleEvent:(NSUInteger)event {
	//[[objc_getClass("SBScreenFlash") mainScreenFlasher] flashWhiteWithCompletion:nil];
	if (!self.isMonitoring || ![ASPreferences isTouchIDDevice]) {
		return;
	}

	switch (event) {
		case TouchIDFingerDown: {
			asphaleiaLogMsg(@"Finger down");
			[[NSNotificationCenter defaultCenter] postNotificationName:@"com.a3tweaks.asphaleia.fingerdown" object:self];
			break;
		}
		case TouchIDFingerUp: {
			asphaleiaLogMsg(@"Finger up");
			[[NSNotificationCenter defaultCenter] postNotificationName:@"com.a3tweaks.asphaleia.fingerup" object:self];
			break;
		}
		case TouchIDFingerHeld:
			asphaleiaLogMsg(@"Finger held");
			[[NSNotificationCenter defaultCenter] postNotificationName:@"com.a3tweaks.asphaleia.fingerheld" object:self];
			break;
		case TouchIDMatched:
			asphaleiaLogMsg(@"Finger matched");
			[[NSNotificationCenter defaultCenter] postNotificationName:@"com.a3tweaks.asphaleia.authsuccess" object:self];
			[self stopMonitoring];
			_shouldBlockLockscreenMonitor = NO;
			break;
		case TouchIDNotMatched: {
			asphaleiaLogMsg(@"Authentication failed");
			[[NSNotificationCenter defaultCenter] postNotificationName:@"com.a3tweaks.asphaleia.authfailed" object:self];
			if ([[ASPreferences sharedInstance] vibrateOnIncorrectFingerprint]) {
				AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
			}
			break;
		}
		// For the new iPhone
		case 10: {
			asphaleiaLogMsg(@"Authentication failed");
			[[NSNotificationCenter defaultCenter] postNotificationName:@"com.a3tweaks.asphaleia.authfailed" object:self];
			if ([[ASPreferences sharedInstance] vibrateOnIncorrectFingerprint]) {
				AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
			}
			break;
		}
	}
}

- (void)matchResult:(id)result withDetails:(id)details {
	if (!result) {
		return;
	}

	asphaleiaLogMsg(@"Finger matched");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"com.a3tweaks.asphaleia.authsuccess" object:self userInfo:@{ @"fingerprint" : result }];
	self.lastMatchedFingerprint = result;
	_shouldBlockLockscreenMonitor = NO;
}

- (void)startMonitoring {
	// If already monitoring, don't start again
	if (self.isMonitoring || starting || ![ASPreferences isTouchIDDevice]) {
		return;
	}
	starting = YES;

/*
	LAActivator *activator = [objc_getClass("LAActivator") sharedInstance];
	if (activator) {
		LAEvent *event = [objc_getClass("LAEvent") eventWithName:@"libactivator.fingerprint-sensor.press.single" mode:activator.currentEventMode];
		if (event) {
			activatorListenerNames = [activator assignedListenerNamesForEvent:event];
			if (activatorListenerNames) {
				for (NSString *listenerName in activatorListenerNames) {
					[activator removeListenerAssignment:listenerName fromEvent:event];
				}
			}
		}
	}
*/

	_SBUIBiometricKitInterface *interface = [%c(BiometricKit) manager].delegate;
	_oldDelegate = interface.delegate;

	dlopen("/usr/lib/libactivator.dylib", RTLD_LAZY);
	Class la = %c(LAActivator);
	if (la) {
		if ([[%c(LAActivator) sharedInstance] hasListenerWithName:@"Dynamic Selection"]) {
			[[ASActivatorListener sharedInstance] unload];
		}

		if ([[%c(LAActivator) sharedInstance] hasListenerWithName:@"Control Panel"]) {
			[[ASControlPanel sharedInstance] unload];
		}
	}

	// Begin listening :D
	interface.delegate = self;
	[interface matchWithMode:0 andCredentialSet:nil];

	starting = NO;
	self.isMonitoring = YES;

	asphaleiaLogMsg(@"Touch ID monitoring began");
}

- (void)stopMonitoring {
	if (!self.isMonitoring || stopping || ![ASPreferences isTouchIDDevice]) {
		return;
	}
	stopping = YES;

	_SBUIBiometricKitInterface *interface = [%c(BiometricKit) manager].delegate;
	[interface cancel];
	interface.delegate = _oldDelegate;
	[interface detectFingerWithOptions:nil];

	_oldDelegate = nil;

/*
	LAActivator *activator = [objc_getClass("LAActivator") sharedInstance];
  if (activator && activatorListenerNames) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
			LAEvent *event = [objc_getClass("LAEvent") eventWithName:@"libactivator.fingerprint-sensor.press.single" mode:activator.currentEventMode];
			if (event) {
				for (NSString *listenerName in activatorListenerNames) {
					[activator addListenerAssignment:listenerName toEvent:event];
				}
			}
		});
	}
*/

	dlopen("/usr/lib/libactivator.dylib", RTLD_LAZY);
	Class la = %c(LAActivator);
	if (la) {
		if (![[%c(LAActivator) sharedInstance] hasListenerWithName:@"Dynamic Selection"]) {
			[[ASActivatorListener sharedInstance] load];
		}
		if (![[%c(LAActivator) sharedInstance] hasListenerWithName:@"Control Panel"]) {
			[[ASControlPanel sharedInstance] load];
		}
	}

	stopping = NO;
	self.isMonitoring = NO;

	asphaleiaLogMsg(@"Touch ID monitoring ended");
}

@end
