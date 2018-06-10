#import "ASAlert.h"
#import <BiometricKit/BiometricKitIdentity.h>

@class ASAuthenticationAlert;

@protocol ASAuthenticationAlertDelegate <ASAlertDelegate>
- (void)authAlertView:(ASAuthenticationAlert *)alertView dismissed:(BOOL)dismissed authorised:(BOOL)authorised fingerprint:(BiometricKitIdentity *)fingerprint;
@end

@interface ASAuthenticationAlert : ASAlert
@property (strong, nonatomic) UIView *icon;
@property (strong, nonatomic) NSTimer *resetFingerprintTimer;
@property (assign, nonatomic) BOOL useSmallIcon;

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message icon:(UIView *)icon smallIcon:(BOOL)useSmallIcon delegate:(id<ASAuthenticationAlertDelegate>)delegate;
- (instancetype)initWithApplication:(NSString *)identifier message:(NSString *)message delegate:(id<ASAuthenticationAlertDelegate>)delegate;

@end
