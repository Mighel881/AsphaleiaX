#import "ASSecuredAppsListController.h"
#import "ASRootListController.h"
#import "ASPerAppProtectionOptions.h"
#import <AppList/AppList.h>
#import <Preferences/PSSpecifier.h>

@implementation ALLinkCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}

	return self;
}

@end

BOOL reload = NO;
void AppListNeedsToReload() {
	reload = YES;
}

@implementation ASSecuredAppsListController

- (NSMutableArray <PSSpecifier *> *)specifiers {
	return nil;
}

- (void)updateDataSource:(NSString *)searchText {
	NSNumber *iconSize = @(ALApplicationIconSizeSmall);

	NSString *enabledList = @"";
	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:kPreferencesPath];
	if (prefs) {
		NSArray *apps = [ALApplicationList sharedApplicationList].applications.allKeys;
		for (NSString *identifier in apps) {
			if (![prefs[[NSString stringWithFormat:@"securedApps-%@-enabled", identifier]] boolValue]) {
				continue;
			}

			enabledList = [enabledList stringByAppendingString:[NSString stringWithFormat:@"'%@',", identifier]];
		}
	}
	enabledList = [enabledList stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
	NSString *filter = (searchText && searchText.length > 0) ? [NSString stringWithFormat:@"displayName beginsWith[cd] '%@'", searchText] : nil;

	if (filter) {
		_dataSource.sectionDescriptors = @[@{ALSectionDescriptorTitleKey: @"Search Results", ALSectionDescriptorCellClassNameKey: @"ALLinkCell", ALSectionDescriptorIconSizeKey: iconSize, ALSectionDescriptorSuppressHiddenAppsKey: @YES, ALSectionDescriptorPredicateKey: filter}];
	} else {
		if ([enabledList isEqual:@""]) {
			_dataSource.sectionDescriptors = @[@{ALSectionDescriptorTitleKey: @"", ALSectionDescriptorCellClassNameKey: @"ALLinkCell", ALSectionDescriptorIconSizeKey: iconSize, ALSectionDescriptorSuppressHiddenAppsKey: @YES, ALSectionDescriptorPredicateKey: [NSString stringWithFormat:@"not bundleIdentifier in {%@}", enabledList]}];
		} else {
			NSDictionary *enabledAppsDescriptor = @{ALSectionDescriptorTitleKey: @"Enabled Applications", ALSectionDescriptorCellClassNameKey: @"ALLinkCell", ALSectionDescriptorIconSizeKey: iconSize, ALSectionDescriptorSuppressHiddenAppsKey: @YES, ALSectionDescriptorPredicateKey: [NSString stringWithFormat:@"bundleIdentifier in {%@}", enabledList]};
			NSDictionary *otherAppsDescriptor = @{ALSectionDescriptorTitleKey: @"Other Applications", ALSectionDescriptorCellClassNameKey: @"ALLinkCell", ALSectionDescriptorIconSizeKey: iconSize, ALSectionDescriptorSuppressHiddenAppsKey: @YES, ALSectionDescriptorPredicateKey: [NSString stringWithFormat:@"not bundleIdentifier in {%@}", enabledList]};
			_dataSource.sectionDescriptors = @[enabledAppsDescriptor, otherAppsDescriptor];
		}
	}

	[_tableView reloadData];
}

- (instancetype)init {
	self = [super init];
	if (self) {
		CGRect bounds = [UIScreen mainScreen].bounds;

		_dataSource = [[ALApplicationTableDataSource alloc] init];

		_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(bounds), CGRectGetHeight(bounds)) style:UITableViewStyleGrouped];
		_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_tableView.delegate = self;
		_tableView.dataSource = _dataSource;
		_dataSource.tableView = _tableView;
		[self updateDataSource:nil];
	}

	return self;
}

- (void)viewDidLoad {
	self.title = @"Applications";
	[self.view addSubview:_tableView];

	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
	if (reload) {
		[self updateDataSource:nil];
		reload = NO;
	}

	[super viewWillAppear:animated];
}


- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

	// Need to mimic what PSListController does when it handles didSelectRowAtIndexPath
	// otherwise the child controller won't load
	ASPerAppProtectionOptions *controller = [[ASPerAppProtectionOptions alloc] initWithAppName:cell.textLabel.text identifier:[_dataSource displayIdentifierForIndexPath:indexPath]];
	controller.rootController = self.rootController;
	controller.parentController = self;

	[self pushController:controller];
	[tableView deselectRowAtIndexPath:indexPath animated:true];
}

@end
