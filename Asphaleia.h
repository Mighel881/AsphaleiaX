#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBApplicationIcon.h>
#import <SpringBoard/SBDisplayItem.h>
#import <SpringBoard/SBDisplayLayout.h>
#import <SpringBoard/SBLockScreenManager.h>
#import <UIKit/UIKit.h>
#import <version.h>

@interface BBBulletin : NSObject
- (NSString *)sectionID;
- (id)modalAlertContent;
@end

@interface CAFilter : NSObject
+ (CAFilter*)filterWithName:(NSString*)name;
@end

@interface SBAppSwitcherIconController : NSObject
@property(copy, nonatomic) NSArray *displayLayouts;
@end

@interface SBAppSwitcherSnapshotView : UIView
@property (nonatomic, retain) UIView *obscurityView;
@property(retain, nonatomic) UIImage *deferredUpdateImage;
@property(readonly, copy, nonatomic) SBDisplayItem *displayItem;
@end

@interface SBBannerContainerViewController : UIViewController
@property(readonly, assign, nonatomic) UIView* bannerContextView;
- (CGRect)_bannerFrameForOrientation:(int)orientation;
- (CGRect)_bannerFrame;
- (BBBulletin *)_bulletin;
@end

@interface SBControlCenterController : NSObject
+(id)sharedInstance;
-(void)_endPresentation;
-(void)_beginPresentation;
-(void)presentAnimated:(BOOL)animated;
-(void)presentAnimated:(BOOL)animated completion:(id)completion;
-(void)_presentWithDuration:(double)duration completion:(id)completion;
-(void)dismissAnimated:(BOOL)animated completion:(id)completion;
-(void)dismissAnimated:(BOOL)animated;
-(void)_revealSlidingViewToHeight:(float)height;
-(void)_finishPresenting:(BOOL)presenting completion:(id)completion;
-(void)_updateRevealPercentage:(float)percentage;
-(void)cancelTransition;
-(void)abortAnimatedTransition;
@end

@interface SBSwitchAppList : NSObject
@property (nonatomic,retain) NSArray * list;              //@synthesize list=_list - In the implementation block
- (BOOL)containsBundleID:(id)arg1;
@end

@interface SBWorkspaceApplication : NSObject
@property (nonatomic,retain) SBApplication * application;
@property (nonatomic,copy,readonly) NSString * bundleIdentifier;
@end

@interface SBWorkspaceApplicationTransitionContext : NSObject
@property (nonatomic,retain) SBWorkspaceApplication *activatingApplication;
@end

@interface SBSwitchAppSystemGestureWorkspaceTransaction : NSObject {
		SBWorkspaceApplicationTransitionContext *_currentTransitionContext;
}
@property (nonatomic,copy) SBSwitchAppList * switchAppList;
@end

@interface SBIcon : NSObject
// 8.4+
-(NSString *)displayNameForLocation:(int)location;
// 8.3+
-(void)launchFromLocation:(int)location context:(id)context;
// 8.1 and lower
-(void)launchFromLocation:(int)location;
-(NSString *)displayName;
// All
- (BOOL)isFolderIcon;
- (BOOL)isApplicationIcon;
-(NSString *)applicationBundleID;
-(void)setBadge:(id)badge;
-(id)getIconImage:(int)image;
- (BOOL)isDownloadingIcon;
@end

@interface SBIconController : NSObject
+(id)sharedInstance;
-(BOOL)isEditing;
-(void)setIsEditing:(BOOL)editing;
// Custom method
-(void)asphaleia_resetAsphaleiaIconView;
@end

@interface SBIconLabelImageParameters : NSObject <NSCopying, NSMutableCopying>
@property(readonly, copy, nonatomic) NSString* text;
-(id)mutableCopyWithZone:(NSZone*)zone;
-(id)copyWithZone:(NSZone*)zone;
-(void)setText:(NSString *)text;
-(void)dealloc;
-(id)initWithParameters:(id)parameters;
-(id)init;
@end

@interface SBIconLabelView : UIView {
	SBIconLabelImageParameters* _imageParameters;
}
@property(retain, nonatomic) SBIconLabelImageParameters* imageParameters;
+(void)updateIconLabelView:(id)view withSettings:(id)settings imageParameters:(id)parameters;
+(id)newIconLabelViewWithSettings:(id)settings imageParameters:(id)parameters;
-(void)_checkInImages;
-(void)dealloc;
@end

@interface SBIconImageView : UIImageView
@property(assign, nonatomic) float overlayAlpha;
@end

@interface SBIconView : UIView
@property(assign, nonatomic) int location;
@property(retain, nonatomic) SBIcon* icon;
@property(assign, nonatomic) BOOL isEditing;
-(void)setIsGrabbed:(BOOL)grabbed;
-(void)setHighlighted:(BOOL)highlighted;
-(void)setAllowJitter:(BOOL)jitter;
-(BOOL)isHighlighted;
-(void)cancelLongPressTimer;
-(void)setIconImageAndAccessoryAlpha:(float)alpha;
-(SBIconImageView *)_iconImageView;
-(void)setTouchDownInIcon:(BOOL)icon;
-(BOOL)isTouchDownInIcon;
-(void)cancelLongPressTimer;
-(id)initWithContentType:(int)contentType;
-(void)_setIcon:(id)icon animated:(BOOL)animated;
-(void)setLabelAccessoryViewHidden:(BOOL)hidden;
-(void)setLabelHidden:(BOOL)hidden;
-(void)_updateLabel;
-(BOOL)isInDock;
// New method
-(void)asphaleia_updateLabelWithText:(NSString *)text;
@end

@interface SPUISearchHeader : UIView
@property (retain) UIButton *cancelButton;
-(void)cancelButtonClicked:(id)arg1;
-(BOOL)textFieldShouldReturn:(id)arg1 ;
-(void)focusSearchField;
-(void)unfocusSearchField;
@end

@interface SBUIController : NSObject
+(id)sharedInstanceIfExists;
+(id)sharedInstance;
-(BOOL)isAppSwitcherShowing;
-(BOOL)clickedMenuButton;
-(BOOL)handleHomeButtonDoublePressDown;
@end

@interface SpringBoard : NSObject
@property (nonatomic, retain, readonly) SBApplication *_accessibilityFrontMostApplication;
-(void)_revealSpotlight;
-(void)_runHomeScreenIconPullToSpotlight;
-(void)_runHomeScreenIconPullToSpotlightDismiss;
-(void)_applicationOpenURL:(id)url withApplication:(id)application sender:(id)sender publicURLsOnly:(BOOL)only animating:(BOOL)animating activationSettings:(id)settings withResult:(id)result;
-(BOOL)_requestPermissionToOpenURL:(id)openURL withApplication:(id)application sender:(id)sender;
-(void)applicationOpenURL:(id)url;
-(void)_handleGotoHomeScreenShortcut:(id)arg1 ;
@end

@interface SBMainSwitcherViewController : UIViewController
+ (instancetype)sharedInstance;
- (BOOL)toggleSwitcherNoninteractively;
- (BOOL)activateSwitcherNoninteractively;
- (BOOL)dismissSwitcherNoninteractively;
@end

@interface SBBannerController : NSObject
+(id)sharedInstance;
-(BOOL)isShowingBanner;
@end

@interface BiometricKit : NSObject
+(instancetype)manager;
-(id)identities:(id)object;
-(BOOL)isTouchIDCapable;
@end

@interface SBLockScreenManager ()
@property(assign, nonatomic, getter=isUIUnlocking) BOOL UIUnlocking;
@end

@interface UIWindow ()
- (void)_setSecure:(BOOL)arg1;
@end

@interface SBLockScreenSlideUpToAppController : NSObject
- (void)_finishSlideDownWithCompletion:(id)completion;
@end

@interface UIAlertController ()
@property (nonatomic,retain) UIViewController * contentViewController;
@property UIView *_foregroundView;
@end

@interface CAMImageWell : UIButton
@end

@protocol SBUIBiometricEventObserver
-(void)matchResult:(id)result withDetails:(id)details;
@end

@interface SBToAppsWorkspaceTransaction : NSObject
- (_Bool)toAndFromAppsDiffer;
@property(readonly, retain, nonatomic) NSArray *deactivatingApplications;
@property(readonly, retain, nonatomic) NSArray *activatingApplications;
@property(readonly, retain, nonatomic) NSArray *fromApplications;
@property(readonly, retain, nonatomic) NSArray *toApplications;
@end

@interface BiometricKitIdentity : NSObject
-(NSString *)name;
@end

// Auxo LE
@interface AuxoCardView : UIView
@property(readonly, nonatomic) NSString *displayIdentifier;
@end

@interface AuxoCollectionViewCell : NSObject
@property(readonly, nonatomic) AuxoCardView *cardView;
@end

@interface AuxoCollectionView : UICollectionView
- (void)activateApplicationWithDisplayIdentifier:(NSString *)arg1 fromCell:(AuxoCollectionViewCell *)arg2;
@end

@interface PKGlyphView : UIView
@property (nonatomic,copy) UIColor * primaryColor;                          //@synthesize primaryColor=_primaryColor - In the implementation block
@property (nonatomic,copy) UIColor * secondaryColor;                        //@synthesize secondaryColor=_secondaryColor - In the implementation block
@property (assign,nonatomic) BOOL fadeOnRecognized;
@property (nonatomic,retain) UIImage * customImage;                         //@synthesize customImage=_customImage - In the implementation block
@property (nonatomic,readonly) long long state;                             //@synthesize state=_state - In the implementation block
+(BOOL)automaticallyNotifiesObserversOfState;
-(id)initWithFrame:(CGRect)arg1 ;
-(id)initWithCoder:(id)arg1 ;
-(void)dealloc;
-(void)layoutSubviews;
-(long long)state;
-(void)setState:(long long)arg1 ;
-(id)initWithStyle:(long long)arg1 ;
-(UIColor *)primaryColor;
-(void)setPrimaryColor:(UIColor *)arg1 ;
-(void)setSecondaryColor:(UIColor *)arg1 ;
-(UIColor *)secondaryColor;
-(void)_startPhoneWiggle;
-(void)_endPhoneWiggle;
-(void)setPrimaryColor:(id)arg1 animated:(BOOL)arg2 ;
-(void)_executeTransitionCompletionHandlers:(BOOL)arg1 ;
-(void)_updatePhoneLayoutWithTransitionIndex:(unsigned long long)arg1 animated:(BOOL)arg2 ;
-(double)_minimumAnimationDurationForStateTransition;
-(void)setState:(long long)arg1 animated:(BOOL)arg2 completionHandler:(/*^block*/id)arg3 ;
-(void)_performTransitionWithTransitionIndex:(unsigned long long)arg1 animated:(BOOL)arg2 ;
-(void)_updatePhoneWiggleIfNecessary;
-(void)_updateCustomImageViewOpacityAnimated:(BOOL)arg1 ;
-(void)_updateCheckViewStateAnimated:(BOOL)arg1 ;
-(void)_finishTransitionForIndex:(unsigned long long)arg1 ;
-(void)_executeAfterMinimumAnimationDurationForStateTransition:(/*^block*/id)arg1 ;
-(void)_updateLastAnimationTimeWithAnimationOfDuration:(double)arg1 ;
-(CGPoint)_phonePositionWhileShownWithRotationPercentage:(double)arg1 ;
-(CATransform3D)_phoneTransformDeltaWhileShownFromRotationPercentage:(double)arg1 toPercentage:(double)arg2 ;
-(CGPoint)_phonePositionDeltaWhileShownFromRotationPercentage:(double)arg1 toPercentage:(double)arg2 ;
-(void)setSecondaryColor:(id)arg1 animated:(BOOL)arg2 ;
-(BOOL)fadeOnRecognized;
-(void)setFadeOnRecognized:(BOOL)arg1 ;
-(void)setCustomImage:(UIImage *)arg1 ;
-(UIImage *)customImage;
@end

@interface SBUIPasscodeLockViewBase : UIView
@property (assign,setter=_setLuminosityBoost:,getter=_luminosityBoost,nonatomic) double luminosityBoost;
@property (nonatomic,readonly) NSString * passcode;
-(void)_evaluateLuminance;
@end

@interface SBUIPasscodeLockViewWithKeypad : SBUIPasscodeLockViewBase
@property (nonatomic,retain) UILabel * statusTitleView;
-(void)setDelegate:(id)arg1 ;
-(id)initWithLightStyle:(BOOL)arg1 ;
-(void)setShowsEmergencyCallButton:(BOOL)arg1 ;
-(void)setBackgroundAlpha:(double)arg1 ;
-(void)_layoutStatusView;
-(void)_luminanceBoostDidChange;
-(void)updateStatusText:(id)arg1 subtitle:(id)arg2 animated:(BOOL)arg3 ;
-(void)resetForFailedPasscode;
@end

@interface SBUIPasscodeLockViewSimpleFixedDigitKeypad : SBUIPasscodeLockViewWithKeypad
@property (nonatomic,readonly) unsigned long long numberOfDigits;              //@synthesize numberOfDigits=_numberOfDigits - In the implementation block
-(id)initWithLightStyle:(BOOL)arg1 numberOfDigits:(unsigned long long)arg2 ;
-(id)initWithLightStyle:(BOOL)arg1 ;
-(id)_newEntryField;
-(double)_entryFieldBottomYDistanceFromNumberPadTopButton;
-(unsigned long long)numberOfDigits;
@end

@interface UIAlertController ()
@end

@interface _SBAlertController : UIAlertController
@end

@interface SBAlertItem : NSObject {
	_SBAlertController* _alertController;
}
- (_SBAlertController*)alertController;
- (void)dismiss;
- (void)configure:(BOOL)arg1 requirePasscodeForActions:(BOOL)arg2;
@end

@protocol _SBUIBiometricKitInterfaceDelegate
@required
- (void)biometricKitInterface:(id)interface handleEvent:(unsigned long long)event;
@end

@interface _SBUIBiometricKitInterface : NSObject
@property (assign,nonatomic) id<_SBUIBiometricKitInterfaceDelegate> delegate;
- (void)cancel;
- (void)setDelegate:(id<_SBUIBiometricKitInterfaceDelegate>)arg1;
- (int)detectFingerWithOptions:(id)arg1 ;
- (int)matchWithMode:(unsigned long long)arg1 andCredentialSet:(id)arg2;
- (BOOL)hasEnrolledIdentities;
@end

@interface SBWiFiManager : NSObject
- (NSString*)currentNetworkName;
@end

@interface NCNotificationShortLookView : UIView
@property (nonatomic,retain) UIImage * icon;
@property (nonatomic,copy) NSString * title;
@property (nonatomic,copy) NSDate * date;
@property (getter=isDateAllDay,nonatomic,readonly) BOOL dateAllDay;
@property (nonatomic,copy) NSTimeZone * timeZone;
@property (nonatomic,copy) NSString * primaryText;
@property (nonatomic,copy) NSString * primarySubtitleText;
@property (nonatomic,copy) NSString * secondaryText;
@property (nonatomic,retain) NSArray * interfaceActions;
@property (nonatomic,retain) UIImage * thumbnail;
@property (nonatomic,copy) NSString * hintText;
@property (nonatomic,retain) UIView * accessoryView;
@property (assign,nonatomic) unsigned long long messageNumberOfLines;
@property (nonatomic,copy) NSString * groupName;
@property (assign,nonatomic) double cornerRadius;
@end

@interface NCNotificationRequest : NSObject
@property (nonatomic,copy,readonly) NSString * sectionIdentifier;                           //@synthesize sectionIdentifier=_sectionIdentifier - In the implementation block
@property (nonatomic,copy,readonly) NSString * notificationIdentifier;                      //@synthesize notificationIdentifier=_notificationIdentifier - In the implementation block
@property (nonatomic,copy,readonly) NSString * threadIdentifier;                            //@synthesize threadIdentifier=_threadIdentifier - In the implementation block
@property (nonatomic,copy,readonly) NSString * categoryIdentifier;                          //@synthesize categoryIdentifier=_categoryIdentifier - In the implementation block
@property (nonatomic,copy,readonly) NSSet * subSectionIdentifiers;                          //@synthesize subSectionIdentifiers=_subSectionIdentifiers - In the implementation block
@property (nonatomic,copy,readonly) NSArray * peopleIdentifiers;                            //@synthesize peopleIdentifiers=_peopleIdentifiers - In the implementation block
@property (nonatomic,copy,readonly) NSString * parentSectionIdentifier;
@end

@interface NCNotificationShortLookViewController : UIViewController {
		UIView* _contextDefiningContainerView;
}
@property (nonatomic,retain) NSString * groupName;
- (NCNotificationShortLookView*)_notificationShortLookViewIfLoaded;
- (CGRect)_frameForTransitionViewInScrollView;
@end
