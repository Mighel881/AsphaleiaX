#import "ASSecuredItemsListController.h"
#import "ASRootListController.h"
#import <Preferences/PSSpecifier.h>
#import <dlfcn.h>
#import <libactivator/libactivator.h>

@implementation ASSecuredItemsListController

#pragma mark - HBListController

+ (NSString *)hb_specifierPlist {
	return @"SecuredItems";
}

#pragma mark - PSListController

- (NSMutableArray <PSSpecifier *> *)specifiers {
	NSMutableArray <PSSpecifier *> *specifiers = [super specifiers];

	dlopen("/usr/lib/libactivator.dylib", RTLD_LAZY);
	Class la = NSClassFromString(@"LAActivator");
	if (!la) {
		[specifiers[0] setProperty:@"Activator is required to use this feature." forKey:@"footerText"];
		[specifiers[1] setProperty:@NO forKey:@"enabled"];
		[specifiers removeObjectAtIndex:2];
	}

	return specifiers;
}

#pragma mark - View management

- (void)openDynamicSelActivatorControlPanel {
	dlopen("/usr/lib/libactivator.dylib", RTLD_LAZY);
	Class la = NSClassFromString(@"LAListenerSettingsViewController");
	if (la) {
		LAListenerSettingsViewController *vc = [[la alloc] init];
		[vc setListenerName:@"Dynamic Selection"];
		vc.title = @"Dynamic Selection";
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
