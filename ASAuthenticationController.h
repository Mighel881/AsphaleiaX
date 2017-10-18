#import <UIKit/UIKit.h>
#import "Asphaleia.h"
#import "ASTouchIDController.h"
#import "ASTouchWindow.h"
#import "ASCommon.h"
#import "ASAuthenticationAlert.h"

@interface ASAuthenticationController : NSObject <ASAuthenticationAlertDelegate> {
	ASCommonAuthenticationHandler authHandler;
	NSString *currentAuthAppBundleID;
}
@property (strong, nonatomic) ASAuthenticationAlert *currentAuthAlert;
@property (strong, nonatomic) SBIconView *currentHSIconView;
@property (strong, nonatomic) PKGlyphView *fingerglyph;
@property (copy, nonatomic) NSString *appUserAuthorisedID;
@property (nonatomic) BOOL catchAllIgnoreRequest;
@property (copy, nonatomic) NSString *temporarilyUnlockedAppBundleID;
@property (strong, nonatomic) ASTouchWindow *anywhereTouchWindow;
+ (instancetype)sharedInstance;
- (void)initialiseGlyphIfRequired;
- (ASAuthenticationAlert *)returnAppAuthenticationAlertWithApplication:(NSString *)appIdentifier customMessage:(NSString *)customMessage delegate:(id<ASAuthenticationAlertDelegate>)delegate;
- (ASAuthenticationAlert *)returnAuthenticationAlertOfType:(ASAuthenticationAlertType)alertType delegate:(id<ASAuthenticationAlertDelegate>)delegate;
- (BOOL)authenticateAppWithDisplayIdentifier:(NSString *)appIdentifier customMessage:(NSString *)customMessage dismissedHandler:(ASCommonAuthenticationHandler)handler;
- (BOOL)authenticateFunction:(ASAuthenticationAlertType)alertType dismissedHandler:(ASCommonAuthenticationHandler)handler;
- (BOOL)authenticateAppWithIconView:(SBIconView *)iconView authenticatedHandler:(ASCommonAuthenticationHandler)handler;
- (void)dismissAnyAuthenticationAlerts;
- (NSArray *)allSubviewsOfView:(UIView *)view;

@end
