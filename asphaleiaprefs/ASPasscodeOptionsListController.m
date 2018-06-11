#import "ASPasscodeOptionsListController.h"
#import "ASRootListController.h"
#import "modalPinVC.h"
#import "TouchIDInfo.h"
#import <dlfcn.h>
#import <libactivator/libactivator.h>
#import <Preferences/PSSpecifier.h>

@implementation ASPasscodeOptionsListController

#pragma mark - HBListController

+ (NSString *)hb_specifierPlist {
	return @"PasscodeOptions";
}

#pragma mark - PSListController

- (NSMutableArray <PSSpecifier *> *)specifiers {
	NSMutableArray <PSSpecifier *> *specifiers = [super specifiers];

	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:kPreferencesPath];
	NSString *PIN = settings[@"passcode"];
	if (!PIN) {
		PSSpecifier *specifier = specifiers[1];
		[specifier setProperty:@(0) forKey:@"mode"];
	}

	dlopen("/usr/lib/libactivator.dylib", RTLD_LAZY);
	Class la = NSClassFromString(@"LAActivator");
	if (!la) {
		[specifiers[10] setProperty:@"Activator is required to use this feature." forKey:@"footerText"];
		[specifiers[11] setProperty:@NO forKey:@"enabled"];
	}

	if (!isTouchIDDevice()) {
		for (PSSpecifier *specifier in specifiers) {
			if (![specifier.identifier isEqualToString:@"vibrateSwitchCell"] && ![specifier.identifier isEqualToString:@"touchIDSwitchCell"] && ![specifier.identifier isEqualToString:@"touchIDGroupCell"]) {
				continue;
			}

			[specifiers removeObject:specifier];
		}
	}

	return specifiers;
}

#pragma mark - View management

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	if ([cell.textLabel.text isEqualToString:@"Reset All Settings"]) {
		cell.textLabel.textColor = [UIColor redColor];
	}

	return cell;
}

- (void)resetAllSettings {
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Asphaleia" message:@"Are you sure you want to reset all settings?\nYou can't undo this, and you will have to reconfigure Asphaleia yourself." preferredStyle:UIAlertControllerStyleActionSheet];
	alert.popoverPresentationController.sourceView = self.view;
	alert.popoverPresentationController.sourceRect = self.view.bounds;

	UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
		NSError *error;
		[[NSFileManager defaultManager] removeItemAtPath:kPreferencesPath error:&error];
		CFNotificationCenterPostNotification (CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.a3tweaks.asphaleia/ReloadPrefs"), NULL, NULL,true);
	}];

	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
		[self dismissViewControllerAnimated:YES completion:nil];
	}];

	[alert addAction:defaultAction];
	[alert addAction:cancelAction];
	[self presentViewController:alert animated:YES completion:nil];
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
	NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:PreferencesPath];
	if (!settings[specifier.properties[@"key"]]) {
		return specifier.properties[@"default"];
	}

	return settings[specifier.properties[@"key"]];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
	[defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:PreferencesPath]];
	defaults[specifier.properties[@"key"]] = value;
	[defaults writeToFile:PreferencesPath atomically:YES];
	CFStringRef toPost = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), toPost, NULL, NULL, YES);

	if ([specifier.properties[@"key"] isEqualToString:@"simplePasscode"] && ![value boolValue] && isTouchIDDevice()) {
		PSSpecifier *touchIDSpecifier;
		for (PSSpecifier *forSpecifier in self.specifiers) {
			if (![forSpecifier.identifier isEqualToString:@"touchIDSwitchCell"]) {
				continue;
			}

			touchIDSpecifier = forSpecifier;
		}

		[self setPreferenceValue:@NO specifier:touchIDSpecifier];
		[[self table] reloadData];
	} else if ([specifier.properties[@"key"] isEqualToString:@"touchID"] && [value boolValue] && isTouchIDDevice()) {
		PSSpecifier *passcodeSpecifier;
		for (PSSpecifier *forSpecifier in self.specifiers) {
			if (![forSpecifier.identifier isEqualToString:@"passcodeSwitchCell"]) {
				continue;
			}

			passcodeSpecifier = forSpecifier;
		}

		[self setPreferenceValue:@YES specifier:passcodeSpecifier];
		[[self table] reloadData];
	}
}

@end
