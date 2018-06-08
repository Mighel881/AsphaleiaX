#import <Preferences/PSViewController.h>
#import "DevicePINControllerDelegate.h"

@interface DevicePINController : PSViewController

+ (BOOL)settingEnabled;

@property (weak, nonatomic) id<DevicePINControllerDelegate> pinDelegate;
@property (assign, nonatomic) BOOL hidesNavigationButtons;
@property (assign, nonatomic) BOOL hidesCancelButton;
@property (assign, nonatomic) BOOL shouldDismissWhenDone;
@property (nonatomic, copy) NSString *doneButtonTitle;
@property (assign, nonatomic) BOOL requiresKeyboard; 
@property (assign, nonatomic) NSInteger pinLength; 
@property (assign, nonatomic) BOOL simplePIN; 
@property (assign, getter=isNumericPIN, nonatomic) BOOL numericPIN; 
@property (assign, nonatomic) BOOL allowOptionsButton;

@end