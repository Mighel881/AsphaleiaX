#import <UIKit/UIKit.h>
#import <libactivator/libactivator.h>
#import <SpringBoard/SBIconView+Private.h>
#import <SpringBoardUIServices/SBUIPasscodeLockViewDelegate.h>

typedef void (^ASPasscodeHandlerEventBlock) (BOOL authenticated);

@interface ASPasscodeHandler : NSObject <SBUIPasscodeLockViewDelegate>
@property (copy, readonly, nonatomic) NSString *passcode;
+ (instancetype)sharedInstance;

- (void)showInKeyWindowWithPasscode:(NSString *)passcode iconView:(SBIconView *)iconView eventBlock:(ASPasscodeHandlerEventBlock)eventBlock;
- (void)dismissPasscodeView;

@end
