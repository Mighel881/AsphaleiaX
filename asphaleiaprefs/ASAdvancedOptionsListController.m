#import "ASAdvancedOptionsListController.h"
#import "ASRootListController.h"
#import "TouchIDInfo.h"
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSSystemConfigurationDynamicStoreWifiWatcher.h>

static UITextField *wifiTextField;

@implementation ASAdvancedOptionsListController

#pragma mark - HBListController

+ (NSString *)hb_specifierPlist {
	return @"PasscodeOptions-AdvancedOptions";
}

#pragma mark - PSListController

- (NSMutableArray <PSSpecifier *> *)specifiers {
	NSMutableArray <PSSpecifier *> *specifiers = [super specifiers];

	if (!isTouchIDDevice()) {
		for (PSSpecifier *specifier in specifiers) {
			if (![specifier.identifier isEqualToString:@"fingerprintCell"] && ![specifier.identifier isEqualToString:@"fingerprintGroupCell"]) {
				continue;
			}

			[specifiers removeObject:specifier];
		}
	}

	return specifiers;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	for (id subview in [cell.contentView subviews]) {
		if (![subview isKindOfClass:[UITextField class]]) {
			continue;
		}

		wifiTextField = subview;
		wifiTextField.delegate = self;
		[wifiTextField setReturnKeyType:UIReturnKeyDone];
	}

	return cell;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textfield {
	[textfield resignFirstResponder];
	return YES;
}

- (void)addCurrentNetwork {
	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:kPreferencesPath];
	NSMutableString *currentWifiString = [NSMutableString stringWithString:[wifiTextField text]];
	NSString *currentSSID = [self currentWifiSSID];
	NSArray *networks = [currentWifiString componentsSeparatedByString:@", "];
	if ([networks containsObject:currentSSID]) {
		return;
	}

	if (currentWifiString.length != 0) {
		[currentWifiString appendString:@", "];
	}

	[currentWifiString appendString:currentSSID];
	[wifiTextField setText:currentWifiString];
	[settings setObject:currentWifiString forKey:@"wifiNetwork"];
	[settings writeToFile:kPreferencesPath atomically:YES];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.a3tweaks.asphaleia/ReloadPrefs"), NULL, NULL, YES);
}

- (NSString *)currentWifiSSID {
	PSSystemConfigurationDynamicStoreWifiWatcher *dynamicStoreWifiWatcher = [PSSystemConfigurationDynamicStoreWifiWatcher sharedInstance];
	NSDictionary *wifiConfig = [dynamicStoreWifiWatcher wifiConfig];

	return [wifiConfig objectForKey:@"wifiName"] ? wifiConfig[@"wifiName"] : @"";
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:PreferencesPath];
	if (!settings[specifier.properties[@"key"]]) {
		return specifier.properties[@"default"];
	}

	return settings[specifier.properties[@"key"]];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
	NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	[defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:PreferencesPath]];
	defaults[specifier.properties[@"key"]] = value;
	[defaults writeToFile:PreferencesPath atomically:YES];
	CFStringRef toPost = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
	if (toPost) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), toPost, NULL, NULL, YES);
	}
}

@end
