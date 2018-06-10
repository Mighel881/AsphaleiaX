#import "SBUIPasscodeLockViewBase.h"

@interface SBUIPasscodeLockViewWithKeypad : SBUIPasscodeLockViewBase
@property (strong, nonatomic) UILabel *statusTitleView;

- (instancetype)initWithLightStyle:(BOOL)light;

- (void)_layoutStatusView;
- (void)_luminanceBoostDidChange;
- (void)updateStatusText:(NSString *)text subtitle:(NSString *)subtitle animated:(BOOL)animated;
- (void)resetForFailedPasscode;

@end