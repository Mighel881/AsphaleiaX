#import <Preferences/PSViewController.h>
#import <AppList/AppList.h>

@interface ALApplicationTableDataSource (Private)
- (void)sectionRequestedSectionReload:(id)section animated:(BOOL)animated;
@end

@interface ALLinkCell : ALValueCell
@end

@interface ASSecuredAppsListController : PSViewController <UITableViewDelegate> {
	UITableView *_tableView;
	ALApplicationTableDataSource *_dataSource;
}
@end
