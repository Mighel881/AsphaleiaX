#import "_SBUIBiometricKitInterfaceDelegate.h"
#import <BiometricKit/BiometricKitDelegate.h>

@interface _SBUIBiometricKitInterface : NSObject <BiometricKitDelegate>
@property (assign, nonatomic) id<_SBUIBiometricKitInterfaceDelegate> delegate;
- (void)cancel;
- (NSInteger)detectFingerWithOptions:(id)options;
- (NSInteger)matchWithMode:(NSUInteger)mode andCredentialSet:(id)credentialSet;
- (BOOL)hasEnrolledIdentities;

- (void)matchResult:(id)result withDetails:(id)details;

@end