#import <AppSupport/CPDistributedMessagingCenter.h>

@interface ASXPCHandler : NSObject {
	CPDistributedMessagingCenter *_messagingServer;
}
@property BOOL slideUpControllerActive;
+ (instancetype)sharedInstance;
- (void)loadServer;

- (NSDictionary *)handleMessageNamed:(NSString *)name withUserInfo:(NSDictionary *)userinfo;
@end
