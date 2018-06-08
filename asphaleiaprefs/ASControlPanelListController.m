#import "ASControlPanelListController.h"
#import "ASRootListController.h"
#import <dlfcn.h>
#import <libactivator/libactivator.h>
#import <Preferences/PSSpecifier.h>

@implementation ASControlPanelListController

#pragma mark - HBListController

+ (NSString *)hb_specifierPlist {
	return @"PasscodeOptions-AsphaleiaControlPanel";
}

#pragma mark PSListController

- (void)openActivatorControlPanel {
	dlopen("/usr/lib/libactivator.dylib", RTLD_LAZY);
	Class la = NSClassFromString(@"LAListenerSettingsViewController");
	if (la) {
		LAListenerSettingsViewController *vc = [[la alloc] init];
		[vc setListenerName:@"Control Panel"];
		vc.title = @"Control Panel";
		[self.navigationController pushViewController:vc animated:YES];
	}
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
	if (toPost) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), toPost, NULL, NULL, YES);
	}
}

@end
