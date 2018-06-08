#import <CepheiPrefs/HBRootListController.h>

#define kPreferencesPath @"/var/mobile/Library/Preferences/com.a3tweaks.asphaleia.plist"
#define kBundlePath @"/Library/PreferenceBundles/AsphaleiaPrefs.bundle"

#define kPreferencesTemplatePath @"/private/var/mobile/Library/Preferences/%@.plist"
#define PreferencesPath [NSString stringWithFormat:kPreferencesTemplatePath,specifier.properties[@"defaults"]]

@interface ASRootListController : HBRootListController 
@property (assign, nonatomic) BOOL alreadyAnimatedOnce;

@end
