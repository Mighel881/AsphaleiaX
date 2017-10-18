#import "ASPasscodeHandler.h"
#import "ASCommon.h"
#import "ASPreferences.h"
#import <AudioToolbox/AudioServices.h>
#import "Asphaleia.h"

@interface ASPasscodeHandler ()
@property SBUIPasscodeLockViewSimpleFixedDigitKeypad *passcodeView;
@property UIWindow *passcodeWindow;
@property (nonatomic, strong) ASPasscodeHandlerEventBlock eventBlock;
@end

void showPasscodeView(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[[ASPasscodeHandler sharedInstance] showInKeyWindowWithPasscode:[[ASPreferences sharedInstance] getPasscode] iconView:nil eventBlock:^void(BOOL authenticated){
		if (authenticated) {
			CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.a3tweaks.asphaleia.passcodeauthsuccess"), NULL, NULL, YES);
		} else {
			CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.a3tweaks.asphaleia.passcodeauthfailed"), NULL, NULL, YES);
		}
	}];
}

static NSBundle *bundle;

@implementation ASPasscodeHandler

+ (instancetype)sharedInstance {
	static ASPasscodeHandler *sharedInstance = nil;
	static dispatch_once_t token;
	dispatch_once(&token, ^{
	  sharedInstance = [self new];
	  addObserver(showPasscodeView,"com.a3tweaks.asphaleia.showpasscodeview");
		bundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/AsphaleiaPrefs.bundle"];
	});
	return sharedInstance;
}

- (void)showInKeyWindowWithPasscode:(NSString *)passcode iconView:(SBIconView *)iconView eventBlock:(ASPasscodeHandlerEventBlock)eventBlock {
	self.passcode = passcode;
	self.eventBlock = [eventBlock copy];

	if (self.passcodeView && self.passcodeWindow) {
		[self.passcodeView removeFromSuperview];
		self.passcodeWindow.hidden = YES;
		self.passcodeView = nil;
		self.passcodeWindow = nil;
	}

	self.passcodeWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	self.passcodeWindow.windowLevel = UIWindowLevelAlert;
	self.passcodeWindow._secure = YES;
	self.passcodeView = [[objc_getClass("SBUIPasscodeLockViewSimpleFixedDigitKeypad") alloc] initWithLightStyle:NO numberOfDigits:passcode.length];
	self.passcodeView.showsEmergencyCallButton = NO;
	self.passcodeView.delegate = self;

	UIVisualEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
	UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];

	effectView.frame = self.passcodeWindow.bounds;
	[self.passcodeWindow insertSubview:effectView atIndex:0];

	self.passcodeView.backgroundAlpha = 0.f;

	UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[iconView.icon getIconImage:1]];
	iconImageView.contentMode = UIViewContentModeScaleAspectFill;
	iconImageView.frame = CGRectMake(0,0,40,40);
	[self.passcodeView _layoutStatusView];
	iconImageView.center = CGPointMake(CGRectGetMidX(self.passcodeWindow.bounds), self.passcodeView.statusTitleView.center.y / 2 - 5);

	self.passcodeView.luminosityBoost = 0.33;
	[self.passcodeView _evaluateLuminance];

	[self.passcodeWindow addSubview:iconImageView];
	[self.passcodeWindow addSubview:self.passcodeView];
	self.passcodeWindow.alpha = 0.f;
	[self.passcodeWindow makeKeyAndVisible];
	[self.passcodeView updateStatusText:[bundle localizedStringForKey:@"ENTER_PASS" value:nil table:@"Localizable"] subtitle:nil animated:NO];
	[UIView animateWithDuration:0.15f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
		self.passcodeWindow.alpha = 1.f;
	} completion:nil];
}

- (void)passcodeLockViewPasscodeEntered:(SBUIPasscodeLockViewSimpleFixedDigitKeypad *)passcodeView {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		if ([passcodeView.passcode length] == [self.passcode length] && [passcodeView.passcode isEqualToString:self.passcode]) {
				[UIView animateWithDuration:0.15f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
						self.passcodeWindow.alpha = 0.f;
				} completion:^(BOOL finished){
						if (finished) {
								[self.passcodeView removeFromSuperview];
								self.passcodeWindow.hidden = YES;
								self.passcodeView = nil;
								self.passcodeWindow = nil;
								self.eventBlock(YES);
						}
				}];
		} else if ([passcodeView.passcode length] == [self.passcode length] && ![passcodeView.passcode isEqualToString:self.passcode]) {
			[passcodeView resetForFailedPasscode];
		}
	});
}

- (void)passcodeLockViewCancelButtonPressed:(SBUIPasscodeLockViewSimpleFixedDigitKeypad *)passcodeView {
	[UIView animateWithDuration:0.15f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
		self.passcodeWindow.alpha = 0.f;
	} completion:^(BOOL finished) {
		if (finished) {
			[self.passcodeView removeFromSuperview];
			self.passcodeWindow.hidden = YES;
			self.passcodeView = nil;
			self.passcodeWindow = nil;
			self.eventBlock(NO);
		}
	}];
}

- (void)dismissPasscodeView {
	if (!self.passcodeWindow) {
		return;
	}

	[UIView animateWithDuration:0.15f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
		self.passcodeWindow.alpha = 0.f;
	} completion:^(BOOL finished){
		if (finished) {
			[self.passcodeView removeFromSuperview];
			self.passcodeWindow.hidden = YES;
			self.passcodeView = nil;
			self.passcodeWindow = nil;
			self.eventBlock(NO);
		}
	}];
}

@end
