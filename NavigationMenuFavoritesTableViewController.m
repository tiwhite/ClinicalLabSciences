//
//  NavigationMenuFavoritesTableViewController.m
//  ClinicalLabSciences
//
//  Created by tiwhite on 1/10/14.
//  Copyright (c) 2014 tiwhite. All rights reserved.
//

#import "NavigationMenuFavoritesTableViewController.h"
#import "FavoritesManager.h"
#import "NavMenuViewController.h"
#import "NavigationMenuFavoritesTableCell.h"


@interface NavigationMenuFavoritesTableViewController ()

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *favoritesArray;	// string array containing the names of the favorited procedures
@property (nonatomic, weak) IBOutlet UIImageView *favoritesPrompt;

@end

static NSString * const kTableCellIdentifier = @"NavigationMenuFavoritesTableCellIdentifier";

@implementation NavigationMenuFavoritesTableViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// register nib files for the table's headers and cells
	UINib *tableCellNib = [UINib nibWithNibName:@"NavigationMenuFavoritesTableCell" bundle:nil];
	[self.tableView registerNib:tableCellNib forCellReuseIdentifier:kTableCellIdentifier];
	
	[self refreshFavorites];
	
	[self.navigationMenuRoot adjustFavoritesHeight:self.tableView.contentSize.height];
}

- (void)refreshFavorites
{
	self.favoritesArray = [[FavoritesManager favoritesManagerInstance] listOfFavorites];
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



#pragma mark - UITableView DataSource


// ---------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}


// ---------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.favoritesArray.count;
}


// ---------------------------------------------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Favorites";
}


// ---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NavigationMenuFavoritesTableCell *cell = (NavigationMenuFavoritesTableCell *)[self.tableView dequeueReusableCellWithIdentifier:
																				kTableCellIdentifier];
	
	[cell configureAppearance];
	[cell setTitle:[self.favoritesArray objectAtIndex:indexPath.row]];
	
	return cell;
}


#pragma mark - UITableView Delegate


// ---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}


@end
