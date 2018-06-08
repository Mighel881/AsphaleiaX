#import <Preferences/PSRootController.h>

@class PSSpecifier;

@interface PSRootController () {
    PSSpecifier *_specifier;
}

- (PSSpecifier *)specifier;
- (void)setSpecifier:(PSSpecifier *)specifier;

@end