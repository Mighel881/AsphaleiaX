#import "SBIconLabelView.h"

@class SBIconLabelImageParameters;

@interface SBIconLegibilityLabelView : UIView <SBIconLabelView>
@property (strong, nonatomic) SBIconLabelImageParameters *imageParameters;

- (void)updateIconLabelWithSettings:(id)settings imageParameters:(SBIconLabelImageParameters *)parameters;

@end