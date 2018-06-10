#import <SpringBoard/SBIcon.h>

@interface SBIcon ()
@property (copy, nonatomic, readonly) NSString *displayName;

- (BOOL)isDownloadingIcon;
- (BOOL)isFolderIcon;

- (NSString *)applicationBundleID;

@end