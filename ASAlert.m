#import "ASAlert.h"
#import "ASPreferences.h"
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SpringBoard+Private.h>

#define titleWithSpacingForIcon(t) [NSString stringWithFormat:@"\n\n\n%@",t]
#define titleWithSpacingForSmallIcon(t) [NSString stringWithFormat:@"\n\n%@",t]

@interface ASPreferences ()
@property (assign, readwrite, nonatomic) BOOL asphaleiaDisabled;
@property (assign, readwrite, nonatomic) BOOL itemSecurityDisabled;
@end

@interface ASAlert ()
@property (strong, nonatomic) NSMutableArray *buttons;
@property (strong, nonatomic) UIView *aboveTitleSubview;
@end

@implementation ASAlert 

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id<ASAlertDelegate>)delegate {
	self = [self init];
	if (self) {
		self.title = title;
		self.message = message;
		self.delegate = delegate;
		self.buttons = [NSMutableArray array];
	}

	return self;
}

- (void)configure:(BOOL)configure requirePasscodeForActions:(BOOL)requirePasscode {
	[super configure:configure requirePasscodeForActions:requirePasscode];

	[self alertController].title = self.title;
	[self alertController].message = self.message;

	SBApplication *frontmostApp = [(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
	NSString *bundleID = frontmostApp.bundleIdentifier;

	UIAlertAction *securedItemsAction = [UIAlertAction actionWithTitle:self.buttons[0] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[ASPreferences sharedInstance].itemSecurityDisabled = ![ASPreferences sharedInstance].itemSecurityDisabled;
		if ([ASPreferences sharedInstance].itemSecurityDisabled && [[ASPreferences sharedInstance] protectAllApps]) {
			[[ASPreferences sharedInstance] setObject:@(NO) forKey:kProtectAllAppsKey];
		}
		[self dismiss];
	}];

	UIAlertAction *globalSecurityAction = [UIAlertAction actionWithTitle:self.buttons[1] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
	[[ASPreferences sharedInstance] setObject:@(![[ASPreferences sharedInstance] protectAllApps]) forKey:kProtectAllAppsKey];
		if ([ASPreferences sharedInstance].itemSecurityDisabled && [[ASPreferences sharedInstance] protectAllApps]) {
			[ASPreferences sharedInstance].itemSecurityDisabled = NO;
		}
		[self dismiss];
	}];

	[[self alertController] addAction:securedItemsAction];
	[[self alertController] addAction:globalSecurityAction];

	if (self.buttons.count == 3) {
		UIAlertAction *removeAppAction = [UIAlertAction actionWithTitle:self.buttons[2] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
			if (![[ASPreferences sharedInstance] objectForKey:kSecuredAppsKey]) {
				[[ASPreferences sharedInstance] setObject:[NSMutableDictionary dictionary] forKey:kSecuredAppsKey];
			}

			NSMutableDictionary *dict = [[ASPreferences sharedInstance] objectForKey:kSecuredAppsKey];
			dict[frontmostApp.bundleIdentifier] = @(![[ASPreferences sharedInstance] securityEnabledForApp:bundleID]);
			[[ASPreferences sharedInstance] setObject:dict forKey:kSecuredAppsKey];
			[self dismiss];
		}];

		[[self alertController] addAction:removeAppAction];
	}

	UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
		[self dismiss];
	}];
	[[self alertController] addAction:cancelAction];

	if (self.aboveTitleSubview) {
		[self alertController].title = titleWithSpacingForSmallIcon(self.title);
		self.aboveTitleSubview.center = CGPointMake(270/2,32);
		dispatch_async(dispatch_get_main_queue(), ^{
			[self addSubviewToAlert:self.aboveTitleSubview];
		});
	}
}

- (BOOL)shouldShowInLockScreen {
	return NO;
}

- (void)addSubviewToAlert:(UIView *)view {
	UIView *labelSuperview;
	for (id subview in [self allSubviewsOfView:[[self alertController] view]]) {
		if (![subview isKindOfClass:[UILabel class]]) {
			continue;
		}

		labelSuperview = [subview superview];
	}

	if ([labelSuperview respondsToSelector:@selector(addSubview:)]) {
		[labelSuperview addSubview:view];
	}
}

- (NSArray *)allSubviewsOfView:(UIView *)view {
	NSMutableArray *viewArray = [NSMutableArray array];
	[viewArray addObject:view];
	for (UIView *subview in view.subviews) {
		[viewArray addObjectsFromArray:(NSArray *)[self allSubviewsOfView:subview]];
	}

	return [NSArray arrayWithArray:viewArray];
}

- (void)show {
	if (self.delegate && [self.delegate respondsToSelector:@selector(willPresentAlertView:)]) {
		[self.delegate willPresentAlertView:self];
	}

	[SBAlertItem activateAlertItem:self];
}

- (void)addButtonWithTitle:(NSString *)buttonTitle {
	if (![buttonTitle isKindOfClass:[NSString class]]) {
		return;
	}

	[self.buttons addObject:buttonTitle];
}

- (void)removeButtonWithTitle:(NSString *)buttonTitle {
	if ([buttonTitle isKindOfClass:[NSString class]]) {
		return;
	}

	[self.buttons removeObject:buttonTitle];
}

@end
