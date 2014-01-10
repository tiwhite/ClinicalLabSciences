//
//  ProcTableViewController.m
//  ClinicalLabSciences
//
//  Created by tiwhite on 1/8/14.
//  Copyright (c) 2014 tiwhite. All rights reserved.
//


#import "ProceduresTableViewController.h"
#import "ProceduresTableCell.h"
#import "NSDictionary-MutableDeepCopy.h"
#import "RootViewController.h"
#import "UIColor+AppDefinedColors.h"
#import "ProcedureViewController.h"
#import "ProcedureModel.h"
#import "ProcedureTransitionManager.h"
#import "SwipeBackInteractionController.h"
#import "UserDefaultsConsts.h"
#import "HelpPopupViewController.h"
#import "FavoritesManager.h"


@interface ProceduresTableViewController ()

@property (nonatomic, strong) NSDictionary *proceduresRootDictionary;	// a dictionary of all available procedures
@property (nonatomic, strong) NSMutableDictionary *proceduresVisibleDictionary;	// a mutable copy used by the table. Can
																				// be modified to hide some procedures

@property (nonatomic, strong) NSMutableArray *proceduresKeyArray;			// array of all the section header names

@property (nonatomic, weak) HiddenPanelCell *activeHiddenPanelCell;	// table cell currently with hidden panel exposed
@property (nonatomic, weak) HiddenPanelCell *selectedCell;
@property (nonatomic, assign) BOOL isUserDraggingLeftEdge;

@property (nonatomic, strong) ProcedureTransitionManager *transitionManager;
@property (nonatomic, strong) SwipeBackInteractionController *swipeBackInteractionController;

@property (nonatomic, assign) BOOL hasListLoaded;	// some initialization needs to go in viewWillAppear, but should
													// only be done once - this bool ensures it does not happen twice

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *menuButton;

@property (nonatomic, strong) NSString *unblockedProcedureCategory;	// if blank, show all, otherwise show only this one

@end


static NSString * const kTableCellIdentifier = @"ExpandableTableCellIdentifier";


@implementation ProceduresTableViewController


// ---------------------------------------------------------------------------------------------------------------------
// instead of showing all procedures, only show those of a particular category
// this method returns false if the given category is not valid
- (BOOL)restrictProceduresToCategory:(NSString *)categoryName
{
	if (self.proceduresKeyArray == nil) {
		[self initializeVisibleDictionary];
	}
	
	if ([self.proceduresKeyArray indexOfObject:categoryName] != NSNotFound) {
		self.unblockedProcedureCategory = categoryName;
		return true;
	}
	
	return false;
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];

	// register nib files for the table's headers and cells
	UINib *tableCellNib = [UINib nibWithNibName:@"ProceduresTableCell" bundle:nil];
	[self.tableView registerNib:tableCellNib forCellReuseIdentifier:kTableCellIdentifier];

	// initialize the table
	[self resetVisibleDictionary];

	// add a search bar to the top of the table
	UISearchBar *searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
	searchBar.searchBarStyle = UISearchBarStyleDefault;
	searchBar.barTintColor = [UIColor appSearchBarColor];
	searchBar.showsCancelButton = NO;
	searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	searchBar.delegate = self;
	searchBar.placeholder = @"Search                                                      ";
	self.tableView.tableHeaderView = searchBar;

	// set up the navigation controller to use a custom animation when transitioning
	self.transitionManager = [[ProcedureTransitionManager alloc] init];
	self.navigationController.delegate = self;
	self.swipeBackInteractionController = [[SwipeBackInteractionController alloc] init];

	[self configureAppearance];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	if (!self.hasListLoaded) {
		// hide the search bar at the top
		[self.tableView setContentOffset:CGPointMake(0, self.tableView.tableHeaderView.frame.size.height)];
		self.hasListLoaded = YES;
	}
	[self.tableView reloadData];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)initializeVisibleDictionary
{
	if (self.proceduresRootDictionary == nil) {
		NSString *proceduresListFilePath = [[NSBundle mainBundle] pathForResource:@"Procedures" ofType:@"plist"];
		self.proceduresRootDictionary = [[NSDictionary alloc] initWithContentsOfFile:proceduresListFilePath];
	}
	
	// first create a clean copy of the original dictionary
	self.proceduresVisibleDictionary = [[NSMutableDictionary alloc] initWithDictionary:
										[self.proceduresRootDictionary mutableDeepCopy]];
	
	// then create an array of all the keys in the original
	NSMutableArray *keyArray = [[NSMutableArray alloc] init];
	[keyArray addObjectsFromArray:[[self.proceduresRootDictionary allKeys]
								   sortedArrayUsingSelector:@selector(compare:)]];
	self.proceduresKeyArray = keyArray;
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)resetVisibleDictionary
{
	[self initializeVisibleDictionary];
	
	if (self.unblockedProcedureCategory && ![self.unblockedProcedureCategory isEqualToString:@""]) {
		self.proceduresKeyArray = [[NSMutableArray alloc] initWithArray:@[self.unblockedProcedureCategory]];
	}
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)configureAppearance
{
	// set the color of the cancel button for the search bar
	[[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
	 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:	[UIColor appSearchBarButtonTextColor],
							 NSForegroundColorAttributeName,
							 nil]
	 forState:UIControlStateNormal];
	
	UIImageView *titleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavigationTitle"]];
	self.navigationItem.titleView = titleImage;
	
	UIImage *buttonImage = [[UIImage imageNamed:@"btnMenu_normal"]
							imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
	self.menuButton.image = buttonImage;
	
}


#pragma mark - UITableView DataSource


// ---------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return self.proceduresKeyArray.count;
}


// ---------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSString *key = [self.proceduresKeyArray objectAtIndex:section];
	NSArray *sectionArray = [self.proceduresVisibleDictionary objectForKey:key];
	return sectionArray.count;
}


// ---------------------------------------------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return [self.proceduresKeyArray objectAtIndex:section];
}


// ---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	ProceduresTableCell *cell = (ProceduresTableCell *)[self.tableView dequeueReusableCellWithIdentifier:
														kTableCellIdentifier];
	
	NSString *key = [self.proceduresKeyArray objectAtIndex:indexPath.section];
	NSArray *sectionArray = [self.proceduresVisibleDictionary objectForKey:key];
	[cell setTitle:[[sectionArray objectAtIndex:indexPath.row] objectForKey:@"Name"]];
	
	cell.delegate = self;
	cell.indexPath = indexPath;
	
	[cell configureAppearance];
	
	return cell;
}


// ---------------------------------------------------------------------------------------------------------------------
// NOTE: I'm not sure why, but the scroll indicators do not work correctly without this
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	return nil;
}


#pragma mark - UITableView Delegate


// ---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"SELECT");
}

#pragma mark - Rotation Code


// ---------------------------------------------------------------------------------------------------------------------
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
								duration:(NSTimeInterval)duration
{
	for (int i = 0; i < [self.tableView numberOfSections]; i++)
	{
		for (int j = 0; j < [self.tableView numberOfRowsInSection:i]; j++)
		{
			[(HiddenPanelCell *)
			 [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]] willRotate];
		}
	}
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	for (int i = 0; i < [self.tableView numberOfSections]; i++)
	{
		for (int j = 0; j < [self.tableView numberOfRowsInSection:i]; j++)
		{
			[(HiddenPanelCell *)
			 [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]] didRotate];
		}
	}
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)hiddenPanelCell:(HiddenPanelCell *)hiddenPanelCell toggleScrolling:(BOOL)isScrollingAllowed
{
	self.tableView.scrollEnabled = isScrollingAllowed;
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)hiddenPanelCellOpened:(HiddenPanelCell *)hiddenPanelCell
{
	if (self.activeHiddenPanelCell != nil && hiddenPanelCell != self.activeHiddenPanelCell) {
		[self.activeHiddenPanelCell hideHiddenPanel];
	}
	self.activeHiddenPanelCell = hiddenPanelCell;
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)hiddenPanelCellClosed:(HiddenPanelCell *)hiddenPanelCell
{
	if (hiddenPanelCell == self.activeHiddenPanelCell) {
		self.activeHiddenPanelCell = nil;
	}
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)hiddenPanelCellTapped:(HiddenPanelCell *)hiddenPanelCell
{
	[self.activeHiddenPanelCell hideHiddenPanel];
	self.selectedCell = hiddenPanelCell;
	[hiddenPanelCell setSelected:YES];
	
	// use the first version to force the selected appearance of a cell when tapped.  Use the second version for normal
	//	[self performSelector:@selector(selectHiddenCell:) withObject:hiddenPanelCell afterDelay:.01];
	[self performSegueWithIdentifier:@"ProcedureSelectedSegue" sender:hiddenPanelCell];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)selectHiddenCell:(HiddenPanelCell *)hiddenPanelCell
{
	[self performSegueWithIdentifier:@"ProcedureSelectedSegue" sender:hiddenPanelCell];
}


#pragma mark - Search Bar Delegate


// ---------------------------------------------------------------------------------------------------------------------
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	searchBar.showsCancelButton = YES;
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	searchBar.showsCancelButton = NO;
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	// get the length of the searchText, excluding spaces, etc.
	NSUInteger searchLength = [searchText stringByTrimmingCharactersInSet:
							   [NSCharacterSet whitespaceCharacterSet]].length;
	
	// if the search text is empty, or if the user is only searching for whitespace characters, just show the full list
	if (searchText == nil || searchLength == 0) {
		[self resetVisibleDictionary];
		[self.tableView reloadData];
		return;
	}
	
	[self handleSearchForTerm:searchText];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	searchBar.text = @"";
	searchBar.showsCancelButton = YES;
	
	[self resetVisibleDictionary];
	[self.tableView reloadData];
	[searchBar resignFirstResponder];
}


#pragma mark - Searching


// ---------------------------------------------------------------------------------------------------------------------
- (void)handleSearchForTerm:(NSString *)searchTerm
{
	NSMutableArray *sectionsToRemove = [[NSMutableArray alloc] init];
	
	// first reset the "visible" dictionary so that all procedure and sections are present
	[self resetVisibleDictionary];
	
	// loop through each section of the visible dictionary
	for (int i = 0; i < self.proceduresKeyArray.count; i++)
	{
		NSMutableArray *proceduresToRemove = [[NSMutableArray alloc] init];
		NSString *currentSectionKey = [self.proceduresKeyArray objectAtIndex:i];
		NSMutableArray *currentSectionProcedures = [self.proceduresVisibleDictionary objectForKey:currentSectionKey];
		
		// for each section, check each procedure's name
		for (int j = 0; j < currentSectionProcedures.count; j++)
		{
			NSDictionary *procedure = [currentSectionProcedures objectAtIndex:j];
			NSString *procedureName = [procedure objectForKey:@"Name"];
			
			// if a procedure's name does not contain the search term, flag it for removal
			if ([procedureName rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location == NSNotFound) {
				[proceduresToRemove addObject:procedure];
			}
		}
		
		// if all the procedures in a section are flagged for removal, flag the section for removal
		if (currentSectionProcedures.count == proceduresToRemove.count) {
			[sectionsToRemove addObject:currentSectionKey];
		}
		
		// remove the flagged procedures
		[currentSectionProcedures removeObjectsInArray:proceduresToRemove];
	}
	
	// remove the flagged sections
	[self.proceduresKeyArray removeObjectsInArray:sectionsToRemove];
	
	
	[self.tableView reloadData];
}


#pragma mark - Show Navigation Menu


// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)openMenu:(id)sender
{
	[self.activeHiddenPanelCell hideHiddenPanel];
	[self.rootViewController revealMenu];
}


// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)handlePanToOpenMenu:(UIPanGestureRecognizer *)gestureRecognizer
{
	// we're only interested in touches on the left-most edge of the view
	switch (gestureRecognizer.state) {
		case UIGestureRecognizerStateBegan:;
			CGRect validInput = CGRectMake(0, 0, 35, self.view.bounds.size.height);
			if (CGRectContainsPoint(validInput, [gestureRecognizer locationInView:self.view])) {
				self.isUserDraggingLeftEdge = YES;
			} else {
				self.isUserDraggingLeftEdge = NO;
			}
			break;
		case UIGestureRecognizerStateChanged:
			if (self.isUserDraggingLeftEdge) {
				CGPoint location = [gestureRecognizer locationInView:self.rootViewController.view];
				[self.rootViewController dragMenuToPoint:location];
			}
			break;
		case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateEnded:
			if (self.isUserDraggingLeftEdge) {
				CGPoint touchPoint = [gestureRecognizer locationInView:self.rootViewController.view];
				CGPoint touchVelocity = [gestureRecognizer velocityInView:self.rootViewController.view];
				[self.rootViewController releaseMenuAtPoint:touchPoint withVelocity:touchVelocity];
			}
			break;
		default:
			break;
	}
}


#pragma mark - Transitioning Delegate


// ---------------------------------------------------------------------------------------------------------------------
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
								  animationControllerForOperation:(UINavigationControllerOperation)operation
											   fromViewController:(UIViewController *)fromVC
												 toViewController:(UIViewController *)toVC
{
	self.transitionManager.isTransitionPush = (operation == UINavigationControllerOperationPush);
	if (operation == UINavigationControllerOperationPush) {
		self.transitionManager.listCellView = self.selectedCell;
		CGRect selectedCellRect = [self.tableView rectForRowAtIndexPath:self.selectedCell.indexPath];
		CGRect convertedRect = [self.tableView convertRect:selectedCellRect toView:self.view.superview];
		self.transitionManager.listCellRect = convertedRect;
		ProcedureViewController *procedureVC = (ProcedureViewController *)toVC;
		procedureVC.swipeBackInteractionController = self.swipeBackInteractionController;
		[self.swipeBackInteractionController connectToViewController:toVC];
	}
	return self.transitionManager;
}


// ---------------------------------------------------------------------------------------------------------------------
- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
						 interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)
																		animationController
{
	if (self.swipeBackInteractionController.isTransitionInProgress) {
		return self.swipeBackInteractionController;
	}
	
	return nil;
}


#pragma mark - Other


// ---------------------------------------------------------------------------------------------------------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"ProcedureSelectedSegue"])
	{
		HiddenPanelCell *cell = (HiddenPanelCell *)sender;
		NSIndexPath *indexPath = cell.indexPath;
		
		NSString *key = [self.proceduresKeyArray objectAtIndex:indexPath.section];	// remember extra section at top
		NSArray *sectionArray = [self.proceduresVisibleDictionary objectForKey:key];
		NSDictionary *procedureDictionary = [sectionArray objectAtIndex:indexPath.row];
		
		ProcedureViewController *procedureViewController = (ProcedureViewController *)segue.destinationViewController;
		procedureViewController.procedureDictionary = procedureDictionary;
	}
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[self.activeHiddenPanelCell hideHiddenPanel];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)sectionExpanded:(NSInteger)sectionNumber
{
	[self.activeHiddenPanelCell hideHiddenPanel];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)sectionCollapsed:(NSInteger)sectionNumber
{
	[self.activeHiddenPanelCell hideHiddenPanel];
}


@end
