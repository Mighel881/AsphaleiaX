#import "ASPINController.h"

@implementation ASPINController

- (BOOL)isBlocked {
    return NO;
}

- (BOOL)isNumericPIN {
    return YES;
}

- (BOOL)simplePIN {
    return YES;
}

- (BOOL)useProgressiveDelays {
    return NO;
}

- (NSInteger)pinLength {
    return 6;
}

- (BOOL)validatePIN:(NSString *)PIN {
    NSDictionary *preferences = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/com.a3tweaks.asphaleia.plist"];
    NSString *passcode = preferences[@"passcode"];
    return [PIN isEqualToString:passcode];
}

- (void)setPIN:(NSString *)PIN completion:(id)completion {
    NSMutableDictionary *settings = [NSMutableDictionary dictionary];
    NSString *settingsPath = @"/var/mobile/Library/Preferences/com.a3tweaks.asphaleia.plist";
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];
    
    settings[@"passcode"] = PIN;
    [settings writeToFile:settingsPath atomically:YES];

	CFNotificationCenterPostNotification (CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.a3tweaks.asphaleia/ReloadPrefs"), NULL, NULL, YES);
}

- (void)setPIN:(NSString *)PIN {
    [self setPIN:PIN completion:nil];
}

- (NSBundle *)stringsBundle {
    return [NSBundle bundleForClass:DevicePINController.class];
}

- (NSString *)stringsTable {
    return @"PIN Entry";
}

- (BOOL)isKindOfClass:(Class)aClass {
    // Just to make sure its recognized as subclass
    if (aClass == [DevicePINController class]) {
        return YES;
    }

    return [super isKindOfClass:aClass];
}

@end