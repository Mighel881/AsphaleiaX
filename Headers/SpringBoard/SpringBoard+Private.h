#import <SpringBoard/SpringBoard.h>

@interface SpringBoard ()

- (void)applicationOpenURL:(NSURL *)url;
- (void)_handleGotoHomeScreenShortcut:(id)shortcut;
@end