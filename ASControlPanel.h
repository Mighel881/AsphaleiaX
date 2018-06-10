#import <UIKit/UIKit.h>
#import "ASAlert.h"
#import <libactivator/libactivator.h>

@interface ASControlPanel : NSObject <LAListener, ASAlertDelegate> {
	NSData *smallIconData;
}
+ (instancetype)sharedInstance;
- (void)load;
- (void)unload;
@end
