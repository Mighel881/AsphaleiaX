#import <UIKit/UIKit.h>
#import <AppSupport/CPDistributedMessagingCenter.h>

@interface ASXPCHandler : NSObject {
	CPDistributedMessagingCenter *_messagingServer;
}

@property BOOL slideUpControllerActive;
+ (instancetype)sharedInstance;
- (NSDictionary *)handleMessageNamed:(NSString *)name withUserInfo:(NSDictionary *)userinfo;
@end
