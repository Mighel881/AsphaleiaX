#import "ASRootListController.h"
#import "ASPerAppProtectionOptions.h"
#import <Preferences/PSSpecifier.h>

extern void AppListNeedsToReload();

@implementation ASPerAppProtectionOptions
- (NSArray*)specifiers {
    if (!_specifiers) {
        _specifiers = [self loadSpecifiersFromPlistName:@"SecuredApps-AdvancedOptions" target:self];
    }

    return _specifiers;
}

- (instancetype)initWithAppName:(NSString*)appName identifier:(NSString*)identifier {
    _appName = appName;
    _identifier = identifier;

    self.title = appName;
    return [self init];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:PreferencesPath]];

    NSString *key = [NSString stringWithFormat:@"securedApps-%@-%@",_identifier,[specifier propertyForKey:@"key"]];
    [defaults setObject:value forKey:key];
    [defaults writeToFile:PreferencesPath atomically:YES];
    CFStringRef toPost = (__bridge CFStringRef)specifier.properties[@"PostNotification"];
    if (toPost) {
      CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), toPost, NULL, NULL, YES);
    }

    AppListNeedsToReload();
}

- (id)readPreferenceValue:(PSSpecifier*)specifier {
    NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:PreferencesPath];

    NSString *key = [NSString stringWithFormat:@"securedApps-%@-%@",_identifier,[specifier propertyForKey:@"key"]];
    return ![settings objectForKey:key] ? [specifier propertyForKey:@"default"] : settings[key];
}

@end
