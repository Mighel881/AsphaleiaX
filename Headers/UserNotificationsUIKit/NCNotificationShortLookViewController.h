#import <UserNotificationsUIKit/NCNotificationViewController.h>

@class NCNotificationShortLookView;

@interface NCNotificationShortLookViewController : NCNotificationViewController {
		UIView *_contextDefiningContainerView;
}

- (NCNotificationShortLookView *)_notificationShortLookViewIfLoaded;
- (CGRect)_frameForTransitionViewInScrollView;
- (void)_updateScrollViewContentSize;

@end