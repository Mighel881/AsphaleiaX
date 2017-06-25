#import <UIKit/UIKit.h>
#import "ASTouchIDController.h"
#import "ASAuthenticationController.h"
#import "ASCommon.h"
#import "ASPreferences.h"
#import "substrate.h"
#import <AudioToolbox/AudioServices.h>
#import "ASActivatorListener.h"
#import "ASControlPanel.h"
#import "NSTimer+Blocks.h"
#import "ASPasscodeHandler.h"
#import "ASTouchWindow.h"
#import "Asphaleia.h"
#import <rocketbootstrap/rocketbootstrap.h>
#import <AppSupport/CPDistributedMessagingCenter.h>
#import "ASXPCHandler.h"

#define kBundlePath @"/Library/Application Support/Asphaleia/AsphaleiaAssets.bundle"

#define asphaleiaLog() NSLog(@"[Asphaleia] Method called: %@",NSStringFromSelector(_cmd))

SBAppSwitcherIconController *iconController;
NSTimer *currentTempUnlockTimer;
NSTimer *currentTempGlobalDisableTimer;
NCNotificationShortLookViewController *controller;
CPDistributedMessagingCenter *centre;

void RegisterForTouchIDNotifications(id observer, SEL selector) {
	[[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:@"com.a3tweaks.asphaleia.fingerdown" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:@"com.a3tweaks.asphaleia.fingerup" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:@"com.a3tweaks.asphaleia.authsuccess" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:observer selector:selector name:@"com.a3tweaks.asphaleia.authfailed" object:nil];
}

void DeregisterForTouchIDNotifications(id observer) {
	[[NSNotificationCenter defaultCenter] removeObserver:observer];
}

@interface ASPreferences ()
@property (readwrite) BOOL asphaleiaDisabled;
@property (readwrite) BOOL itemSecurityDisabled;
@end

%hook SBIconController
- (void)iconTapped:(SBIconView *)iconView {
	BOOL isProtected = [[ASAuthenticationController sharedInstance] authenticateAppWithIconView:iconView authenticatedHandler:^void(BOOL wasCancelled){
		if (!wasCancelled) {
			if (IS_IOS_OR_NEWER(iOS_8_3)) {
				[iconView.icon launchFromLocation:iconView.location context:nil];
			} else {
				[iconView.icon launchFromLocation:iconView.location];
			}
		}
	}];

	if (!isProtected) {
		%orig;
	}
}

- (void)iconHandleLongPress:(SBIconView *)iconView withFeedbackBehavior:(id)arg2 {
	if (self.isEditing || ![[ASPreferences sharedInstance] secureAppArrangement]) {
		%orig;
		return;
	}

	[iconView setHighlighted:NO];
	[iconView cancelLongPressTimer];
	[iconView setTouchDownInIcon:NO];

	[[ASAuthenticationController sharedInstance] authenticateFunction:ASAuthenticationAlertAppArranging dismissedHandler:^(BOOL wasCancelled) {
		if (!wasCancelled) {
			[self setIsEditing:YES];
		}
	}];
}

%new
- (void)asphaleia_resetAsphaleiaIconView {
	if ([ASAuthenticationController sharedInstance].fingerglyph && [ASAuthenticationController sharedInstance].currentHSIconView) {
		[[ASAuthenticationController sharedInstance].currentHSIconView _updateLabel];

		[UIView animateWithDuration:0.3f animations:^{
			[ASAuthenticationController sharedInstance].fingerglyph.transform = CGAffineTransformMakeScale(0.01,0.01);
		}];
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
			[[ASAuthenticationController sharedInstance].currentHSIconView setHighlighted:NO];
			CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.a3tweaks.asphaleia.stopmonitoring"), NULL, NULL, YES);

			[[ASAuthenticationController sharedInstance].fingerglyph removeFromSuperview];
			[ASAuthenticationController sharedInstance].fingerglyph.transform = CGAffineTransformMakeScale(1,1);
			[[ASAuthenticationController sharedInstance].fingerglyph setState:0 animated:YES completionHandler:nil];

			[[ASAuthenticationController sharedInstance].currentHSIconView _updateLabel];

			[ASAuthenticationController sharedInstance].currentHSIconView = nil;
			[[ASAuthenticationController sharedInstance].anywhereTouchWindow setHidden:YES];
		});
	}
}
%end

%hook SBIconView
%new
- (void)asphaleia_updateLabelWithText:(NSString *)text {
	SBIconLabelView *iconLabelView = MSHookIvar<SBIconLabelView *>(self,"_labelView");

	SBIconLabelImageParameters *imageParameters = [[iconLabelView imageParameters] mutableCopy];
	[imageParameters setText:text];
	[%c(SBIconLabelView) updateIconLabelView:iconLabelView withSettings:nil imageParameters:imageParameters];
}
%end

%hook SBAppSwitcherIconController
- (id)init {
	iconController = %orig;
	return iconController;
}
%end

%hook SBAppSwitcherSnapshotView
%property (nonatomic, retain) UIView *obscurityView;

- (void)_layoutStatusBar {
	if (![[ASPreferences sharedInstance] requiresSecurityForApp:self.displayItem.displayIdentifier] || ![[ASPreferences sharedInstance] obscureAppContent]) {
		%orig;
	}
}

- (void)prepareToBecomeVisibleIfNecessary {
	%orig;
	if (![[ASPreferences sharedInstance] requiresSecurityForApp:self.displayItem.displayIdentifier] || ![[ASPreferences sharedInstance] obscureAppContent]) {
		return;
	}

	CAFilter* filter = [CAFilter filterWithName:@"gaussianBlur"];
	[filter setValue:@10 forKey:@"inputRadius"];
	UIView *snapshotImageView = MSHookIvar<UIView *>(self,"_containerView");
	snapshotImageView.layer.filters = [NSArray arrayWithObject:filter];

	NSBundle *asphaleiaAssets = [[NSBundle alloc] initWithPath:kBundlePath];
	UIImage *obscurityEye = [UIImage imageNamed:@"unocme.png" inBundle:asphaleiaAssets compatibleWithTraitCollection:nil];

	UIView *obscurityView = [[UIView alloc] initWithFrame:self.bounds];
	obscurityView.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.7f];

	UIImageView *imageView = [[UIImageView alloc] init];
	imageView.image = obscurityEye;
	imageView.frame = CGRectMake(0, 0, obscurityEye.size.width*2, obscurityEye.size.height*2);
	imageView.center = obscurityView.center;
	[obscurityView addSubview:imageView];

	obscurityView.tag = 80085; // ;)

	[self addSubview:obscurityView];
	self.obscurityView = obscurityView;
}

- (void)respondToBecomingInvisibleIfNecessary {
	self.layer.filters = nil;
	UIView *obscurityView = self.obscurityView;
	if (obscurityView) {
		[obscurityView removeFromSuperview];
	}

	self.obscurityView = nil;
	%orig;
}
%end

%hook SBUIController
- (BOOL)handleHomeButtonSinglePressUp {
	if (![[ASAuthenticationController sharedInstance] currentAuthAlert]) {
		return %orig;
	}

	return NO;
}
%end

%hook SBMainSwitcherViewController
BOOL switcherAuthenticating;

- (BOOL)isVisible {
	if (switcherAuthenticating) {
		return YES;
	} else {
		return %orig;
	}
}

- (BOOL)activateSwitcherNoninteractively {
		//Semi works so whatever
		BOOL orig = %orig;
		if (![[ASPreferences sharedInstance] secureSwitcher] || switcherAuthenticating) {
				return orig;
		}

		switcherAuthenticating = YES;
		BOOL authenticated = [[ASAuthenticationController sharedInstance] authenticateFunction:ASAuthenticationAlertSwitcher dismissedHandler:^(BOOL wasCancelled) {
				switcherAuthenticating = NO;
				if (wasCancelled) {
						[self dismissSwitcherNoninteractively];
				}
		}];

		return authenticated;
}

%end


%hook SBLockScreenManager
UIWindow *blurredWindow;

- (void)_lockUI {
	[ASXPCHandler sharedInstance].slideUpControllerActive = NO;
	[[ASTouchIDController sharedInstance] stopMonitoring];
	[[%c(SBIconController) sharedInstance] asphaleia_resetAsphaleiaIconView];
	[[ASAuthenticationController sharedInstance] dismissAnyAuthenticationAlerts];
	[[ASPasscodeHandler sharedInstance] dismissPasscodeView];
	%orig;
	if ([[ASPreferences sharedInstance] resetAppExitTimerOnLock] && currentTempUnlockTimer) {
		[currentTempUnlockTimer fire];
		[currentTempGlobalDisableTimer fire];
	}
}

- (void)_finishUIUnlockFromSource:(int)source withOptions:(id)options {
	%orig;
	if ([[ASPreferences sharedInstance] delayAppSecurity]) {
		[ASPreferences sharedInstance].itemSecurityDisabled = YES;
		currentTempGlobalDisableTimer = [NSTimer scheduledTimerWithTimeInterval:[[ASPreferences sharedInstance] appSecurityDelayTime] block:^{
			[ASPreferences sharedInstance].itemSecurityDisabled = NO;
		} repeats:NO];
		return;
	}

	SBApplication *frontmostApp = [(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
	if ([[ASPreferences sharedInstance] requiresSecurityForApp:[frontmostApp bundleIdentifier]] && ![[ASPreferences sharedInstance] unlockToAppUnsecurely] && frontmostApp && !blurredWindow) {
		blurredWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		blurredWindow.backgroundColor = [UIColor clearColor];

		UIVisualEffect *blurEffect;
		blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];

		UIVisualEffectView *visualEffectView;
		visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];

		visualEffectView.frame = [[UIScreen mainScreen] bounds];

		blurredWindow.windowLevel = UIWindowLevelAlert-1;
		[blurredWindow addSubview:visualEffectView];
		[blurredWindow makeKeyAndVisible];
	}
}
/* Not sure what this is for but It breaks unlocks from notifications
- (void)unlockUIFromSource:(NSInteger)source withOptions:(id)options {
	HBLogDebug(@"unlockUIFromSource:%zd", source);
	if (source != 14 || ![[ASTouchIDController sharedInstance] shouldBlockLockscreenMonitor] || ![[ASTouchIDController sharedInstance] isMonitoring]) {
		HBLogDebug(@"running orig");
		%orig;
	}
}
*/
%end

%hook SBDashBoardViewController
- (void)viewDidDisappear:(BOOL)animated {
	%orig;

	SBApplication *frontmostApp = [(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
	if ([[ASPreferences sharedInstance] requiresSecurityForApp:[frontmostApp bundleIdentifier]] && ![[ASPreferences sharedInstance] unlockToAppUnsecurely] && frontmostApp && ![ASAuthenticationController sharedInstance].catchAllIgnoreRequest) {

		[[ASAuthenticationController sharedInstance] authenticateAppWithDisplayIdentifier:[frontmostApp bundleIdentifier] customMessage:nil dismissedHandler:^(BOOL wasCancelled) {
			if (blurredWindow) {
				blurredWindow.hidden = YES;
				blurredWindow = nil;
			}

			if (wasCancelled) {
				[(SpringBoard *)[UIApplication sharedApplication] _handleGotoHomeScreenShortcut:nil];
			}
		}];
	}
}
%end

%hook SPUISearchHeader
static BOOL searchControllerHasAuthenticated;
static BOOL searchControllerAuthenticating;

- (void)focusSearchField {
	%orig;
	if (!searchControllerHasAuthenticated && !searchControllerAuthenticating && [[ASPreferences sharedInstance] secureSpotlight]) {
		[self unfocusSearchField];
		[[ASAuthenticationController sharedInstance] authenticateFunction:ASAuthenticationAlertSpotlight dismissedHandler:^(BOOL wasCancelled) {
		searchControllerAuthenticating = NO;
		if (!wasCancelled) {
			searchControllerHasAuthenticated = YES;
			[self focusSearchField];
		}
		}];
		searchControllerAuthenticating = YES;
	}
}

-(void)unfocusSearchField {
	searchControllerHasAuthenticated = NO;
	searchControllerAuthenticating = NO;
	%orig;
}
%end

%hook SBPowerDownController
- (void)orderFront {
	if (![[ASPreferences sharedInstance] securePowerDownView]) {
		%orig;
		return;
	}

	[[ASTouchIDController sharedInstance] setShouldBlockLockscreenMonitor:YES];
	[[ASAuthenticationController sharedInstance] authenticateFunction:ASAuthenticationAlertPowerDown dismissedHandler:^(BOOL wasCancelled) {
	[[ASTouchIDController sharedInstance] setShouldBlockLockscreenMonitor:NO];
	if (!wasCancelled)
		%orig;
	}];
}
%end

%hook SBControlCenterController
static BOOL controlCentreAuthenticating;
static BOOL controlCentreHasAuthenticated;

- (void)presentAnimated:(BOOL)animated completion:(id)completion {
	if (controlCentreAuthenticating) {
		return;
	}

	if (![[ASPreferences sharedInstance] secureControlCentre] || controlCentreHasAuthenticated) {
		%orig;
		return;
	}

	controlCentreAuthenticating = YES;
	[[ASTouchIDController sharedInstance] setShouldBlockLockscreenMonitor:YES];
	[[ASAuthenticationController sharedInstance] authenticateFunction:ASAuthenticationAlertControlCentre dismissedHandler:^(BOOL wasCancelled) {
	controlCentreAuthenticating = NO;
	[[ASTouchIDController sharedInstance] setShouldBlockLockscreenMonitor:NO];
	if (!wasCancelled) {
		controlCentreHasAuthenticated = YES;
		%orig;
	}
	}];
}

- (void)_beginTransitionWithTouchLocation:(CGPoint)touchLocation {
	if (![[ASPreferences sharedInstance] secureControlCentre] || controlCentreHasAuthenticated || controlCentreAuthenticating) {
		%orig;
		return;
	}

	controlCentreAuthenticating = YES;
	[[ASTouchIDController sharedInstance] setShouldBlockLockscreenMonitor:YES];
	[[ASAuthenticationController sharedInstance] authenticateFunction:ASAuthenticationAlertControlCentre dismissedHandler:^(BOOL wasCancelled) {
	controlCentreAuthenticating = NO;
	[[ASTouchIDController sharedInstance] setShouldBlockLockscreenMonitor:NO];
	if (!wasCancelled) {
		controlCentreHasAuthenticated = YES;
		[self presentAnimated:YES];
	}
	}];
}

- (void)_endPresentation {
	controlCentreHasAuthenticated = NO;
	controlCentreAuthenticating = NO;
	%orig;
}
%end

%hook SBApplication
- (void)willAnimateDeactivation:(BOOL)deactivation {
	%orig;
	if (![[ASPreferences sharedInstance] requiresSecurityForApp:[self bundleIdentifier]]) {
		return;
	}
	if (currentTempUnlockTimer) {
		[currentTempUnlockTimer fire];
	}

	if ([[ASPreferences sharedInstance] appExitUnlockTime] <= 0) {
		return;
	}

	[ASAuthenticationController sharedInstance].temporarilyUnlockedAppBundleID = [self bundleIdentifier];
	currentTempUnlockTimer = [NSTimer scheduledTimerWithTimeInterval:[[ASPreferences sharedInstance] appExitUnlockTime] block:^{
		[ASAuthenticationController sharedInstance].temporarilyUnlockedAppBundleID = nil;
		currentTempUnlockTimer = nil;
	} repeats:NO];
}
%end

%hook SpringBoard
static BOOL openURLHasAuthenticated;

- (void)_openURLCore:(id)core display:(id)display animating:(BOOL)animating sender:(id)sender activationSettings:(id)settings withResult:(id)result {
	%orig;
	openURLHasAuthenticated = NO;
}

- (void)_applicationOpenURL:(id)url withApplication:(id)application sender:(id)sender publicURLsOnly:(BOOL)publicURL animating:(BOOL)animating activationSettings:(id)settings withResult:(id)result {
	asphaleiaLog();
	if (![[ASPreferences sharedInstance] requiresSecurityForApp:[application bundleIdentifier]] || openURLHasAuthenticated || [[ASAuthenticationController sharedInstance].appUserAuthorisedID isEqualToString:[application bundleIdentifier]] || !publicURL) {
		%orig;
		return;
	}
	if (result) {
		[result invoke];
	}

	[ASAuthenticationController sharedInstance].catchAllIgnoreRequest = YES;
	if ([[settings description] containsString:@"fromLocked = BSSettingFlagYes"]) {
		SBApplication *frontmostApp = [(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
		if ([[ASPreferences sharedInstance] unlockToAppUnsecurely] && [[ASPreferences sharedInstance] requiresSecurityForApp:[frontmostApp bundleIdentifier]])
			return;
	}

	[[ASAuthenticationController sharedInstance] authenticateAppWithDisplayIdentifier:[application bundleIdentifier] customMessage:nil dismissedHandler:^(BOOL wasCancelled) {
			if (!wasCancelled) {
				if (blurredWindow && [[settings description] containsString:@"fromLocked = BSSettingFlagYes"]) {
					blurredWindow.hidden = YES;
					blurredWindow = nil;
				}
				// using %orig; crashes springboard, so this is my alternative.
				openURLHasAuthenticated = YES;
				[self applicationOpenURL:url];
			}
		}];
}
%end

%hook NCNotificationShortLookViewController
UIVisualEffectView *notificationBlurView;
PKGlyphView *bannerFingerGlyph;
BOOL currentBannerAuthenticated;
NSString *bundleIdentifier;

- (instancetype)_initWithNotificationRequest:(NCNotificationRequest*)request revealingAdditionalContentOnPresentation:(BOOL)arg2 {
	controller = %orig;
	RegisterForTouchIDNotifications(controller, @selector(receiveTouchIDNotification:));
	bundleIdentifier = request.sectionIdentifier;
	return controller;
}

- (void)viewWillLayoutSubviews {
	%orig;

	currentBannerAuthenticated = NO;

	if (![[ASPreferences sharedInstance] requiresSecurityForApp:bundleIdentifier] || ![[ASPreferences sharedInstance] obscureNotifications]) {
		return;
	}

	UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
	notificationBlurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
	notificationBlurView.frame = [self _notificationShortLookViewIfLoaded].frame;
	notificationBlurView.userInteractionEnabled = NO;
	[[self _notificationShortLookViewIfLoaded] addSubview:notificationBlurView];

	SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:bundleIdentifier];
	SBApplicationIcon *appIcon = [[%c(SBApplicationIcon) alloc] initWithApplication:application];
	SBIconView *iconView = [[%c(SBIconView) alloc] initWithContentType:0];
	[iconView _setIcon:appIcon animated:YES];
	UIImage *iconImage = [iconView.icon getIconImage:2];
	UIImageView *imgView = [[UIImageView alloc] initWithImage:iconImage];
	imgView.frame = CGRectMake(0,0,notificationBlurView.frame.size.height-20,notificationBlurView.frame.size.height-20);
	imgView.center = CGPointMake(imgView.frame.size.width/2+10,CGRectGetMidY(notificationBlurView.bounds));
	[notificationBlurView.contentView addSubview:imgView];

	NSString *displayName = [application displayName];
	UILabel *appNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	appNameLabel.textColor = [UIColor whiteColor];
	appNameLabel.text = displayName;
	[appNameLabel sizeToFit];
	appNameLabel.center = CGPointMake(10+imgView.frame.size.width+10+appNameLabel.frame.size.width/2,CGRectGetMidY(notificationBlurView.bounds));
	[notificationBlurView.contentView addSubview:appNameLabel];

	if (![[ASPreferences sharedInstance] touchIDEnabled]) {
		UILabel *authPassLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		authPassLabel.text = @"Tap to show";
		[authPassLabel sizeToFit];
		authPassLabel.center = notificationBlurView.contentView.center;
		CGRect frame = authPassLabel.frame;
		frame.origin.x = notificationBlurView.frame.size.width - frame.size.width - 10;
		authPassLabel.frame = frame;
		authPassLabel.textColor = [UIColor whiteColor];
		[notificationBlurView.contentView addSubview:authPassLabel];
		return;
	}

	if (!bannerFingerGlyph) {
		bannerFingerGlyph = [(PKGlyphView*)[%c(PKGlyphView) alloc] initWithStyle:1];
		bannerFingerGlyph.secondaryColor = [UIColor grayColor];
		bannerFingerGlyph.primaryColor = [UIColor redColor];
	}
	CGRect fingerframe = bannerFingerGlyph.frame;
	fingerframe.size.height = notificationBlurView.frame.size.height-20;
	fingerframe.size.width = notificationBlurView.frame.size.height-20;
	bannerFingerGlyph.frame = fingerframe;
	bannerFingerGlyph.center = CGPointMake(notificationBlurView.bounds.size.width-fingerframe.size.height/2-10,CGRectGetMidY(notificationBlurView.bounds));
	[notificationBlurView.contentView addSubview:bannerFingerGlyph];
	[bannerFingerGlyph setState:0 animated:YES completionHandler:nil];

	[[ASTouchIDController sharedInstance] startMonitoring];
}

- (void)_handleTapOnView:(id)arg1 {
	if (![[ASPreferences sharedInstance] requiresSecurityForApp:bundleIdentifier] || currentBannerAuthenticated || ![[ASPreferences sharedInstance] obscureNotifications]) {
		%orig;
	} else {
		[[ASTouchIDController sharedInstance] stopMonitoring];
		[[ASPasscodeHandler sharedInstance] showInKeyWindowWithPasscode:[[ASPreferences sharedInstance] getPasscode] iconView:nil eventBlock:^void(BOOL authenticated){
			if (authenticated) {
				if (notificationBlurView) {
					currentBannerAuthenticated = YES;
					[ASAuthenticationController sharedInstance].appUserAuthorisedID = bundleIdentifier;
					[UIView animateWithDuration:0.3f animations:^{
						[notificationBlurView setAlpha:0.0f];
					} completion:^(BOOL finished){
						if (finished && bannerFingerGlyph) {
							[bannerFingerGlyph setState:0 animated:NO completionHandler:nil];
						}
					}];
				}
			} else {
				if ([[%c(SBBannerController) sharedInstance] isShowingBanner] && [[ASPreferences sharedInstance] touchIDEnabled]) {
					[[ASTouchIDController sharedInstance] startMonitoring];
				}
			}
		}];
	}
}

- (void)viewDidDisappear:(BOOL)animated {
	%orig;
	currentBannerAuthenticated = NO;
	[ASAuthenticationController sharedInstance].appUserAuthorisedID = nil;

	if (![[%c(SBBannerController) sharedInstance] isShowingBanner]) {
		[[ASTouchIDController sharedInstance] stopMonitoring];
	}

	if (bannerFingerGlyph) {
		[bannerFingerGlyph setState:0 animated:NO completionHandler:nil];
	}

	if (notificationBlurView) {
		[notificationBlurView removeFromSuperview];
		notificationBlurView = nil;
	}
}

%new
- (void)receiveTouchIDNotification:(NSNotification *)notification {
	if ([[notification object] isKindOfClass:NSClassFromString(@"BiometricKitIdentity")]) {
		if (![[ASPreferences sharedInstance] fingerprintProtectsSecureItems:[[notification object] name]]) {
			if (bannerFingerGlyph) {
				[bannerFingerGlyph setState:0 animated:YES completionHandler:nil];
			}
			if ([[ASPreferences sharedInstance] vibrateOnIncorrectFingerprint]) {
				AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
			}
			return;
		}
	}
	if ([[notification name] isEqualToString:@"com.a3tweaks.asphaleia.fingerdown"]) {
		if (bannerFingerGlyph) {
			[bannerFingerGlyph setState:1 animated:YES completionHandler:nil];
		}
	} else if ([[notification name] isEqualToString:@"com.a3tweaks.asphaleia.fingerup"]) {
		if (bannerFingerGlyph) {
			[bannerFingerGlyph setState:0 animated:YES completionHandler:nil];
		}
	} else if ([[notification name] isEqualToString:@"com.a3tweaks.asphaleia.authsuccess"]) {
		if (bannerFingerGlyph && notificationBlurView) {
			currentBannerAuthenticated = YES;
			[ASAuthenticationController sharedInstance].appUserAuthorisedID = bundleIdentifier;
			[[ASTouchIDController sharedInstance] stopMonitoring];
			[UIView animateWithDuration:0.3f animations:^{
				[notificationBlurView setAlpha:0.0f];
			} completion:^(BOOL finished){
				if (finished) {
					[bannerFingerGlyph setState:0 animated:NO completionHandler:nil];
				}
			}];
		}
	} else if ([[notification name] isEqualToString:@"com.a3tweaks.asphaleia.authfailed"]) {
		if (bannerFingerGlyph) {
			[bannerFingerGlyph setState:0 animated:YES completionHandler:nil];
		}
	}
}
%end

%hook SBBannerController
- (BOOL)gestureRecognizerShouldBegin:(id)gestureRecognizer {
	if (![[ASPreferences sharedInstance] requiresSecurityForApp:bundleIdentifier] || currentBannerAuthenticated || ![[ASPreferences sharedInstance] obscureNotifications]) {
		return %orig;
	} else {
		return NO;
	}
}
%end

%hook SBMainWorkspace
- (void)setCurrentTransaction:(id)transaction {
	asphaleiaLog();
	if (![transaction isKindOfClass:%c(SBAppToAppWorkspaceTransaction)] || [transaction isKindOfClass:%c(SBRotateScenesWorkspaceTransaction)]) {
		%orig;
		return;
	}

	NSArray *activatingApplications = [transaction activatingApplications];
	if (activatingApplications.count == 0) {
		%orig;
		return;
	}
	SBApplication *application = [activatingApplications[0] application];
	if (![[ASPreferences sharedInstance] requiresSecurityForApp:[application bundleIdentifier]] ||
		[[ASAuthenticationController sharedInstance].appUserAuthorisedID isEqualToString:[application bundleIdentifier]] ||
		[ASAuthenticationController sharedInstance].catchAllIgnoreRequest ||
		![application bundleIdentifier]) {

		[ASAuthenticationController sharedInstance].appUserAuthorisedID = nil;
		[ASAuthenticationController sharedInstance].catchAllIgnoreRequest = NO;
		%orig;
		return;
	}

	[ASAuthenticationController sharedInstance].appUserAuthorisedID = nil;

	SBApplicationIcon *appIcon = [[%c(SBApplicationIcon) alloc] initWithApplication:application];
	SBIconView *iconView = [[%c(SBIconView) alloc] initWithContentType:0];
	[iconView _setIcon:appIcon animated:YES];

	[[ASAuthenticationController sharedInstance] authenticateAppWithDisplayIdentifier:application.bundleIdentifier customMessage:nil dismissedHandler:^(BOOL wasCancelled) {
		[ASAuthenticationController sharedInstance].appUserAuthorisedID = nil;
		if (!wasCancelled) {
			%orig;
		}
	}];
}
%end

%hook SBLockScreenSlideUpToAppController
- (void)beginPresentationWithTouchLocation:(CGPoint)touchLocation {
	%orig;
	[ASXPCHandler sharedInstance].slideUpControllerActive = YES;
}

- (void)_activateApp:(id)app withAppInfo:(id)appInfo andURL:(id)url animated:(BOOL)animated {
	if (![[ASPreferences sharedInstance] requiresSecurityForApp:[app bundleIdentifier]]) {
		%orig;
		return;
	}

	[[ASTouchIDController sharedInstance] setShouldBlockLockscreenMonitor:YES];
	[[ASAuthenticationController sharedInstance] authenticateAppWithDisplayIdentifier:[app bundleIdentifier] customMessage:nil dismissedHandler:^(BOOL wasCancelled) {
			[[ASTouchIDController sharedInstance] setShouldBlockLockscreenMonitor:NO];
			if (!wasCancelled) {
				[ASAuthenticationController sharedInstance].catchAllIgnoreRequest = YES;
				%orig;
			} else {
				[self _finishSlideDownWithCompletion:nil];
			}
		}];
}

- (void)_handleAppLaunchedUnderLockScreenWithResult:(int)result {
	SBApplication *app = MSHookIvar<SBApplication *>(self, "_targetApp");
	if (![[ASPreferences sharedInstance] requiresSecurityForApp:[app bundleIdentifier]]) {
		%orig;
	}
}
%end

%hook FSSwitchMainPanel
BOOL currentSwitchAuthenticated;

- (void)setState:(int)arg1 forSwitchIdentifier:(NSString *)identifier {
	if (![[ASPreferences sharedInstance] requiresSecurityForSwitch:identifier]) {
		%orig;
		return;
	}

	[[ASTouchIDController sharedInstance] setShouldBlockLockscreenMonitor:YES];
	[[ASCommon sharedInstance] authenticateFunction:ASAuthenticationAlertFlipswitch dismissedHandler:^(BOOL wasCancelled){
		[[ASTouchIDController sharedInstance] setShouldBlockLockscreenMonitor:NO];
		if (!wasCancelled) {
			%orig;
			currentSwitchAuthenticated = YES;
		}
	}];
}
- (void)applyActionForSwitchIdentifier:(NSString *)identifier {
	if (![[ASPreferences sharedInstance] requiresSecurityForSwitch:identifier]) {
		%orig;
		return;
	}

	if (currentSwitchAuthenticated) {
		%orig;
		currentSwitchAuthenticated = NO;
		return;
	}

	[[ASTouchIDController sharedInstance] setShouldBlockLockscreenMonitor:YES];
	[[ASCommon sharedInstance] authenticateFunction:ASAuthenticationAlertFlipswitch dismissedHandler:^(BOOL wasCancelled){
		[[ASTouchIDController sharedInstance] setShouldBlockLockscreenMonitor:NO];
		if (!wasCancelled) {
			%orig;
		}
	}];
}
- (void)applyAlternateActionForSwitchIdentifier:(NSString *)identifier {
	if (![[ASPreferences sharedInstance] requiresSecurityForSwitch:identifier]) {
		%orig;
		return;
	}

	if (currentSwitchAuthenticated) {
		%orig;
		currentSwitchAuthenticated = NO;
		return;
	}

	[[ASTouchIDController sharedInstance] setShouldBlockLockscreenMonitor:YES];
	[[ASCommon sharedInstance] authenticateFunction:ASAuthenticationAlertFlipswitch dismissedHandler:^(BOOL wasCancelled){
		[[ASTouchIDController sharedInstance] setShouldBlockLockscreenMonitor:NO];
		if (!wasCancelled) {
			%orig;
		}
	}];
}

%end

%ctor {
	if (!IN_SPRINGBOARD) {
		HBLogWarn(@"[Asphaleia] Attempting to load into non-SpringBoard process. Stop.");
		return;
	}

	dlopen("/Library/MobileSubstrate/DynamicLibraries/Flipswitch.dylib", RTLD_NOW);
	loadPreferences();
	[[ASControlPanel sharedInstance] load];
	[[ASActivatorListener sharedInstance] load];
	%init;
}
