#import "ASSecuredSettingsListController.h"
#import "ASRootListController.h"
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#import <PreferencesUI/PSUIPrefsListController.h>
#import <PreferencesUI/PSUIPrefsRootController+Private.h>

@implementation ASSecuredSettingsListController {
	PSUIPrefsListController *_rootListController;
}

- (NSMutableArray <PSSpecifier *> *)specifiers {
	return nil;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	PSUIPrefsRootController *navigationController = (PSUIPrefsRootController *)self.navigationController;
	_rootListController = [navigationController rootListController];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	settingsPanelNames = [NSMutableArray array];
	asphaleiaSettings = [NSMutableDictionary dictionaryWithContentsOfFile:kPreferencesPath];
	securedSettings = [asphaleiaSettings objectForKey:@"securedPanels"] ? asphaleiaSettings[@"securedPanels"] : [NSMutableDictionary dictionary];
}

- (NSInteger)getRowIndexFromAllRows:(NSIndexPath *)indexPath {
	int total = 0;
	for (int i = 0; i < indexPath.section; i++) {
		total += [self tableView:[self table] numberOfRowsInSection:i];
	}
	total += indexPath.row;
	return total;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [_rootListController tableView:[_rootListController table] cellForRowAtIndexPath:indexPath];
	if (!cell) { // Invalid indexPath.
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ASSettingsCell"];
		return cell;
	}

	if ([cell.accessoryView isKindOfClass:[UISwitch class]]) {
		cell.userInteractionEnabled = NO;
		cell.textLabel.enabled = NO;
		cell.detailTextLabel.enabled = NO;
		[(UISwitch *)cell.accessoryView setEnabled:NO];
	}
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];

	NSString *identifier = ((PSTableCell *)cell).specifier.identifier;
	if (identifier && ![settingsPanelNames containsObject:identifier]) {
		[settingsPanelNames insertObject:identifier atIndex:[self getRowIndexFromAllRows:indexPath]];
	}

	[switchview addTarget:self action:@selector(updateSwitchAtIndexPath:) forControlEvents:UIControlEventValueChanged];
	switchview.tag = [self getRowIndexFromAllRows:indexPath];
	[switchview setOn:[securedSettings[settingsPanelNames[[self getRowIndexFromAllRows:indexPath]]] boolValue] animated:NO];

	cell.detailTextLabel.text = nil;
	cell.accessoryView = switchview;
	return cell;
}

- (void)updateSwitchAtIndexPath:(UISwitch *)sender {
	securedSettings[settingsPanelNames[sender.tag]] = @(sender.on);
	asphaleiaSettings[@"securedPanels"] = securedSettings;
	[asphaleiaSettings writeToFile:kPreferencesPath atomically:YES];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.a3tweaks.asphaleia/ReloadPrefs"), NULL, NULL, YES);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [_rootListController numberOfSectionsInTableView:[_rootListController table]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [_rootListController tableView:[_rootListController table] numberOfRowsInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return nil;
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
