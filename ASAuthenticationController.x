#import "ASAuthenticationController.h"
#include <sys/sysctl.h>
#import <objc/runtime.h>
#import <AudioToolbox/AudioServices.h>
#import "ASPreferences.h"
#import "ASPasscodeHandler.h"

static NSString *const ASBundlePath = @"/Library/Application Support/Asphaleia/AsphaleiaAssets.bundle";
#define titleWithSpacingForIcon(t) [NSString stringWithFormat:@"\n\n\n%@",t]
#define titleWithSpacingForSmallIcon(t) [NSString stringWithFormat:@"\n\n%@",t]

static NSBundle *bundle;

@implementation ASAuthenticationController

+ (instancetype)sharedInstance {
    static ASAuthenticationController *sharedInstance = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedInstance = [[self alloc] init]; 
    });

    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self registerForTouchIDNotifications];
        bundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/AsphaleiaPrefs.bundle"];
    }

    return self;
}

- (void)registerForTouchIDNotifications {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(receivedNotification:) name:@"com.a3tweaks.asphaleia.fingerdown" object:nil];
	[center addObserver:self selector:@selector(receivedNotification:) name:@"com.a3tweaks.asphaleia.fingerup" object:nil];
	[center addObserver:self selector:@selector(receivedNotification:) name:@"com.a3tweaks.asphaleia.authsuccess" object:nil];
	[center addObserver:self selector:@selector(receivedNotification:) name:@"com.a3tweaks.asphaleia.authfailed" object:nil];
}

- (void)receivedNotification:(NSNotification *)notification {
    NSString *name = notification.name;
    id fingerprint = [[ASTouchIDController sharedInstance] lastMatchedFingerprint];

    if (!self.currentHSIconView) {
        return;
    }

    if ([fingerprint isKindOfClass:%c(BiometricKitIdentity)]) {
        if (![[ASPreferences sharedInstance] fingerprintProtectsSecureItems:[fingerprint name]]) {
            name = @"com.a3tweaks.asphaleia.authfailed";
        }
    }

    if (!IN_SPRINGBOARD) {
        return;
    }

    if ([name isEqualToString:@"com.a3tweaks.asphaleia.fingerdown"]) {
        if (_fingerglyph && _currentHSIconView) {
            [_fingerglyph setState:1 animated:YES completionHandler:nil];
            [_currentHSIconView asphaleia_updateLabelWithText:@"Scanning..."];
        }
    } else if ([name isEqualToString:@"com.a3tweaks.asphaleia.fingerup"]) {
        if (_fingerglyph) {
            [_fingerglyph setState:0 animated:YES completionHandler:nil];
        }
    } else if ([name isEqualToString:@"com.a3tweaks.asphaleia.authsuccess"]) {
        if (_fingerglyph && _currentHSIconView) {
            [ASAuthenticationController sharedInstance].appUserAuthorisedID = currentAuthAppBundleID;
            [_currentHSIconView.icon launchFromLocation:_currentHSIconView.location context:nil];
            [[%c(SBIconController) sharedInstance] asphaleia_resetAsphaleiaIconView];
            currentAuthAppBundleID = nil;
        }
    } else if ([name isEqualToString:@"com.a3tweaks.asphaleia.authfailed"]) {
        if (_fingerglyph && _currentHSIconView) {
            [_fingerglyph setState:0 animated:YES completionHandler:nil];
            [_currentHSIconView asphaleia_updateLabelWithText:@"Scan finger..."];
        }
    }
}

- (ASAuthenticationAlert *)returnAppAuthenticationAlertWithApplication:(NSString *)appIdentifier customMessage:(NSString *)customMessage delegate:(id<ASAuthenticationAlertDelegate>)delegate {
    NSString *message;
    if (customMessage) {
      message = customMessage;
    } else {
      message = [bundle localizedStringForKey:@"SCAN_FINGER_OPEN" value:nil table:@"Localizable"];
    }

    ASAuthenticationAlert *alertView = [[ASAuthenticationAlert alloc] initWithApplication:appIdentifier message:message delegate:delegate];
    alertView.tag = ASAuthenticationItem;

    currentAuthAppBundleID = appIdentifier;

    return alertView;
}

- (ASAuthenticationAlert *)returnAuthenticationAlertOfType:(ASAuthenticationAlertType)alertType delegate:(id<ASAuthenticationAlertDelegate>)delegate {
    NSBundle *asphaleiaAssets = [NSBundle bundleWithPath:ASBundlePath];

    NSString *title;
    UIImage *iconImage;
    NSInteger tag;
    switch (alertType) {
        case ASAuthenticationAlertAppArranging: {
            title = [bundle localizedStringForKey:@"ARRANGE_APPS" value:nil table:@"Localizable"];
            iconImage = [UIImage imageNamed:@"IconEditMode.png" inBundle:asphaleiaAssets compatibleWithTraitCollection:nil];
            tag = ASAuthenticationFunction;
            break;
        }
        case ASAuthenticationAlertSwitcher: {
            title = [bundle localizedStringForKey:@"MULTITASKING" value:nil table:@"Localizable"];
            iconImage = [UIImage imageNamed:@"IconMultitasking.png" inBundle:asphaleiaAssets compatibleWithTraitCollection:nil];
            tag = ASAuthenticationFunction;
            break;
        }
        case ASAuthenticationAlertSpotlight: {
            title = [bundle localizedStringForKey:@"SPOTLIGHT" value:nil table:@"Localizable"];
            iconImage = [UIImage imageNamed:@"IconSpotlight.png" inBundle:asphaleiaAssets compatibleWithTraitCollection:nil];
            tag = ASAuthenticationFunction;
            break;
        }
        case ASAuthenticationAlertPowerDown: {
            title = [bundle localizedStringForKey:@"SLIDE_TO_POWER_OFF" value:nil table:@"Localizable"];
            iconImage = [UIImage imageNamed:@"IconPowerOff.png" inBundle:asphaleiaAssets compatibleWithTraitCollection:nil];
            tag = ASAuthenticationFunction;
            break;
        }
        case ASAuthenticationAlertControlCentre: {
            title = [bundle localizedStringForKey:@"CONTROL_CENTER" value:nil table:@"Localizable"];
            iconImage = [UIImage imageNamed:@"IconControlCenter.png" inBundle:asphaleiaAssets compatibleWithTraitCollection:nil];
            tag = ASAuthenticationFunction;
            break;
        }
        case ASAuthenticationAlertControlPanel: {
            title = [bundle localizedStringForKey:@"CONTROL_PANEL" value:nil table:@"Localizable"];
            iconImage = [UIImage imageNamed:@"IconDefault.png" inBundle:asphaleiaAssets compatibleWithTraitCollection:nil];
            tag = ASAuthenticationSecurityMod;
            break;
        }
        case ASAuthenticationAlertDynamicSelection: {
            title = [bundle localizedStringForKey:@"DYNAMIC_SELECTION" value:nil table:@"Localizable"];
            iconImage = [UIImage imageNamed:@"IconDefault.png" inBundle:asphaleiaAssets compatibleWithTraitCollection:nil];
            tag = ASAuthenticationSecurityMod;
            break;
        }
        case ASAuthenticationAlertPhotos: {
            title = [bundle localizedStringForKey:@"PHOTO_LIBRARY" value:nil table:@"Localizable"];
            iconImage = [UIImage imageNamed:@"IconDefault.png" inBundle:asphaleiaAssets compatibleWithTraitCollection:nil];
            tag = ASAuthenticationFunction;
            break;
        }
        case ASAuthenticationAlertSettingsPanel: {
            title = [bundle localizedStringForKey:@"SETTINGS_PANEL" value:nil table:@"Localizable"];
            iconImage = [UIImage imageNamed:@"IconDefault.png" inBundle:asphaleiaAssets compatibleWithTraitCollection:nil];
            tag = ASAuthenticationItem;
            break;
        }
        case ASAuthenticationAlertFlipswitch: {
            title = [bundle localizedStringForKey:@"FLIPSWITCH" value:nil table:@"Localizable"];
            iconImage = [UIImage imageNamed:@"IconDefault.png" inBundle:asphaleiaAssets compatibleWithTraitCollection:nil];
            tag = ASAuthenticationItem;
            break;
        }
        default: {
            title = [bundle localizedStringForKey:@"ASPHALEIA" value:nil table:@"Localizable"];
            iconImage = [UIImage imageNamed:@"IconDefault.png" inBundle:asphaleiaAssets compatibleWithTraitCollection:nil];
            tag = ASAuthenticationFunction;
            break;
        }
    }

    UIImageView *imgView = [[UIImageView alloc] initWithImage:iconImage];
    imgView.frame = CGRectMake(0,0,iconImage.size.width,iconImage.size.height);

    ASAuthenticationAlert *alertView = [[ASAuthenticationAlert alloc] initWithTitle:title message:[bundle localizedStringForKey:@"SCAN_FINGER_ACCESS" value:nil table:@"Localizable"] icon:imgView smallIcon:YES delegate:delegate];
    alertView.tag = tag;

    return alertView;
}

- (BOOL)authenticateAppWithDisplayIdentifier:(NSString *)appIdentifier customMessage:(NSString *)customMessage dismissedHandler:(ASCommonAuthenticationHandler)handler {
    [[%c(SBIconController) sharedInstance] asphaleia_resetAsphaleiaIconView];

    if (![[ASPreferences sharedInstance] requiresSecurityForApp:appIdentifier]) {
        return NO;
    }

    authHandler = [handler copy];

    ASAuthenticationAlert *alertView = [self returnAppAuthenticationAlertWithApplication:appIdentifier customMessage:customMessage delegate:self];

    if (![[ASPreferences sharedInstance] touchIDEnabled] && ![[ASPreferences sharedInstance] passcodeEnabled]) {
        return NO;
    }

    if (![[ASPreferences sharedInstance] touchIDEnabled] || [[ASPreferences sharedInstance] securityLevelForApp:appIdentifier] == 0) {
        [[ASPasscodeHandler sharedInstance] showInKeyWindowWithPasscode:[[ASPreferences sharedInstance] getPasscode] iconView:nil eventBlock:^void(BOOL authenticated){
                if (authenticated) {
                    _appUserAuthorisedID = appIdentifier;
                }

                authHandler(!authenticated);
            }];
        return YES;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [alertView show];
    });
    return YES;
}

- (BOOL)authenticateFunction:(ASAuthenticationAlertType)alertType dismissedHandler:(ASCommonAuthenticationHandler)handler {
    if ([ASPreferences sharedInstance].asphaleiaDisabled) {
        return NO;
    }

    [[%c(SBIconController) sharedInstance] asphaleia_resetAsphaleiaIconView];
    authHandler = [handler copy];

    ASAuthenticationAlert *alertView = [self returnAuthenticationAlertOfType:alertType delegate:self];

    if (![[ASPreferences sharedInstance] touchIDEnabled] && ![[ASPreferences sharedInstance] passcodeEnabled]) {
        return NO;
    }

    if (![[ASPreferences sharedInstance] touchIDEnabled]) {
        [[ASPasscodeHandler sharedInstance] showInKeyWindowWithPasscode:[[ASPreferences sharedInstance] getPasscode] iconView:nil eventBlock:^void(BOOL authenticated){
            authHandler(!authenticated);
        }];
        return YES;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [alertView show];
    });
    return YES;
}

- (BOOL)authenticateAppWithIconView:(SBIconView *)iconView authenticatedHandler:(ASCommonAuthenticationHandler)handler {
    if (!IN_SPRINGBOARD) {
      return NO;
    }

    if ([ASPreferences sharedInstance].asphaleiaDisabled || [ASPreferences sharedInstance].itemSecurityDisabled || [[iconView icon] isDownloadingIcon]) {
        [[%c(SBIconController) sharedInstance] asphaleia_resetAsphaleiaIconView];
        iconView.highlighted = NO;
        return NO;
    }

    NSString *displayName = iconView.icon.displayName;
    currentAuthAppBundleID = [iconView.icon applicationBundleID];

    if (_fingerglyph && _currentHSIconView && [[ASPreferences sharedInstance] securityLevelForApp:currentAuthAppBundleID] != 2) {
        iconView.highlighted = NO;
        if ([iconView isEqual:_currentHSIconView]) {
            [[ASPasscodeHandler sharedInstance] showInKeyWindowWithPasscode:[[ASPreferences sharedInstance] getPasscode] iconView:iconView eventBlock:^void(BOOL authenticated){
                if (authenticated) {
                    [ASAuthenticationController sharedInstance].appUserAuthorisedID = iconView.icon.applicationBundleID;
                }
                handler(!authenticated);
            }];
        }
        [[%c(SBIconController) sharedInstance] asphaleia_resetAsphaleiaIconView];

        return YES;
    } else if (([iconView.icon isApplicationIcon] && ![[ASPreferences sharedInstance] requiresSecurityForApp:iconView.icon.applicationBundleID]) || ([iconView.icon isFolderIcon] && ![[ASPreferences sharedInstance] requiresSecurityForFolder:displayName])) {
        iconView.highlighted = NO;
        return NO;
    } else if ((![[ASPreferences sharedInstance] touchIDEnabled] || [[ASPreferences sharedInstance] securityLevelForApp:currentAuthAppBundleID] == 0) && [[ASPreferences sharedInstance] passcodeEnabled]) {
        iconView.highlighted = NO;
        [[ASPasscodeHandler sharedInstance] showInKeyWindowWithPasscode:[[ASPreferences sharedInstance] getPasscode] iconView:iconView eventBlock:^void(BOOL authenticated){

            if (authenticated){
                [ASAuthenticationController sharedInstance].appUserAuthorisedID = iconView.icon.applicationBundleID;
            }
            handler(!authenticated);
        }];
        return YES;
    }

    if (!_anywhereTouchWindow) {
        _anywhereTouchWindow = [[ASTouchWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }

    _currentHSIconView = iconView;

    [self initialiseGlyphIfRequired];

    CGRect fingerframe = _fingerglyph.frame;
    fingerframe.size.height = [iconView _iconImageView].frame.size.height-10;
    fingerframe.size.width = [iconView _iconImageView].frame.size.width-10;
    _fingerglyph.frame = fingerframe;
    _fingerglyph.center = CGPointMake(CGRectGetMidX([iconView _iconImageView].bounds),CGRectGetMidY([iconView _iconImageView].bounds));
    [[iconView _iconImageView] addSubview:_fingerglyph];

    _fingerglyph.transform = CGAffineTransformMakeScale(0.01,0.01);
    [UIView animateWithDuration:0.3f animations:^{
        _fingerglyph.transform = CGAffineTransformMakeScale(1,1);
    }];

    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.a3tweaks.asphaleia.startmonitoring"), NULL, NULL, YES);

    [_currentHSIconView asphaleia_updateLabelWithText:@"Scan finger..."];

    [_anywhereTouchWindow blockTouchesAllowingTouchInView:_currentHSIconView touchBlockedHandler:^void(ASTouchWindow *touchWindow, BOOL blockedTouch){
        if (blockedTouch) {
            [[%c(SBIconController) sharedInstance] asphaleia_resetAsphaleiaIconView];
            handler(YES);
        }
    }];
    return YES;
}

- (void)dismissAnyAuthenticationAlerts {
    if (!self.currentAuthAlert) {
        return;
    }
    [self.currentAuthAlert dismiss];
}

- (NSArray *)allSubviewsOfView:(UIView *)view {
    NSMutableArray *viewArray = [[NSMutableArray alloc] init];
    [viewArray addObject:view];
    for (UIView *subview in view.subviews) {
        [viewArray addObjectsFromArray:(NSArray *)[self allSubviewsOfView:subview]];
    }
    return [NSArray arrayWithArray:viewArray];
}

- (void)initialiseGlyphIfRequired {
    if (_fingerglyph) {
        return;
    }

    _fingerglyph = [(PKGlyphView *)[%c(PKGlyphView) alloc] initWithStyle:1];
    _fingerglyph.secondaryColor = [UIColor grayColor];
    _fingerglyph.primaryColor = [UIColor redColor];
}

// ASAuthenticationAlert delegate methods
- (void)authAlertView:(ASAuthenticationAlert *)alertView dismissed:(BOOL)dismissed authorised:(BOOL)authorised fingerprint:(BiometricKitIdentity *)fingerprint {
    BOOL correctFingerUsed = YES;
    if ([fingerprint isKindOfClass:%c(BiometricKitIdentity)]) {
        correctFingerUsed = NO;
        switch (self.currentAuthAlert.tag) {
            case ASAuthenticationItem:
                correctFingerUsed = [[ASPreferences sharedInstance] fingerprintProtectsSecureItems:[fingerprint name]];
                break;
            case ASAuthenticationFunction:
                correctFingerUsed = [[ASPreferences sharedInstance] fingerprintProtectsAdvancedSecurity:[fingerprint name]];
                break;
            case ASAuthenticationSecurityMod:
                correctFingerUsed = [[ASPreferences sharedInstance] fingerprintProtectsSecurityMods:[fingerprint name]];
                break;
            default:
                correctFingerUsed = YES;
                break;
        }
    }

    if (!correctFingerUsed) {
        return;
    } else if (correctFingerUsed && !dismissed) {
        [self.currentAuthAlert dismiss];
    }
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.a3tweaks.asphaleia.stopmonitoring"), NULL, NULL, YES);
    if (authorised) {
        _appUserAuthorisedID = currentAuthAppBundleID;
    }

    authHandler(!(authorised && correctFingerUsed));
    self.currentAuthAlert = nil;
    currentAuthAppBundleID = nil;
}

@end
