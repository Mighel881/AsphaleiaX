#include "ASSecuredAppsListController.h"
#import "ASRootListController.h"
#import "ASPerAppProtectionOptions.h"
#import <Preferences/PSSpecifier.h>
#import <AppList/AppList.h>

@implementation ALLinkCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (!self) {
		return nil;
	}

	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	return self;
}
@end

BOOL reload = NO;
void AppListNeedsToReload() {
	reload = YES;
}

@implementation ASSecuredAppsListController
- (NSArray *)specifiers {
	return nil;
}

- (void)updateDataSource:(NSString*)searchText {
	NSNumber *iconSize = [NSNumber numberWithUnsignedInteger:ALApplicationIconSizeSmall];

	NSString *enabledList = @"";
	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:kPreferencesPath];
	if (prefs) {
	  NSArray *apps = [[ALApplicationList sharedApplicationList] applications].allKeys;
		for (NSString* identifier in apps) {
	    if ([prefs[[NSString stringWithFormat:@"securedApps-%@-enabled",identifier]] boolValue]) {
	        enabledList = [enabledList stringByAppendingString:[NSString stringWithFormat:@"'%@',", identifier]];
	    }
		}
	}
	enabledList = [enabledList stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
	NSString* filter = (searchText && searchText.length > 0) ? [NSString stringWithFormat:@"displayName beginsWith[cd] '%@'", searchText] : nil;

	if (filter) {
		_dataSource.sectionDescriptors = [NSArray arrayWithObjects:
	                                        [NSDictionary dictionaryWithObjectsAndKeys:
	                                         @"Search Results", ALSectionDescriptorTitleKey,
	                                         @"ALLinkCell", ALSectionDescriptorCellClassNameKey,
	                                         iconSize, ALSectionDescriptorIconSizeKey,
	                                         @YES, ALSectionDescriptorSuppressHiddenAppsKey,
	                                         filter, ALSectionDescriptorPredicateKey
	                                         , nil]
	                                        , nil];
	} else {
	  if ([enabledList isEqual:@""]) {
	      _dataSource.sectionDescriptors = [NSArray arrayWithObjects:
	                                    [NSDictionary dictionaryWithObjectsAndKeys:
	                                     @"", ALSectionDescriptorTitleKey,
	                                     @"ALLinkCell", ALSectionDescriptorCellClassNameKey,
	                                     iconSize, ALSectionDescriptorIconSizeKey,
	                                      @YES, ALSectionDescriptorSuppressHiddenAppsKey,
	                                     [NSString stringWithFormat:@"not bundleIdentifier in {%@}", enabledList],
	                                     ALSectionDescriptorPredicateKey
	                                     , nil],
	                                    nil];
	  } else {
	      _dataSource.sectionDescriptors = [NSArray arrayWithObjects:
	                                    [NSDictionary dictionaryWithObjectsAndKeys:
	                                     @"Enabled Applications", ALSectionDescriptorTitleKey,
	                                     @"ALLinkCell", ALSectionDescriptorCellClassNameKey,
	                                     iconSize, ALSectionDescriptorIconSizeKey,
	                                     @YES, ALSectionDescriptorSuppressHiddenAppsKey,
	                                     [NSString stringWithFormat:@"bundleIdentifier in {%@}", enabledList],
	                                     ALSectionDescriptorPredicateKey
	                                     , nil],
	                                    [NSDictionary dictionaryWithObjectsAndKeys:
	                                     @"Other Applications", ALSectionDescriptorTitleKey,
	                                     @"ALLinkCell", ALSectionDescriptorCellClassNameKey,
	                                     iconSize, ALSectionDescriptorIconSizeKey,
	                                     @YES, ALSectionDescriptorSuppressHiddenAppsKey,
	                                     [NSString stringWithFormat:@"not bundleIdentifier in {%@}", enabledList],
	                                     ALSectionDescriptorPredicateKey
	                                     , nil],
	                                    nil];
	  }
	}
	[_tableView reloadData];
}

- (instancetype)init {
	self = [super init];
	if (!self) {
	  return nil;
	}

	CGRect bounds = [UIScreen mainScreen].bounds;

	_dataSource = [[ALApplicationTableDataSource alloc] init];

	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, bounds.size.height) style:UITableViewStyleGrouped];
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_tableView.delegate = self;
	_tableView.dataSource = _dataSource;
	_dataSource.tableView = _tableView;
	[self updateDataSource:nil];

	return self;
}

- (void)viewDidLoad {
	((UIViewController *)self).title = @"Applications";

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
	UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];

	// Need to mimic what PSListController does when it handles didSelectRowAtIndexPath
	// otherwise the child controller won't load
	ASPerAppProtectionOptions *controller = [[ASPerAppProtectionOptions alloc] initWithAppName:cell.textLabel.text identifier:[_dataSource displayIdentifierForIndexPath:indexPath]];
	controller.rootController = self.rootController;
	controller.parentController = self;

	[self pushController:controller];
	[tableView deselectRowAtIndexPath:indexPath animated:true];
}


- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

@end
