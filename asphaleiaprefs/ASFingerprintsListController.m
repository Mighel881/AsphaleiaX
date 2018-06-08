#import "ASFingerprintsListController.h"
#import "ASRootListController.h"
#import <dlfcn.h>
#import <BiometricKit/BiometricKit.h>
#import <BiometricKit/BiometricKitIdentity.h>
#import <Cephei/CompactConstraint.h>
#import <Preferences/PSSpecifier.h>

@implementation ASFingerprintsListController

- (NSMutableArray <PSSpecifier *> *)specifiers {
	return nil;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	dlopen("/System/Library/PrivateFrameworks/BiometricKit.framework/BiometricKit", RTLD_LAZY);
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	asphaleiaSettings = [NSMutableDictionary dictionaryWithContentsOfFile:kPreferencesPath];
	UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 20, 0);
	[self table].contentInset = insets;
	fingerprintSecurity = asphaleiaSettings[@"fingerprintSettings"] ? [asphaleiaSettings[@"fingerprintSettings"] mutableCopy] : [NSMutableDictionary dictionary];
}

- (NSString *)keyForSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"securedItemsFingerprints";
		case 1:
			return @"securityModifiersFingerprints";
		case 2:
			return @"advancedSecurityFingerprints";
		default:
			return nil;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ASFingerprintCell"];
	cell.selectionStyle = UITableViewCellSelectionStyleDefault;

	NSArray<BiometricKitIdentity *> *identities = [[NSClassFromString(@"BiometricKit") manager] identities:nil];
	cell.textLabel.text = identities[indexPath.row].name;
	cell.accessoryType = [fingerprintSecurity[[self keyForSection:indexPath.section]][cell.textLabel.text] boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	NSString *fingerprintAccessKey = [self keyForSection:indexPath.section];
	BOOL cellEnabled = (cell.accessoryType == UITableViewCellAccessoryCheckmark);
	cell.accessoryType = cellEnabled ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;

	NSMutableDictionary *fingerprintSettingsDict = [fingerprintSecurity objectForKey:fingerprintAccessKey] ? fingerprintSecurity[fingerprintAccessKey] : [NSMutableDictionary dictionary];
	fingerprintSecurity[cell.textLabel.text] = @(!cellEnabled);
	fingerprintSecurity[fingerprintAccessKey] = fingerprintSettingsDict;

	asphaleiaSettings[@"fingerprintSettings"] = fingerprintSecurity;
	[asphaleiaSettings writeToFile:kPreferencesPath atomically:YES];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.a3tweaks.asphaleia/ReloadPrefs"), NULL, NULL, YES);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[NSClassFromString(@"BiometricKit") manager] identities:nil].count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	UIView *headerView = [[UIView alloc] init];
	UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	headerLabel.backgroundColor = [UIColor clearColor];
	headerLabel.opaque = YES;
	headerLabel.textColor = [UIColor colorWithRed:0.427f green:0.427f blue:0.447f alpha:1.0f];

	headerLabel.font = [UIFont systemFontOfSize:13];
	headerLabel.frame = CGRectMake(15.0, 7.5, CGRectGetWidth([UIScreen mainScreen].bounds) - 30.f,40.0);
	//Use CompactConstraint
	//[headerLabel addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:[headerLabel(==%f)]",[[UIScreen mainScreen] bounds].size.width-30.f] options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerLabel)]];

	[headerLabel hb_addConstraintsWithVisualFormat:[NSString stringWithFormat:@"H:[headerLabel(==%f)]",[[UIScreen mainScreen] bounds].size.width-30.f] options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerLabel)];

	//[headerLabel addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[headerLabel(==40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerLabel)]];
	[headerLabel hb_addConstraintsWithVisualFormat:@"V:[headerLabel(==40)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerLabel)];

	headerLabel.numberOfLines = 0;
	switch (section) {
		case 0:
			headerLabel.text = @"Fingerprints that can access secured items.";
			break;
		case 1:
			headerLabel.text = @"Fingerprints that can access control panel and dynamic selection.";
			break;
		case 2:
			headerLabel.text = @"Fingerprints that can access advanced security.";
			break;
		default:
			break;
	}

	[headerLabel sizeToFit];
	[headerView addSubview:headerLabel];

	return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if (section == 1) {
		return 45.f;
	} else {
		return 29.f;
	}
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 44.f;
}

- (NSInteger)tableView:(UITableView *)tableView titleAlignmentForFooterInSection:(NSInteger)section {
	return 1;
}

- (UIView *)_tableView:(UITableView *)tableView viewForCustomInSection:(NSInteger)section isHeader:(BOOL)isHeader {
	return nil;
}

- (CGFloat)_tableView:(UITableView *)tableView heightForCustomInSection:(NSInteger)section isHeader:(BOOL)isHeader {
	return 0.0f;
}

@end
