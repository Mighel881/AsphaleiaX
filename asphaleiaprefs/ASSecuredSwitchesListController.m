#import "ASSecuredSwitchesListController.h"
#import "ASRootListController.h"
#import <Flipswitch/Flipswitch.h>
#import <Preferences/PSSpecifier.h>

@implementation ASSecuredSwitchesListController

- (NSMutableArray <PSSpecifier *> *)specifiers {
	return nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	asphaleiaSettings = [NSMutableDictionary dictionaryWithContentsOfFile:kPreferencesPath];
	securedSwitches = [asphaleiaSettings objectForKey:@"securedSwitches"] ? asphaleiaSettings[@"securedSwitches"] : [NSMutableDictionary dictionary];
	switchNames = [NSMutableDictionary dictionary];

	for (NSString *identifier in [FSSwitchPanel sharedPanel].sortedSwitchIdentifiers) {
		switchNames[identifier] = [[FSSwitchPanel sharedPanel] titleForSwitchIdentifier:identifier];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ASFlipswitchCell"];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;

	UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
	[switchview addTarget:self action:@selector(updateSwitchAtIndexPath:) forControlEvents:UIControlEventValueChanged];
	switchview.tag = indexPath.row;

	NSString *key = [FSSwitchPanel sharedPanel].sortedSwitchIdentifiers[indexPath.row];
	cell.textLabel.text = switchNames[key];
	[switchview setOn:[securedSwitches[key] boolValue] animated:NO];
	cell.accessoryView = switchview;
	return cell;
}

- (void)updateSwitchAtIndexPath:(UISwitch *)sender {
	securedSwitches[[FSSwitchPanel sharedPanel].sortedSwitchIdentifiers[sender.tag]] = @(sender.on);
	asphaleiaSettings[@"securedSwitches"] = securedSwitches;
	[asphaleiaSettings writeToFile:kPreferencesPath atomically:YES];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.a3tweaks.asphaleia/ReloadPrefs"), NULL, NULL, YES);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [FSSwitchPanel sharedPanel].sortedSwitchIdentifiers.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return;
}

- (UIView *)_tableView:(UITableView *)tableView viewForCustomInSection:(NSInteger)section isHeader:(BOOL)isHeader {
	return nil;
}

- (CGFloat)_tableView:(UITableView *)tableView heightForCustomInSection:(NSInteger)section isHeader:(BOOL)isHeader {
	return 0.0f;
}

@end
