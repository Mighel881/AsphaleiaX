@class SBUIPasscodeLockViewBase;

@protocol SBUIPasscodeLockViewDelegate <NSObject>
@optional

- (void)passcodeLockViewPasscodeDidChange:(SBUIPasscodeLockViewBase *)passcodeLockView;
- (void)passcodeLockViewPasscodeEntered:(SBUIPasscodeLockViewBase *)passcodeLockView;
- (void)passcodeLockViewCancelButtonPressed:(SBUIPasscodeLockViewBase *)passcodeLockView;
- (void)passcodeLockViewEmergencyCallButtonPressed:(SBUIPasscodeLockViewBase *)passcodeLockView;
- (void)passcodeLockViewPasscodeEnteredViaMesa:(SBUIPasscodeLockViewBase *)passcodeLockView;

@end