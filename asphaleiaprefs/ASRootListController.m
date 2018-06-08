#import "ASRootListController.h"
#import "ASCreatorsListController.h"
#import "ASPasscodeOptionsListController.h"
#import "ASSecuredItemsListController.h"
#import <CepheiPrefs/HBSupportController.h>
#import <TechSupport/TSContactViewController.h>
#import <UIKit/UIImage+Private.h>

@implementation ASRootListController

#pragma mark - HBListController

+ (NSString *)hb_shareText {
	return @"Securing my apps with #AsphaleiaX from @ShadeZepheri!";
}

+ (NSURL *)hb_shareURL {
    return [NSURL URLWithString:@"https://shade-zepheri.github.io/"];
}

+ (NSString *)hb_specifierPlist {
	return @"Root";
}

#pragma mark - View management

- (void)viewDidLoad {
	[super viewDidLoad];

	UIImage *logoImage = [UIImage imageNamed:@"NavA3tweaks" inBundle:self.bundle];
	self.navigationItem.titleView = [[UIImageView alloc] initWithImage:logoImage];
	self.navigationItem.titleView.alpha = 0.0f;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	if (!self.alreadyAnimatedOnce) {
		self.alreadyAnimatedOnce = YES;
		self.navigationItem.titleView.alpha = 0.0f;
		[UIView animateWithDuration:0.3f animations:^{
			self.navigationItem.titleView.alpha = 1.0f;
		}];
	}
}

- (void)showSecurity {
	[self pushController:[[ASSecuredItemsListController alloc] init]];
}

- (void)showCreators {
	[self pushController:[[ASCreatorsListController alloc] init]];
}

- (void)showPasscodeOptions {
	[self pushController:[[ASPasscodeOptionsListController alloc] init]];
}

- (void)showSupportController {
	TSContactViewController *supportController = [HBSupportController supportViewControllerForBundle:self.bundle];
	[self.navigationController pushViewController:supportController animated:YES];
}

- (BOOL)canBeShownFromSuspendedState {
	return NO;
}

@end
