#import <UIKit/UIKit.h>
#import "SBUIPasscodeLockViewDelegate.h"
#import <SpringBoardFoundation/SBFLegibilitySettingsProvider.h>

@interface SBUIPasscodeLockViewBase : UIView

@property (weak, nonatomic) id<SBUIPasscodeLockViewDelegate> delegate;
@property (nonatomic, readonly) NSString *passcode;
@property (assign, nonatomic) BOOL showsEmergencyCallButton;
@property (assign, nonatomic) CGFloat backgroundAlpha;
@property (strong, nonatomic) UIColor *customBackgroundColor;
@property (strong, nonatomic) id<SBFLegibilitySettingsProvider> backgroundLegibilitySettingsProvider;
@property (assign, getter=isScreenOn, nonatomic) BOOL screenOn;

- (BOOL)resignFirstResponder;
- (BOOL)becomeFirstResponder;

@end