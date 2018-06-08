#import <Preferences/PSSpecifier.h>

@interface PSSpecifier ()
@property (assign, nonatomic) Class editPaneClass;

- (BOOL)isEqualToSpecifier:(PSSpecifier *)specifier;

@end