#import "ASAlert.h"
#import "ASPreferences.h"
#import <SpringBoard/SBAlertItemsController.h>

#define titleWithSpacingForIcon(t) [NSString stringWithFormat:@"\n\n\n%@",t]
#define titleWithSpacingForSmallIcon(t) [NSString stringWithFormat:@"\n\n%@",t]

@interface ASPreferences ()
@property (readwrite) BOOL asphaleiaDisabled;
@property (readwrite) BOOL itemSecurityDisabled;
@end

@interface ASAlert ()
@property (nonatomic) NSMutableArray *buttons;
@property (nonatomic) UIView *aboveTitleSubview;
- (NSArray *)allSubviewsOfView:(UIView *)view;
- (void)addSubviewToAlert:(UIView *)view;
@end

%subclass ASAlert : SBAlertItem
%property (nonatomic, copy) NSString *title;
%property (nonatomic, copy) NSString *message;
%property (nonatomic, assign) NSInteger tag;
%property (nonatomic, retain) UIView *aboveTitleSubview;

%new
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id<ASAlertDelegate>)delegate {
	self = [self init];
	if (self) {
		self.title = title;
		self.message = message;
		self.delegate = delegate;
		self.buttons = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)configure:(BOOL)configure requirePasscodeForActions:(BOOL)requirePasscode {
	%orig;
	[self alertController].title = self.title;
	[self alertController].message = self.message;

	SBApplication *frontmostApp = [(SpringBoard *)[UIApplication sharedApplication] _accessibilityFrontMostApplication];
	NSString *bundleID = [frontmostApp bundleIdentifier];

	UIAlertAction *securedItemsAction = [UIAlertAction actionWithTitle:self.buttons[0] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[ASPreferences sharedInstance].itemSecurityDisabled = ![ASPreferences sharedInstance].itemSecurityDisabled;
		if ([ASPreferences sharedInstance].itemSecurityDisabled && [[ASPreferences sharedInstance] protectAllApps]) {
			[[ASPreferences sharedInstance] setObject:[NSNumber numberWithBool:NO] forKey:kProtectAllAppsKey];
		}
		[self dismiss];
	}];

	UIAlertAction *globalSecurityAction = [UIAlertAction actionWithTitle:self.buttons[1] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[[ASPreferences sharedInstance] setObject:[NSNumber numberWithBool:![[ASPreferences sharedInstance] protectAllApps]] forKey:kProtectAllAppsKey];
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
			[dict setObject:[NSNumber numberWithBool:![[ASPreferences sharedInstance] securityEnabledForApp:bundleID]] forKey:frontmostApp.bundleIdentifier];
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

%new
- (void)addSubviewToAlert:(UIView *)view {
	UIView *labelSuperview;
	for (id subview in [self allSubviewsOfView:[[self alertController] view]]) {
		if ([subview isKindOfClass:[UILabel class]]) {
		  labelSuperview = [subview superview];
		}
	}
	if ([labelSuperview respondsToSelector:@selector(addSubview:)]) {
		[labelSuperview addSubview:view];
	}
}

%new
- (NSArray *)allSubviewsOfView:(UIView *)view {
	NSMutableArray *viewArray = [[NSMutableArray alloc] init];
	[viewArray addObject:view];
	for (UIView *subview in view.subviews) {
	  [viewArray addObjectsFromArray:(NSArray *)[self allSubviewsOfView:subview]];
	}
	return [NSArray arrayWithArray:viewArray];
}

%new
- (void)show {
	if (self.delegate && [self.delegate respondsToSelector:@selector(willPresentAlertView:)]) {
		[self.delegate willPresentAlertView:self];
	}
	if (%c(SBAlertItemsController)) {
		[[%c(SBAlertItemsController) sharedInstance] activateAlertItem:self];
	}
}

%new
- (void)addButtonWithTitle:(NSString *)buttonTitle {
	if ([buttonTitle isKindOfClass:[NSString class]]) {
		[self.buttons addObject:buttonTitle];
	}
}

%new
- (void)removeButtonWithTitle:(NSString *)buttonTitle {
	if ([buttonTitle isKindOfClass:[NSString class]]) {
		[self.buttons removeObject:buttonTitle];
	}
}

// Properties
%new
- (void)setDelegate:(id<ASAlertDelegate>)delegate {
	objc_setAssociatedObject(self, @selector(delegate), delegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

%new
- (id<ASAlertDelegate>)delegate {
	return objc_getAssociatedObject(self, @selector(delegate));
}

%new
- (void)setButtons:(NSMutableArray *)buttons {
	objc_setAssociatedObject(self, @selector(buttons), buttons, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
%new
- (NSMutableArray *)buttons {
	return objc_getAssociatedObject(self, @selector(buttons));
}

%end
