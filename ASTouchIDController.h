/* Modified from Sassoty's code
https://github.com/Sassoty/BioTesting */
#import "Asphaleia.h"
@class ASTouchIDController;

typedef void (^BTTouchIDEventBlock) (ASTouchIDController *controller, id monitor, unsigned event);

#define asphaleiaLogMsg(str) HBLogDebug(@"[Asphaleia] %@",str)

#define TouchIDFingerDown  1
#define TouchIDFingerUp    0
#define TouchIDFingerHeld  2
#define TouchIDMatched     3
#define TouchIDMaybeMatched 4
#define TouchIDNotMatched  9

@interface ASTouchIDController : NSObject <_SBUIBiometricKitInterfaceDelegate> {
	BOOL starting;
	BOOL stopping;
	NSArray *activatorListenerNames;
}
@property (nonatomic, strong) BTTouchIDEventBlock biometricEventBlock;
@property (readonly) BOOL isMonitoring;
@property (readonly) id<_SBUIBiometricKitInterfaceDelegate> oldDelegate;
@property (readonly) id lastMatchedFingerprint;
@property (nonatomic) BOOL shouldBlockLockscreenMonitor;
+ (instancetype)sharedInstance;
- (void)startMonitoring;
- (void)stopMonitoring;
@end
