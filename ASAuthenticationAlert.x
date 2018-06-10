#import "ASAuthenticationAlert.h"
#import "ASAuthenticationController.h"
#import "ASPreferences.h"
#import "ASPasscodeHandler.h"
#import <SpringBoard/SBAlertItemsController.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>
#import <UIKit/UIImage+Private.h>

#define titleWithSpacingForIcon(t) [NSString stringWithFormat:@"\n\n\n%@",t]
#define titleWithSpacingForSmallIcon(t) [NSString stringWithFormat:@"\n\n%@",t]

@interface ASAuthenticationAlert ()
- (UIImage *)colouriseImage:(UIImage *)origImage withColour:(UIColor *)tintColour;
@end

static BOOL blockPasscode;

@implementation ASAuthenticationAlert

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message icon:(UIView *)icon smallIcon:(BOOL)useSmallIcon delegate:(id<ASAuthenticationAlertDelegate>)delegate {
	self = [super initWithTitle:title message:message delegate:delegate];
	if (self) {
		self.icon = icon;
		self.useSmallIcon = useSmallIcon;
	}

	return self;
}

- (instancetype)initWithApplication:(NSString *)identifier message:(NSString *)message delegate:(id<ASAuthenticationAlertDelegate>)delegate {
	if (!identifier) {
		return nil;
	}

	self = [self init];
	if (self) {
		SBApplication *application = [[%c(SBApplicationController) sharedInstance] applicationWithBundleIdentifier:identifier];
		self.title = application.displayName;
		self.message = message;
		self.delegate = delegate;

		UIImage *iconImage = [UIImage _applicationIconImageForBundleIdentifier:identifier format:0 scale:[UIScreen mainScreen].scale];
		UIImageView *imageView = [[UIImageView alloc] initWithImage:iconImage];
		imageView.frame = CGRectMake(0,0,iconImage.size.width,iconImage.size.height);

		if ([[ASPreferences sharedInstance] touchIDEnabled]) {
			dispatch_async(dispatch_get_main_queue(), ^{
				[[ASAuthenticationController sharedInstance] initialiseGlyphIfRequired];
				imageView.image = [self colouriseImage:iconImage withColour:[UIColor colorWithWhite:0.f alpha:0.5f]];
				CGRect fingerframe = [[ASAuthenticationController sharedInstance] fingerglyph].frame;
				fingerframe.size.height = [%c(SBIconView) defaultIconSize].height - 10;
				fingerframe.size.width = [%c(SBIconView) defaultIconSize].width - 10;
				[[ASAuthenticationController sharedInstance] fingerglyph].frame = fingerframe;
				[[ASAuthenticationController sharedInstance] fingerglyph].center = CGPointMake(CGRectGetMidX(imageView.bounds), CGRectGetMidY(imageView.bounds));
				[imageView addSubview:[[ASAuthenticationController sharedInstance] fingerglyph]];
			});
		}
		self.icon = imageView;

		blockPasscode = ([[ASPreferences sharedInstance] securityLevelForApp:identifier] == 2);

		self.useSmallIcon = NO;
	}

	return self;
}

- (void)configure:(BOOL)configure requirePasscodeForActions:(BOOL)requirePasscode {
	if (self.useSmallIcon) {
		[self alertController].title = titleWithSpacingForSmallIcon(self.title);
		self.icon.center = CGPointMake(270/2,34);
	} else {
		[self alertController].title = titleWithSpacingForIcon(self.title);
		self.icon.center = CGPointMake(270/2,41);
	}
	[self alertController].message = self.message;

	UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"com.a3tweaks.asphaleia.stopmonitoring" object:nil];
		[[ASAuthenticationController sharedInstance] setCurrentAuthAlert:nil];
		if (self.delegate && [self.delegate respondsToSelector:@selector(authAlertView:dismissed:authorised:fingerprint:)]) {
			[(id)self.delegate authAlertView:self dismissed:YES authorised:NO fingerprint:nil];
		}

		[self dismiss];
	}];

	UIAlertAction *passcodeButton = [UIAlertAction actionWithTitle:@"Passcode" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"com.a3tweaks.asphaleia.stopmonitoring" object:nil];
		[[ASAuthenticationController sharedInstance] setCurrentAuthAlert:nil];
		if (self.delegate) {
			SBIconView *icon = [self.icon isKindOfClass:%c(SBIconView)] ? (SBIconView *)self.icon : nil;
			id delegateReference = self.delegate;
			[[ASPasscodeHandler sharedInstance] showInKeyWindowWithPasscode:[[ASPreferences sharedInstance] getPasscode] iconView:icon eventBlock:^void(BOOL authenticated){
				if (authenticated && [delegateReference respondsToSelector:@selector(authAlertView:dismissed:authorised:fingerprint:)]) {
					[(id)delegateReference authAlertView:self dismissed:YES authorised:YES fingerprint:nil];
				}
			}];
		}

		[self dismiss];
	}];

	[[self alertController] addAction:cancelButton];
	if (!blockPasscode) {
		[[self alertController] addAction:passcodeButton];
	}

	[self addSubviewToAlert:self.icon];
}

- (BOOL)shouldShowInLockScreen {
	return NO;
}

- (void)show {
	if ([[ASAuthenticationController sharedInstance] currentAuthAlert]) {
		[[[ASAuthenticationController sharedInstance] currentAuthAlert] dismiss];
	}

	[[ASAuthenticationController sharedInstance] setCurrentAuthAlert:self];

	NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
	if ([[ASPreferences sharedInstance] touchIDEnabled]) {
		[center postNotificationName:@"com.a3tweaks.asphaleia.startmonitoring" object:nil];
	}

	[center addObserver:self selector:@selector(receivedNotification:) name:@"com.a3tweaks.asphaleia.fingerdown" object:nil];
	[center addObserver:self selector:@selector(receivedNotification:) name:@"com.a3tweaks.asphaleia.fingerup" object:nil];
	[center addObserver:self selector:@selector(receivedNotification:) name:@"com.a3tweaks.asphaleia.authsuccess" object:nil];
	[center addObserver:self selector:@selector(receivedNotification:) name:@"com.a3tweaks.asphaleia.authfailed" object:nil];

	[super show];
}

- (void)receivedNotification:(NSNotification *)notification {
	NSString *name = [notification name];
	if ([name isEqualToString:@"com.a3tweaks.asphaleia.fingerdown"]) {
		if (self.useSmallIcon) {
			[self alertController].title = titleWithSpacingForSmallIcon(@"Scanning finger...");
		} else {
			[self alertController].title = titleWithSpacingForIcon(@"Scanning finger...");
		}

		self.resetFingerprintTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:NO block:^(NSTimer *timer) {
			if (self.useSmallIcon) {
				[self alertController].title = titleWithSpacingForSmallIcon(self.title);
			} else {
				[self alertController].title = titleWithSpacingForIcon(self.title);
			}
		}];

		if ([[ASAuthenticationController sharedInstance] fingerglyph]) {
			[[[ASAuthenticationController sharedInstance] fingerglyph] setState:1 animated:YES completionHandler:nil];
		}
	} else if ([name isEqualToString:@"com.a3tweaks.asphaleia.fingerup"]) {
		if ([[ASAuthenticationController sharedInstance] fingerglyph]) {
			[[[ASAuthenticationController sharedInstance] fingerglyph] setState:0 animated:YES completionHandler:nil];
		}
	} else if ([name isEqualToString:@"com.a3tweaks.asphaleia.authsuccess"]) {
		if ([[ASAuthenticationController sharedInstance] fingerglyph]) {
			[[[ASAuthenticationController sharedInstance] fingerglyph] setState:0 animated:YES completionHandler:nil];
		}

		if (self.delegate && [self.delegate respondsToSelector:@selector(authAlertView:dismissed:authorised:fingerprint:)]) {
			[(id)self.delegate authAlertView:self dismissed:NO authorised:YES fingerprint:[notification userInfo][@"fingerprint"]];
		}
	} else if ([name isEqualToString:@"com.a3tweaks.asphaleia.authfailed"]) {
		if (self.useSmallIcon) {
			[self alertController].title = titleWithSpacingForSmallIcon(self.title);
		} else {
			[self alertController].title = titleWithSpacingForIcon(self.title);
		}
		if ([[ASAuthenticationController sharedInstance] fingerglyph]) {
			[[[ASAuthenticationController sharedInstance] fingerglyph] setState:0 animated:YES completionHandler:nil];
		}
	}
}

- (void)dismiss {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	if (self.resetFingerprintTimer) {
		[self.resetFingerprintTimer invalidate];
		self.resetFingerprintTimer = nil;
	}
	
	[super dismiss];
}

- (UIImage *)colouriseImage:(UIImage *)origImage withColour:(UIColor *)tintColour {
	UIGraphicsBeginImageContextWithOptions(origImage.size, NO, origImage.scale);
	CGContextRef imgContext = UIGraphicsGetCurrentContext();
	CGRect imageRect = CGRectMake(0, 0, origImage.size.width, origImage.size.height);
	CGContextScaleCTM(imgContext, 1, -1);
	CGContextTranslateCTM(imgContext, 0, -imageRect.size.height);
	CGContextSaveGState(imgContext);
	CGContextClipToMask(imgContext, imageRect, origImage.CGImage);
	[tintColour set];
	CGContextFillRect(imgContext, imageRect);
	CGContextRestoreGState(imgContext);
	CGContextSetBlendMode(imgContext, kCGBlendModeMultiply);
	CGContextDrawImage(imgContext, imageRect, origImage.CGImage);
	UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return finalImage;
}

@end
