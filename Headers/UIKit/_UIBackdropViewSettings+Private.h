#import <UIKit/_UIBackdropViewSettings.h>

@interface _UIBackdropViewSettings ()
@property (readonly, nonatomic) UIColor *combinedTintColor;

+ (instancetype)settingsForPrivateStyle:(NSInteger)style graphicsQuality:(NSInteger)quality;

@end