@class _SBUIBiometricKitInterface;

@protocol _SBUIBiometricKitInterfaceDelegate <NSObject>
@required

// Hehe we dont use that one :) - (void)biometricKitInterface:(_SBUIBiometricKitInterface *)interface enrolledIdentitiesDidChange:(BOOL)didChange;
- (void)biometricKitInterface:(_SBUIBiometricKitInterface *)interface handleEvent:(NSUInteger)event;

@end