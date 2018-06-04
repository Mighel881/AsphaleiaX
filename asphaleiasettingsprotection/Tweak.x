#import <UIKit/UIKit.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSTableCell.h>
#import "../ASCommon.h"
#import "../ASPreferences.h"

@interface PSUIPrefsListController : PSListController

@end

%hook PSUIPrefsListController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (![[ASPreferences sharedInstance] requiresSecurityForPanel:((PSTableCell *)[tableView cellForRowAtIndexPath:indexPath]).specifier.identifier]) {
		%orig;
		return;
	}

	[[ASCommon sharedInstance] authenticateFunction:ASAuthenticationAlertSettingsPanel dismissedHandler:^(BOOL wasCancelled) {
		if (!wasCancelled) {
			%orig;
		} else {
			[tableView deselectRowAtIndexPath:indexPath animated:YES];
		}
	}];
}

%end

%ctor {
	loadPreferences();
}
