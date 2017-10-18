#include <sys/sysctl.h>
#import "ASPreferences.h"
#import "ASAuthenticationController.h"
#import "Asphaleia.h"
#import <Flipswitch/Flipswitch.h>
#import <dlfcn.h>
#import <rocketbootstrap/rocketbootstrap.h>

static NSString *const ASPreferencesFilePath = @"/var/mobile/Library/Preferences/com.a3tweaks.asphaleia.plist";

#define kPrefsChangedNotification "com.a3tweaks.asphaleia/ReloadPrefs"
#define kDisableAsphaleiaNotification "com.a3tweaks.asphaleia/DisableAsphaleia"
#define kEnableAsphaleiaNotification "com.a3tweaks.asphaleia/EnableAsphaleia"

@interface ASPreferences ()
@property (readwrite) BOOL asphaleiaDisabled;
- (void)_loadPreferences;
- (id)objectForKey:(NSString *)key;
- (void)setObject:(id)object forKey:(NSString *)key;
@end

void preferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
	[[ASPreferences sharedInstance] _loadPreferences];
}

@implementation ASPreferences
@synthesize asphaleiaDisabled = _asphaleiaDisabled, itemSecurityDisabled = _itemSecurityDisabled;

+ (instancetype)sharedInstance {
	static ASPreferences *sharedInstance = nil;
	static dispatch_once_t token;
	dispatch_once(&token, ^{
			sharedInstance = [self new];
	});

	return sharedInstance;
}

- (void)_loadPreferences {
	static dispatch_once_t token = 0;
	dispatch_once(&token, ^{
		addObserver(preferencesChangedCallback,kPrefsChangedNotification);
	});

	_center = [%c(CPDistributedMessagingCenter) centerNamed:@"com.a3tweaks.asphaleia.xpc"];
	void *handle = dlopen("/usr/lib/librocketbootstrap.dylib", RTLD_LAZY);
	if (handle) {
		void (*rocketbootstrap_distributedmessagingcenter_apply)(CPDistributedMessagingCenter *) = (void(*)(CPDistributedMessagingCenter *))dlsym(handle, "rocketbootstrap_distributedmessagingcenter_apply");
		rocketbootstrap_distributedmessagingcenter_apply(_center);
		dlclose(handle);
	}

	_prefs = [NSDictionary dictionaryWithContentsOfFile:ASPreferencesFilePath];
	if (![self passcodeEnabled] && ![self touchIDEnabled] && %c(SpringBoard)) {
		_asphaleiaDisabled = YES;
		_itemSecurityDisabled = YES;
	} else {
		_asphaleiaDisabled = NO;
		_itemSecurityDisabled = NO;
	}
}

- (BOOL)requireAuthorisationOnWifi {
	BOOL unlockOnWifi = [self objectForKey:kWifiUnlockKey] ? [[self objectForKey:kWifiUnlockKey] boolValue] : NO;
	NSString *unlockSSIDValue = [self objectForKey:kWifiUnlockNetworkKey] ? [self objectForKey:kWifiUnlockNetworkKey] : @"";
	NSArray *unlockSSIDs = [unlockSSIDValue componentsSeparatedByString:@", "];
	NSString *currentSSID = [[%c(SBWiFiManager) sharedInstance] currentNetworkName];

	for (NSString *SSID in unlockSSIDs) {
		if (unlockOnWifi && [currentSSID isEqualToString:SSID]) {
			return NO;
		}
	}
	return YES;
}

+ (BOOL)isTouchIDDevice {
	if (%c(BiometricKit)) {
		return [[%c(BiometricKit) manager] isTouchIDCapable];
	} else {
		CPDistributedMessagingCenter *centre = [%c(CPDistributedMessagingCenter) centerNamed:@"com.a3tweaks.asphaleia.xpc"];
		rocketbootstrap_distributedmessagingcenter_apply(centre);
		NSDictionary *reply = [centre sendMessageAndReceiveReplyName:@"com.a3tweaks.asphaleia.xpc/IsTouchIDDevice" userInfo:nil];
		return [reply[@"isTouchIDDevice"] boolValue];
	}
}

+ (BOOL)devicePasscodeSet {
	// From http://pastebin.com/T9YwEjnL
	NSData* secret = [@"Device has passcode set?" dataUsingEncoding:NSUTF8StringEncoding];
	NSDictionary *attributes = @{
		(__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
		(__bridge id)kSecAttrService: @"LocalDeviceServices",
		(__bridge id)kSecAttrAccount: @"NoAccount",
		(__bridge id)kSecValueData: secret,
		(__bridge id)kSecAttrAccessible: (__bridge id)kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
	};

	OSStatus status = SecItemAdd((__bridge CFDictionaryRef)attributes, NULL);
	if (status == errSecSuccess) {
		NSDictionary *query = @{
			(__bridge id)kSecClass:  (__bridge id)kSecClassGenericPassword,
			(__bridge id)kSecAttrService: @"LocalDeviceServices",
			(__bridge id)kSecAttrAccount: @"NoAccount"
		};

		status = SecItemDelete((__bridge CFDictionaryRef)query);

		return YES;
	}

	if (status == errSecDecode) {
		return NO;
	}

	return YES;
}

- (id)objectForKey:(NSString *)key {
	return [_prefs objectForKey:key];
}

- (void)setObject:(id)object forKey:(NSString *)key {
	NSMutableDictionary *tempPrefs = [NSMutableDictionary dictionaryWithDictionary:_prefs];
	[tempPrefs setObject:object forKey:key];
	[tempPrefs writeToFile:ASPreferencesFilePath atomically:YES];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR(kPrefsChangedNotification), NULL, NULL, YES);
}

- (BOOL)passcodeEnabled {
	return [self objectForKey:kPasscodeEnabledKey] ? [[self objectForKey:kPasscodeEnabledKey] boolValue] : NO;
}

- (BOOL)touchIDEnabled {
	return ([self objectForKey:kTouchIDEnabledKey] && [ASPreferences isTouchIDDevice]) ? [[self objectForKey:kTouchIDEnabledKey] boolValue] : NO;
}

- (NSString *)getPasscode {
	return [self objectForKey:kPasscodeKey] ? [self objectForKey:kPasscodeKey] : nil;
}

- (BOOL)enableControlPanel {
	return [self objectForKey:kEnableControlPanelKey] ? [[self objectForKey:kEnableControlPanelKey] boolValue] : NO;
}

- (BOOL)allowControlPanelInApps {
	return [self objectForKey:kControlPanelInAppsKey] ? [[self objectForKey:kControlPanelInAppsKey] boolValue] : NO;
}

- (NSInteger)appSecurityDelayTime {
	return [self objectForKey:kDelayAfterLockTimeKey] ? [[self objectForKey:kDelayAfterLockTimeKey] integerValue] : 10;
}

- (BOOL)delayAppSecurity {
	return [self objectForKey:kDelayAfterLockKey] ? [[self objectForKey:kDelayAfterLockKey] boolValue] : NO;
}

- (BOOL)resetAppExitTimerOnLock {
	return [self objectForKey:kResetAppExitTimerOnLockKey] ? [[self objectForKey:kResetAppExitTimerOnLockKey] boolValue] : NO;
}

- (NSInteger)appExitUnlockTime {
	return [self objectForKey:kAppExitUnlockTimeKey] ? [[self objectForKey:kAppExitUnlockTimeKey] integerValue] : 0;
}

- (BOOL)enableDynamicSelection {
	if (![self requireAuthorisationOnWifi] || [ASPreferences sharedInstance].asphaleiaDisabled || [ASPreferences sharedInstance].itemSecurityDisabled) {
		return NO;
	}
	return [self objectForKey:kDynamicSelectionKey] ? [[self objectForKey:kDynamicSelectionKey] boolValue] : NO;
}

- (BOOL)protectAllApps {
	if (![self requireAuthorisationOnWifi] || [ASPreferences sharedInstance].asphaleiaDisabled) {
		return NO;
	}
	return [self objectForKey:kProtectAllAppsKey] ? [[self objectForKey:kProtectAllAppsKey] boolValue] : NO;
}

- (BOOL)vibrateOnIncorrectFingerprint {
	return [self objectForKey:kVibrateOnFailKey] ? [[self objectForKey:kVibrateOnFailKey] boolValue] : NO;
}

- (BOOL)secureControlCentre {
	if (![self requireAuthorisationOnWifi] || [ASPreferences sharedInstance].asphaleiaDisabled) {
		return NO;
	}
	return [self objectForKey:kSecureControlCentreKey] ? [[self objectForKey:kSecureControlCentreKey] boolValue] : NO;
}

- (BOOL)securePowerDownView {
	if (![self requireAuthorisationOnWifi] || [ASPreferences sharedInstance].asphaleiaDisabled) {
		return NO;
	}
	return [self objectForKey:kSecurePowerDownKey] ? [[self objectForKey:kSecurePowerDownKey] boolValue] : NO;
}

- (BOOL)secureSpotlight {
	if (![self requireAuthorisationOnWifi] || [ASPreferences sharedInstance].asphaleiaDisabled) {
		return NO;
	}
	return [self objectForKey:kSecureSpotlightKey] ? [[self objectForKey:kSecureSpotlightKey] boolValue] : NO;
}

- (BOOL)unlockToAppUnsecurely {
	if (![self requireAuthorisationOnWifi] || [ASPreferences sharedInstance].asphaleiaDisabled || [ASPreferences sharedInstance].itemSecurityDisabled) {
		return YES;
	}
	return [self objectForKey:kUnsecureUnlockToAppKey] ? [[self objectForKey:kUnsecureUnlockToAppKey] boolValue] : NO;
}

- (BOOL)obscureAppContent {
	if (![self requireAuthorisationOnWifi] || [ASPreferences sharedInstance].asphaleiaDisabled || [ASPreferences sharedInstance].itemSecurityDisabled) {
		return NO;
	}
	return [self objectForKey:kObscureAppContentKey] ? [[self objectForKey:kObscureAppContentKey] boolValue] : YES;
}

- (BOOL)obscureNotifications {
	if (![self requireAuthorisationOnWifi] || [ASPreferences sharedInstance].asphaleiaDisabled || [ASPreferences sharedInstance].itemSecurityDisabled) {
		return NO;
	}
	return [self objectForKey:kObscureBannerKey] ? [[self objectForKey:kObscureBannerKey] boolValue] : YES;
}

- (BOOL)secureSwitcher {
	if (![self requireAuthorisationOnWifi] || [ASPreferences sharedInstance].asphaleiaDisabled) {
		return NO;
	}
	return [self objectForKey:kSecureSwitcherKey] ? [[self objectForKey:kSecureSwitcherKey] boolValue] : NO;
}

- (BOOL)secureAppArrangement {
	if (![self requireAuthorisationOnWifi] || [ASPreferences sharedInstance].asphaleiaDisabled) {
		return NO;
	}
	return [self objectForKey:kSecureAppArrangementKey] ? [[self objectForKey:kSecureAppArrangementKey] boolValue] : NO;
}

- (BOOL)securePhotos {
	if (![self requireAuthorisationOnWifi] || [ASPreferences sharedInstance].asphaleiaDisabled) {
		return NO;
	}
	return [self objectForKey:kSecurePhotosKey] ? [[self objectForKey:kSecurePhotosKey] boolValue] : NO;
}

- (BOOL)showPhotosProtectMessage {
	return [[self objectForKey:kPhotosMessageCount] intValue] <= 3 ? YES : NO;
}

- (void)increasePhotosProtectMessageCount {
	[self setObject:[NSNumber numberWithInt:[[self objectForKey:kPhotosMessageCount] intValue]+1] forKey:kPhotosMessageCount];
}

- (BOOL)securityEnabledForApp:(NSString *)app {
	NSString *key = [NSString stringWithFormat:@"securedApps-%@-enabled", app];
	return ![self objectForKey:key] ? NO : [[self objectForKey:key] boolValue];
}

- (NSInteger)securityLevelForApp:(NSString*)app {
	NSString *key = [NSString stringWithFormat:@"securedApps-%@-protectionLevel", app];
	return ![self objectForKey:key] ? 1 : [[self objectForKey:key] intValue];
}

- (BOOL)requiresSecurityForApp:(NSString *)app {
	NSString *tempUnlockedApp;
	if (%c(SpringBoard) && %c(ASAuthenticationController)) {
		tempUnlockedApp = [[%c(ASAuthenticationController) sharedInstance] temporarilyUnlockedAppBundleID];
	} else {
		NSDictionary *reply = [_center sendMessageAndReceiveReplyName:@"com.a3tweaks.asphaleia.xpc/GetCurrentTempUnlockedApp" userInfo:nil];
		tempUnlockedApp = reply[@"bundleIdentifier"];
	}

	NSString *key = [NSString stringWithFormat:@"securedApps-%@-enabled", app];
	if (![self requireAuthorisationOnWifi] || [ASPreferences sharedInstance].itemSecurityDisabled || [ASPreferences sharedInstance].asphaleiaDisabled || [tempUnlockedApp isEqualToString:app]) {
		return NO;
	} else if ([self protectAllApps]) {
		return YES;
	}

	return [[self objectForKey:key] boolValue];
}

- (BOOL)requiresSecurityForFolder:(NSString *)folder {
	NSDictionary *folders = [self objectForKey:kSecuredFoldersKey];
	if (!folders || ![self requireAuthorisationOnWifi] || [ASPreferences sharedInstance].itemSecurityDisabled || [ASPreferences sharedInstance].asphaleiaDisabled) {
		return NO;
	}

	return [[folders objectForKey:folder] boolValue];
}

- (BOOL)requiresSecurityForPanel:(NSString *)panel {
	NSDictionary *panels = [self objectForKey:kSecuredPanelsKey];
	if (!panels || ![self requireAuthorisationOnWifi] || [ASPreferences sharedInstance].itemSecurityDisabled || [ASPreferences sharedInstance].asphaleiaDisabled) {
		return NO;
	}

	return [[panels objectForKey:panel] boolValue];
}

- (BOOL)requiresSecurityForSwitch:(NSString *)flipswitch {
	NSDictionary *switches = [self objectForKey:kSecuredSwitchesKey];
	if (!switches || ![self requireAuthorisationOnWifi] || [ASPreferences sharedInstance].itemSecurityDisabled || [ASPreferences sharedInstance].asphaleiaDisabled) {
		return NO;
	}

	return [[switches objectForKey:flipswitch] boolValue];
}

- (BOOL)fingerprintProtectsSecureItems:(NSString *)fingerprint {
	NSDictionary *fingerprintSettings = [self objectForKey:kFingerprintSettingsKey];
	if (!fingerprintSettings) {
		return YES;
	}

	NSDictionary *fingerprintDict = [fingerprintSettings objectForKey:kSecuredItemsFingerprintsKey];
	BOOL usesFingerprintProtection = NO;
	for (NSString *fingerprint in fingerprintDict) {
		if ([[fingerprintDict objectForKey:fingerprint] boolValue]) {
			usesFingerprintProtection = YES;
		}
	}
	if (!usesFingerprintProtection) {
		return YES;
	}

	return [[fingerprintDict objectForKey:fingerprint] boolValue];
}

- (BOOL)fingerprintProtectsSecurityMods:(NSString *)fingerprint {
	NSDictionary *fingerprintSettings = [self objectForKey:kFingerprintSettingsKey];
	if (!fingerprintSettings) {
		return YES;
	}

	NSDictionary *fingerprintDict = [fingerprintSettings objectForKey:kSecurityModFingerprintsKey];
	BOOL usesFingerprintProtection = NO;
	for (NSString *fingerprint in fingerprintDict) {
		if ([[fingerprintDict objectForKey:fingerprint] boolValue]) {
			usesFingerprintProtection = YES;
		}
	}
	if (!usesFingerprintProtection) {
		return YES;
	}

	return [[fingerprintDict objectForKey:fingerprint] boolValue];
}

- (BOOL)fingerprintProtectsAdvancedSecurity:(NSString *)fingerprint {
	NSDictionary *fingerprintSettings = [self objectForKey:kFingerprintSettingsKey];
	if (!fingerprintSettings) {
		return YES;
	}

	NSDictionary *fingerprintDict = [fingerprintSettings objectForKey:kAdvancedSecurityFingerprintsKey];
	BOOL usesFingerprintProtection = NO;
	for (NSString *fingerprint in fingerprintDict) {
		if ([[fingerprintDict objectForKey:fingerprint] boolValue]) {
			usesFingerprintProtection = YES;
		}
	}
	if (!usesFingerprintProtection) {
		return YES;
	}

	return [[fingerprintDict objectForKey:fingerprint] boolValue];
}

// Custom setters/getters
- (BOOL)asphaleiaDisabled {
	if (%c(SpringBoard)) {
		return _asphaleiaDisabled;
	}

	NSDictionary *reply = [_center sendMessageAndReceiveReplyName:@"com.a3tweaks.asphaleia.xpc/ReadAsphaleiaState" userInfo:nil];
	return [reply[@"asphaleiaDisabled"] boolValue];
}

- (void)setAsphaleiaDisabled:(BOOL)value {
	if (%c(SpringBoard)) {
		_asphaleiaDisabled = value;
		return;
	}

	[_center sendMessageAndReceiveReplyName:@"com.a3tweaks.asphaleia.xpc/SetAsphaleiaState" userInfo:@{@"asphaleiaDisabled" : [NSNumber numberWithBool:value]}];
}

- (BOOL)itemSecurityDisabled {
	if (%c(SpringBoard)) {
		return _itemSecurityDisabled;
	}

	NSDictionary *reply = [_center sendMessageAndReceiveReplyName:@"com.a3tweaks.asphaleia.xpc/ReadAsphaleiaState" userInfo:nil];
	return [reply[@"itemSecurityDisabled"] boolValue];
}

- (void)setItemSecurityDisabled:(BOOL)value {
	if (%c(SpringBoard)) {
		_itemSecurityDisabled = value;
		return;
	}

	[_center sendMessageAndReceiveReplyName:@"com.a3tweaks.asphaleia.xpc/SetAsphaleiaState" userInfo:@{@"itemSecurityDisabled" : [NSNumber numberWithBool:value]}];
}

@end
