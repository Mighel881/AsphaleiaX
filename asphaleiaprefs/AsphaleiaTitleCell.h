#import <Preferences/PSTableCell.h>

@protocol PreferencesTableCustomView
- (id)initWithSpecifier:(id)arg1;

@optional
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1;
- (CGFloat)preferredHeightForWidth:(CGFloat)arg1 inTableView:(id)arg2;
@end

@interface PSTableCell ()
- (id)initWithStyle:(int)style reuseIdentifier:(id)arg2;
@end

@interface AsphaleiaTitleCell : PSTableCell <PreferencesTableCustomView>
@property (strong, nonatomic) UILabel *tweakTitle;
@property (strong, nonatomic) UILabel *tweakSubtitle;
@property (strong, nonatomic) UILabel *tweakThankSubtitle;

@end
