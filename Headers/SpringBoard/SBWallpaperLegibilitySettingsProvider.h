#import <SpringBoardFoundation/SBFLegibilitySettingsProvider.h>

@interface SBWallpaperLegibilitySettingsProvider : NSObject <SBFLegibilitySettingsProvider>

- (instancetype)initWithVariant:(NSInteger)variant;

@end