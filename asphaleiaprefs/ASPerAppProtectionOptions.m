#import "ASRootListController.h"
#import "ASPerAppProtectionOptions.h"
#import <Preferences/PSSpecifier.h>

extern void AppListNeedsToReload();

@implementation ASPerAppProtectionOptions

#pragma mark - HBListController

+ (NSString *)hb_specifierPlist {
	return @"SecuredApps-AdvancedOptions";
}

#pragma mark - Initialization

- (instancetype)initWithAppName:(NSString *)appName identifier:(NSString *)identifier {
    self = [super init];
    if (self) {
        _appName = appName;
        _identifier = identifier;
        self.title = appName;
    }

    return self;
}

#pragma mark - PSListController

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:PreferencesPath]];

    NSString *key = [NSString stringWithFormat:@"securedApps-%@-%@", self.identifier, [specifier propertyForKey:@"key"]];
    defaults[key] = value; 
    [defaults writeToFile:PreferencesPath atomically:YES];
    CFStringRef toPost = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
    if (toPost) {
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), toPost, NULL, NULL, YES);
    }

    AppListNeedsToReload();
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:PreferencesPath];

    NSString *key = [NSString stringWithFormat:@"securedApps-%@-%@", self.identifier, [specifier propertyForKey:@"key"]];
    return ![settings objectForKey:key] ? [specifier propertyForKey:@"default"] : settings[key];
}

@end
