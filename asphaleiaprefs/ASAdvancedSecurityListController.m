#import "ASAdvancedSecurityListController.h"
#import "ASRootListController.h"
#import <Preferences/PSSpecifier.h>

@implementation ASAdvancedSecurityListController

#pragma mark - HBListController

+ (NSString *)hb_specifierPlist {
	return @"SecuredItems-AdvancedSecurity";
}

#pragma mark - PSListController

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	switch (indexPath.section) {
		case 0:
			cell.imageView.image = [UIImage imageNamed:@"IconEditMode.png" inBundle:[[NSBundle alloc] initWithPath:kBundlePath] compatibleWithTraitCollection:nil];
			break;
		case 1:
			cell.imageView.image = [UIImage imageNamed:@"IconPowerOff.png" inBundle:[[NSBundle alloc] initWithPath:kBundlePath] compatibleWithTraitCollection:nil];
			break;
		case 2:
			cell.imageView.image = [UIImage imageNamed:@"IconMultitasking.png" inBundle:[[NSBundle alloc] initWithPath:kBundlePath] compatibleWithTraitCollection:nil];
			break;
		case 3:
			cell.imageView.image = [UIImage imageNamed:@"IconControlCenter.png" inBundle:[[NSBundle alloc] initWithPath:kBundlePath] compatibleWithTraitCollection:nil];
			break;
		case 4:
			cell.imageView.image = [UIImage imageNamed:@"IconSpotlight.png" inBundle:[[NSBundle alloc] initWithPath:kBundlePath] compatibleWithTraitCollection:nil];
			break;
	}

	return cell;
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
