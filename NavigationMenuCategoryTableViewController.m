//
//  NavigationMenuCategoryTableViewController.m
//  ClinicalLabSciences
//
//  Created by tiwhite on 1/9/14.
//  Copyright (c) 2014 tiwhite. All rights reserved.
//

#import "NavigationMenuCategoryTableViewController.h"
#import "NavigationMenuCategoryTableCell.h"
#import "NavMenuViewController.h"

@interface NavigationMenuCategoryTableViewController ()

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *categoriesArray;		// string array containing the names of all the categories
@property (nonatomic, strong) NSArray *categoryItemsArray;	// int array storing the number of entries in each category

@end

static NSString * const kTableCellIdentifier = @"NavigationMenuCategoryTableCellIdentifier";

@implementation NavigationMenuCategoryTableViewController


// ---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	// register nib files for the table's headers and cells
	UINib *tableCellNib = [UINib nibWithNibName:@"NavigationMenuCategoryTableCell" bundle:nil];
	[self.tableView registerNib:tableCellNib forCellReuseIdentifier:kTableCellIdentifier];
	
	// prepare the procedures dictionary for use by reading from procedures plist
	NSString *proceduresListFilePath = [[NSBundle mainBundle] pathForResource:@"Procedures" ofType:@"plist"];
	NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:proceduresListFilePath];
	
	self.categoriesArray = [[plistDictionary allKeys] sortedArrayUsingSelector:@selector(compare:)];
	NSMutableArray *counterArray = [[NSMutableArray alloc] init];
	for (int i = 0; i < self.categoriesArray.count; i ++) {
		NSArray *currentCategory = [plistDictionary objectForKey:[self.categoriesArray objectAtIndex:i]];
		[counterArray addObject:[NSNumber numberWithInt:currentCategory.count]];
	}
	self.categoryItemsArray = counterArray;
	
	[self.tableView reloadData];
	[self.navigationMenuRoot adjustCategoryHeight:self.tableView.contentSize.height];
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
	return self.categoriesArray.count + 1;
}


// ---------------------------------------------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Categories";
}


// ---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NavigationMenuCategoryTableCell *cell = (NavigationMenuCategoryTableCell *)[self.tableView dequeueReusableCellWithIdentifier:
																kTableCellIdentifier];
	
	[cell configureAppearance];
	
	if (indexPath.row == 0) {
		[cell setTitle:@"All"];
		NSInteger counter = 0;
		for (int i = 0; i < self.categoryItemsArray.count; i++) {
			counter += [[self.categoryItemsArray objectAtIndex:i] integerValue];
		}
		[cell setCategoryCount:counter];
	} else {
		[cell setTitle:[self.categoriesArray objectAtIndex:indexPath.row - 1]];
		[cell setCategoryCount:[[self.categoryItemsArray objectAtIndex:indexPath.row - 1] integerValue]];
	}
	return cell;
}


#pragma mark - UITableView Delegate


// ---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == 0) {
		[self.navigationMenuRoot loadCategoryList:nil];
	} else {
		[self.navigationMenuRoot loadCategoryList:[self.categoriesArray objectAtIndex:indexPath.row - 1]];
	}
}


@end
