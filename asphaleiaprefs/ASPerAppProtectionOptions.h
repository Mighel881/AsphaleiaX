#import <Preferences/PSListController.h>

@interface ASPerAppProtectionOptions : PSListController {
	NSString* _appName;
	NSString* _identifier;
}
- (instancetype)initWithAppName:(NSString*)appName identifier:(NSString*)identifier;
@end
