#import <UIKit/UIKit.h>
#import <SpringBoardUI/SBAlertItem+Private.h>

@class ASAlert;

@protocol ASAlertDelegate <NSObject>
@optional
- (void)willPresentAlertView:(ASAlert *)alertView;
@end

@interface ASAlert : SBAlertItem
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *message;
@property (nonatomic, weak) id<ASAlertDelegate> delegate;
@property (nonatomic) NSInteger tag;

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id<ASAlertDelegate>)delegate;
- (void)addButtonWithTitle:(NSString *)buttonTitle;
- (void)removeButtonWithTitle:(NSString *)buttonTitle;
- (void)setAboveTitleSubview:(UIView *)view;
- (void)show;

- (NSArray *)allSubviewsOfView:(UIView *)view;
- (void)addSubviewToAlert:(UIView *)view;

@end
