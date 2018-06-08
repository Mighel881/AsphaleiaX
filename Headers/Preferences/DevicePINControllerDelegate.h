@class DevicePINController;

@protocol DevicePINControllerDelegate <NSObject>
@optional
- (void)devicePINControllerDidDismissPINPane:(id)pinPane;
- (void)devicePINController:(DevicePINController *)PINController didAcceptSetPIN:(NSString *)PIN;
- (void)didAcceptSetPIN;
- (void)devicePINController:(DevicePINController *)PINController didAcceptChangedPIN:(NSString *)PIN;
- (void)didAcceptChangedPIN;
- (void)willAcceptEnteredPIN;
- (void)didAcceptEnteredPIN:(NSString *)PIN;
- (void)didAcceptEnteredPIN;
- (void)didAcceptRemovePIN;
- (void)devicePINController:(DevicePINController *)PINController shouldAcceptPIN:(NSString *)PIN withCompletion:(id)completion;
- (void)willCancelEnteringPIN;
- (void)didCancelEnteringPIN;

@end