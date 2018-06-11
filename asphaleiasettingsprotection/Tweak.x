#import "../ASCommon.h"
#import "../ASPreferences.h"
#import <Preferences/PSSpecifier+Private.h>
#import <Preferences/DevicePINSetupController.h>
#import <PreferencesUI/PSUIPrefsListController.h>

%hook PSUIPrefsListController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	/// Protect Asphaleia pane
    PSSpecifier *specifier = [self specifierAtIndex:[self indexForIndexPath:indexPath]];
    PSSpecifier *asphaleiaSpecifier = [self specifierForID:@"ASPHALEIAX"];

    // Don't show if first time
    NSString *passcode = [[ASPreferences sharedInstance] getPasscode];

    if (specifier && (specifier == asphaleiaSpecifier) && passcode) {
        PSSpecifier *sidebarSpecifier = [self _sidebarSpecifierForCategoryController];
        if (sidebarSpecifier != specifier) {
            // Configure specifier
            [specifier setProperty:@(3) forKey:@"mode"];
            [specifier setProperty:self forKey:@"PINControllerDelegate"];
            
            // Configure PINController
            DevicePINSetupController *controller = [[DevicePINSetupController alloc] init];
            controller.allowOptionsButton = NO;
            controller.parentController = self;
            controller.specifier = specifier;
            [self showController:controller];
            return;
        }
    }

	// General settings panel protection
	if (![[ASPreferences sharedInstance] requiresSecurityForPanel:((PSTableCell *)[tableView cellForRowAtIndexPath:indexPath]).specifier.identifier]) {
		%orig;
		return;
	}

	[[ASCommon sharedInstance] authenticateFunction:ASAuthenticationAlertSettingsPanel dismissedHandler:^(BOOL wasCancelled) {
		if (wasCancelled) {
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
		} else {
			%orig;
		}
	}];
}

%end

%ctor {
	loadPreferences();
}
