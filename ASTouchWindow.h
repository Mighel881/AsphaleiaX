#import <UIKit/UIKit.h>
#import <SpringBoard/SBIconView.h>

@class ASTouchWindow;

typedef void (^ASTouchWindowTouchBlockedEvent) (ASTouchWindow *touchWindow, BOOL blockedTouch);

@interface ASTouchWindow : UIWindow {
	BOOL touchedOutside;
}

@property (strong, nonatomic) SBIconView *viewToAllowTouchIn;
@property (copy, nonatomic) ASTouchWindowTouchBlockedEvent handler;

- (void)blockTouchesAllowingTouchInView:(SBIconView *)touchView touchBlockedHandler:(ASTouchWindowTouchBlockedEvent)handler;

@end
