@interface SPUISearchHeader : UIView <UITextFieldDelegate>

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
- (void)textFieldDidBeginEditing:(UITextField *)textField;
- (BOOL)textFieldShouldClear:(UITextField *)textField;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;

- (void)focusSearchField;
- (void)unfocusSearchField;

@end