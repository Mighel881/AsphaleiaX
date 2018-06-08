#import "BiometricKitDelegate.h"

@class BiometricKitIdentity;

@interface BiometricKit : NSObject

+ (BiometricKit *)manager;

@property (assign, nonatomic) id<BiometricKitDelegate> delegate;

- (NSArray<BiometricKitIdentity *> *)identities:(id)object;

- (BOOL)isTouchIDCapable;

@end