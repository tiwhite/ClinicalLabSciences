//
//  FavoritesTableViewController.m
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 11/18/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import "FavoritesTableViewController.h"
#import "UserDefaultsConsts.h"
#import "NSDictionary-MutableDeepCopy.h"
#import "UIColor+AppDefinedColors.h"
#import "FavoritesTableCell.h"
#import "RootViewController.h"
#import "ProcedureViewController.h"
#import "ProcedureModel.h"
#import "ProcedureTransitionManager.h"
#import "SwipeBackInteractionController.h"
#import "FavoritesManager.h"


@interface FavoritesTableViewController ()


@property (nonatomic, strong) NSMutableArray *proceduresRootArray;		// an array of all available procedures
@property (nonatomic, strong) NSMutableArray *proceduresVisibleArray;	// a mutable copy used by the table. Can
																		// be modified to hide some procedures
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *menuButton;
@property (nonatomic, weak) IBOutlet UIImageView *favoritesPrompt;

@property (nonatomic, weak) HiddenPanelCell *activeHiddenPanelCell;	// table cell currently with hidden panel exposed
@property (nonatomic, weak) HiddenPanelCell *selectedCell;
@property (nonatomic, assign) BOOL isUserDraggingLeftEdge;
@property (nonatomic, strong) ProcedureTransitionManager *transitionManager;
@property (nonatomic, strong) SwipeBackInteractionController *swipeBackInteractionController;


@end


static NSString *const kTableCellIdentifier = @"FavoritesTableCellIdentifier";


@implementation FavoritesTableViewController


// ---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// register nib files for the table's cells
	UINib *tableCellNib = [UINib nibWithNibName:@"FavoritesTableCell" bundle:nil];
	[self.tableView registerNib:tableCellNib forCellReuseIdentifier:kTableCellIdentifier];
	
	
	// set the color of the cancel button for the search bar
	[[UIBarButtonItem appearanceWhenContainedIn:[UISearchBar class], nil]
	 setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:	[UIColor appSearchBarButtonTextColor],
							 NSForegroundColorAttributeName,
							 nil]
	 forState:UIControlStateNormal];
	
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
	
	UIImageView *titleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavigationTitle"]];
	self.navigationItem.titleView = titleImage;
	
	UIImage *buttonImage = [[UIImage imageNamed:@"btnMenu_normal"]
							imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
	self.menuButton.image = buttonImage;
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.tableView setContentOffset:CGPointMake(0, self.tableView.tableHeaderView.frame.size.height)];
	
	self.proceduresRootArray = [[NSMutableArray alloc] initWithArray:
								[[FavoritesManager favoritesManagerInstance] listOfFavorites]];
	self.proceduresVisibleArray = [[NSMutableArray alloc] initWithArray:self.proceduresRootArray];
	[self.tableView reloadData];
	
	[self toggleFavoritesPrompt];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)toggleFavoritesPrompt
{
	if ([[FavoritesManager favoritesManagerInstance] numberOfFavorites] == 0) {
		self.favoritesPrompt.hidden = NO;
	} else {
		self.favoritesPrompt.hidden = YES;
	}
}


#pragma mark - UITableView Data Source


// ---------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}


// ---------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.proceduresVisibleArray.count;
}


// ---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	FavoritesTableCell *cell = (FavoritesTableCell *)[self.tableView dequeueReusableCellWithIdentifier:
													  kTableCellIdentifier];
	
	[cell setTitle:(NSString *)[self.proceduresVisibleArray objectAtIndex:indexPath.row]];
	
	cell.delegate = self;
	cell.indexPath = indexPath;
	
	[cell configureAppearance];
	
	return cell;
}


#pragma mark - UITableView Delegate


// ---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSLog(@"SELECT");
}


#pragma mark - Hidden Panel Cell Delegate


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
		self.proceduresVisibleArray = [[NSMutableArray alloc] initWithArray:self.proceduresRootArray];;
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
	
	self.proceduresVisibleArray = [[NSMutableArray alloc] initWithArray:self.proceduresRootArray];
	[self.tableView reloadData];
	[searchBar resignFirstResponder];
}


#pragma mark - Searching


// ---------------------------------------------------------------------------------------------------------------------
- (void)handleSearchForTerm:(NSString *)searchTerm
{
	// first reset the "visible" dictionary so that all procedure and sections are present
	self.proceduresVisibleArray = [[NSMutableArray alloc] initWithArray:self.proceduresRootArray];;
	
	// create an array to store the procedures that will be removed from searchArray
	// these will be the procedures with names not matching the user's input
	NSMutableArray *proceduresToRemove = [[NSMutableArray alloc]init];
	
	// loop through each section of the visible dictionary
	for (int i = 0; i < self.proceduresVisibleArray.count; i++)
	{
		NSString *procedureName = [self.proceduresVisibleArray objectAtIndex:i];
			
		if ([procedureName rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location == NSNotFound) {
			[proceduresToRemove addObject:procedureName];
		}
	}
	
	// remove the flagged procedures
	[self.proceduresVisibleArray removeObjectsInArray:proceduresToRemove];
	
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
	self.transitionManager.listCellView = self.selectedCell;
	CGRect selectedCellRect = [self.tableView rectForRowAtIndexPath:self.selectedCell.indexPath];
	CGRect convertedRect = [self.tableView convertRect:selectedCellRect toView:self.view.superview];
	self.transitionManager.listCellRect = convertedRect;
	self.transitionManager.isTransitionPush = (operation == UINavigationControllerOperationPush);
	if (operation == UINavigationControllerOperationPush) {
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
		
		NSString *proceduresListFilePath = [[NSBundle mainBundle] pathForResource:@"Procedures" ofType:@"plist"];
		NSDictionary *procedureListDictionary = [[NSDictionary alloc] initWithContentsOfFile:proceduresListFilePath];
		
		for (NSString *key in procedureListDictionary)
		{
			NSArray *category = [procedureListDictionary objectForKey:key];
			
			for (NSDictionary *procedure in category)
			{
				if ([[procedure objectForKey:@"Name"] isEqualToString:
					 [self.proceduresVisibleArray objectAtIndex:indexPath.row]])
				{
					ProcedureViewController *procedureViewController =
															(ProcedureViewController *)segue.destinationViewController;
					procedureViewController.procedureDictionary = procedure;
					return;
				}
			}
		}
	}
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)favoritesCellDeleteFavorite:(FavoritesTableCell *)favoritesCell
{
	NSString *cellNameToDelete = [self.proceduresVisibleArray objectAtIndex:favoritesCell.indexPath.row];
	
	[self.tableView beginUpdates];
	[self.tableView deleteRowsAtIndexPaths:@[favoritesCell.indexPath] withRowAnimation:UITableViewRowAnimationFade];
	[self.proceduresVisibleArray removeObject:cellNameToDelete];
	[self.proceduresRootArray removeObject:cellNameToDelete];
	[self.tableView endUpdates];

	[[FavoritesManager favoritesManagerInstance] removeProcedureFromFavorites:cellNameToDelete];
	
	// normally, reloadData isn't needed after an insert/delete operation.  However, because each cell tracks its own
	// index, reload is necessary to correct all the indices after a delete
	[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0.2f];
	
	[self performSelector:@selector(toggleFavoritesPrompt) withObject:nil afterDelay:0.2f];
}


@end
