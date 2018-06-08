#import <Preferences/PSTableCell.h>
#import <Preferences/PSHeaderFooterView.h>

@interface AsphaleiaTitleCell : PSTableCell <PSHeaderFooterView>
@property (strong, nonatomic) UILabel *tweakTitle;
@property (strong, nonatomic) UILabel *tweakSubtitle;
@property (strong, nonatomic) UILabel *tweakThankSubtitle;

@end
