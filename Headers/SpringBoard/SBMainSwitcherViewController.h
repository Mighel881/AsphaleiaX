#import <UIKit/UIKit.h>

@interface SBMainSwitcherViewController : UIViewController
+ (instancetype)sharedInstance;

- (BOOL)toggleSwitcherNoninteractively;
- (BOOL)activateSwitcherNoninteractively;
- (BOOL)dismissSwitcherNoninteractively;

@end