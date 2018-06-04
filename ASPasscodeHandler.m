#import "ASPasscodeHandler.h"
#import "Asphaleia.h"
#import "ASCommon.h"
#import "ASPreferences.h"
#import <AudioToolbox/AudioServices.h>
#import <UIKit/UIImage+Private.h>

@interface ASPasscodeHandler ()
@property (strong, nonatomic) SBUIPasscodeLockViewSimpleFixedDigitKeypad *passcodeView;
@property (strong, nonatomic) UIWindow *passcodeWindow;
@property (copy, nonatomic) ASPasscodeHandlerEventBlock eventBlock;
@end

void showPasscodeView(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[[ASPasscodeHandler sharedInstance] showInKeyWindowWithPasscode:[[ASPreferences sharedInstance] getPasscode] iconView:nil eventBlock:^void(BOOL authenticated) {
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
		sharedInstance = [[self alloc] init];
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, showPasscodeView, CFSTR("com.a3tweaks.asphaleia.showpasscodeview"), NULL, CFNotificationSuspensionBehaviorCoalesce);
		bundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/AsphaleiaPrefs.bundle"];
	});
	return sharedInstance;
}

- (void)showInKeyWindowWithPasscode:(NSString *)passcode iconView:(SBIconView *)iconView eventBlock:(ASPasscodeHandlerEventBlock)eventBlock {
	_passcode = passcode;
	self.eventBlock = eventBlock;

	if (self.passcodeView && self.passcodeWindow) {
		[self.passcodeView removeFromSuperview];
		self.passcodeWindow.hidden = YES;
		self.passcodeView = nil;
		self.passcodeWindow = nil;
	}

	self.passcodeWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	self.passcodeWindow.windowLevel = UIWindowLevelAlert;
	self.passcodeWindow._secure = YES;

	self.passcodeView = [[SBUIPasscodeLockViewSimpleFixedDigitKeypad alloc] initWithLightStyle:NO numberOfDigits:passcode.length];

	_UIBackdropViewSettings *settings = [_UIBackdropViewSettings settingsForPrivateStyle:2030 graphicsQuality:100];
	UIColor *combinedTintColor = settings.combinedTintColor;
	UIColor *customBackgroundColor = [combinedTintColor colorWithAlphaComponent:2030];
	self.passcodeView.customBackgroundColor = customBackgroundColor;
	self.passcodeView.backgroundAlpha = [combinedTintColor alphaComponent];

	SBWallpaperLegibilitySettingsProvider *settingsProvider = [[NSClassFromString(@"SBWallpaperLegibilitySettingsProvider") alloc] initWithVariant:0];
	self.passcodeView.backgroundLegibilitySettingsProvider = settingsProvider;

	self.passcodeView.showsEmergencyCallButton = NO;
	self.passcodeView.screenOn = YES;
	self.passcodeView.delegate = self;

	self.passcodeView.frame = [UIScreen mainScreen].bounds;
	self.passcodeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.passcodeWindow addSubview:self.passcodeView];

	Class SBPasscodeBackgroundViewClass = NSClassFromString(@"SBUIBackgroundView") ?: NSClassFromString(@"SBDashBoardBackgroundView");
	SBDashBoardBackgroundView *backgroundView = [[SBPasscodeBackgroundViewClass alloc] initWithFrame:self.passcodeView.bounds];
	backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	backgroundView.backgroundStyle = 3;
	[self.passcodeWindow addSubview:backgroundView];
	[self.passcodeWindow sendSubviewToBack:backgroundView];

	if (iconView) {
		NSString *identifier = [iconView.icon applicationBundleID];
		UIImage *iconImage = [UIImage _applicationIconImageForBundleIdentifier:identifier format:0 scale:[UIScreen mainScreen].scale];
		UIImageView *iconImageView = [[UIImageView alloc] initWithImage:iconImage];
		iconImageView.contentMode = UIViewContentModeScaleAspectFill;
		iconImageView.frame = CGRectMake(0, 0, 40, 40);
		[self.passcodeView _layoutStatusView];
		iconImageView.center = CGPointMake(CGRectGetMidX(self.passcodeWindow.bounds), self.passcodeView.statusTitleView.center.y / 2 - 5);
		[self.passcodeWindow addSubview:iconImageView];
		[self.passcodeWindow bringSubviewToFront:iconImageView];
	}

	self.passcodeWindow.alpha = 0.f;
	[self.passcodeWindow makeKeyAndVisible];
	[self.passcodeView updateStatusText:[bundle localizedStringForKey:@"ENTER_PASS" value:nil table:@"Localizable"] subtitle:nil animated:NO];
	[UIView animateWithDuration:0.15f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
		self.passcodeWindow.alpha = 1.f;
	} completion:nil];
	[self.passcodeView becomeFirstResponder];
}

- (void)passcodeLockViewPasscodeEntered:(SBUIPasscodeLockViewSimpleFixedDigitKeypad *)passcodeView {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		if ([passcodeView.passcode length] == [self.passcode length] && [passcodeView.passcode isEqualToString:self.passcode]) {
			[UIView animateWithDuration:0.15f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
				self.passcodeWindow.alpha = 0.f;
			} completion:^(BOOL finished) {
				if (!finished) {
					return;
				}

				[self.passcodeView removeFromSuperview];
				self.passcodeWindow.hidden = YES;
				self.passcodeView = nil;
				self.passcodeWindow = nil;
				self.eventBlock(YES);
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
		if (!finished) {
			return;
		}

		[self.passcodeView removeFromSuperview];
		self.passcodeWindow.hidden = YES;
		self.passcodeView = nil;
		self.passcodeWindow = nil;
		self.eventBlock(NO);
	}];
}

- (void)dismissPasscodeView {
	if (!self.passcodeWindow) {
		return;
	}

	[UIView animateWithDuration:0.15f delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
		self.passcodeWindow.alpha = 0.f;
	} completion:^(BOOL finished) {
		if (!finished) {
			return;
		}

		[self.passcodeView resignFirstResponder];
		[self.passcodeView removeFromSuperview];
		self.passcodeWindow.hidden = YES;
		self.passcodeView = nil;
		self.passcodeWindow = nil;
		self.eventBlock(NO);
	}];
}

@end
