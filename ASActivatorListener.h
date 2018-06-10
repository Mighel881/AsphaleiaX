#import <UIKit/UIKit.h>
#import <libactivator/libactivator.h>

typedef void (^ASActivatorListenerEventHandler) (LAEvent *event, BOOL abortEventCalled);

@interface ASActivatorListener : NSObject <LAListener> {
	NSData *smallIconData;
}

@property (copy, nonatomic) ASActivatorListenerEventHandler eventHandler;

+ (instancetype)sharedInstance;

- (void)load;
- (void)unload;

@end
