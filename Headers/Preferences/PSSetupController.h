#import <Preferences/PSRootController+Private.h>

@interface PSSetupController : PSRootController {
    UIViewController *_parentController;
}

- (void)setParentController:(UIViewController *)parentController;
- (UIViewController *)parentController;

@end