#import "SBUIPasscodeLockViewWithKeypad.h"

@interface SBUIPasscodeLockViewSimpleFixedDigitKeypad : SBUIPasscodeLockViewWithKeypad
@property (readonly, nonatomic) NSUInteger numberOfDigits;

- (instancetype)initWithLightStyle:(BOOL)light numberOfDigits:(NSUInteger)digits;
- (instancetype)initWithLightStyle:(BOOL)light;

- (CGFloat)_entryFieldBottomYDistanceFromNumberPadTopButton;

@end