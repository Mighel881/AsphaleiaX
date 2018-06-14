#import "ASSecuredFoldersListController.h"
#import "ASRootListController.h"
#import <Preferences/PSSpecifier.h>

static NSString *const SBIconStatePath = @"/private/var/mobile/Library/SpringBoard/IconState.plist";

@implementation ASSecuredFoldersListController

- (NSMutableArray <PSSpecifier *> *)specifiers {
	return nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	NSMutableDictionary *iconState = [NSMutableDictionary dictionaryWithContentsOfFile:SBIconStatePath];
	asphaleiaSettings = [NSMutableDictionary dictionaryWithContentsOfFile:kPreferencesPath];
	securedFolders = [asphaleiaSettings objectForKey:@"securedFolders"] ? asphaleiaSettings[@"securedFolders"] : [NSMutableDictionary dictionary];
	[self processDictionaryOrArray:iconState];
}

- (void)processDictionaryOrArray:(id)dictOrArray {
	if (!folderNames) {
		folderNames = [NSMutableArray array];
	}

	if ([dictOrArray isKindOfClass:[NSDictionary class]]) {
		for (NSString *key in [dictOrArray allKeys]){
			id childDictOrArray = dictOrArray[key];
			if ([key isEqualToString:@"displayName"]) {
				[folderNames addObject:dictOrArray[key]];
			} else {
				[self processDictionaryOrArray:childDictOrArray];
			}
		}
	} else if ([dictOrArray isKindOfClass:[NSArray class]]) {
		for (id childDictOrArray in dictOrArray){
			[self processDictionaryOrArray:childDictOrArray];
		}
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ASFolderCell"];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
	[switchview addTarget:self action:@selector(updateSwitchAtIndexPath:) forControlEvents:UIControlEventValueChanged];
	switchview.tag = indexPath.row;
	cell.textLabel.text = folderNames[indexPath.row];
	[switchview setOn:[securedFolders[folderNames[indexPath.row]] boolValue] animated:NO];
	cell.accessoryView = switchview;
	return cell;
}

- (void)updateSwitchAtIndexPath:(UISwitch *)sender {
	securedFolders[folderNames[sender.tag]] = @(sender.on);
	asphaleiaSettings[@"securedFolders"] = securedFolders;
	[asphaleiaSettings writeToFile:kPreferencesPath atomically:YES];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.a3tweaks.asphaleia/ReloadPrefs"), NULL, NULL, YES);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return folderNames.count;
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
