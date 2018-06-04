#import "Switch.h"
#import "../ASPreferences.h"

@interface ASPreferences ()
@property (readwrite) BOOL asphaleiaDisabled;
@property (readwrite) BOOL itemSecurityDisabled;
@end

@implementation AsphaleiaFlipswitchSwitch

- (instancetype)init {
	self = [super init];
	if (self) {
		loadPreferences();
	}

	return self;
}

- (NSString *)titleForSwitchIdentifier:(NSString *)switchIdentifier {
	return @"Asphaleia";
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
	return (![ASPreferences sharedInstance].asphaleiaDisabled) ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
	switch (newState) {
		case FSSwitchStateIndeterminate:
			break;
		case FSSwitchStateOn:
			[ASPreferences sharedInstance].asphaleiaDisabled = NO;
			break;
		case FSSwitchStateOff:
			[ASPreferences sharedInstance].asphaleiaDisabled = YES;
			break;
	}
}

@end
