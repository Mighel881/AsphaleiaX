#import <SpringBoard/SBIconView.h>

@class SBIconLegibilityLabelView, SBIconImageView;

@interface SBIconView ()
@property (assign, nonatomic) NSInteger location;
@property (assign, nonatomic) BOOL isEditing;
@property (readonly, nonatomic) SBIconLegibilityLabelView *labelView;

- (SBIconImageView *)_iconImageView;

- (void)setHighlighted:(BOOL)highlighted;
- (BOOL)isHighlighted;

- (void)setTouchDownInIcon:(BOOL)touchDownInIcon;
- (BOOL)isTouchDownInIcon;

- (void)cancelLongPressTimer;
- (void)_updateLabel;

// New method
- (void)asphaleia_updateLabelWithText:(NSString *)text;

@end