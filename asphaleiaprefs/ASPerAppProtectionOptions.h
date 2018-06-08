#import <CepheiPrefs/HBListController.h>

@interface ASPerAppProtectionOptions : HBListController
@property (copy, readonly, nonatomic) NSString *appName;
@property (copy, readonly, nonatomic) NSString *identifier;

- (instancetype)initWithAppName:(NSString *)appName identifier:(NSString *)identifier;

@end
