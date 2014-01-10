//
//  NavMenuViewController.m
//  ClinicalLabSciences
//
//  Created by tiwhite on 1/8/14.
//  Copyright (c) 2014 tiwhite. All rights reserved.
//


#import "NavMenuViewController.h"
#import "RootViewController.h"
#import "ProceduresTableViewController.h"


@interface NavMenuViewController ()

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIView *categoryContainer;
@property (nonatomic, weak) IBOutlet UIView *favoritesContainer;

@end


static NSString * const kTableCellIdentifier = @"NavigationMenuTableCellIdentifier";


@implementation NavMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"EmbedMenuTable"]) {
		#pragma clang diagnostic push
		#pragma clang diagnostic ignored "-Wundeclared-selector"	// temporarily disable certain compiler warnings
		if ([segue.destinationViewController respondsToSelector:@selector(setNavigationMenuRoot:)]) {
			[segue.destinationViewController performSelector:@selector(setNavigationMenuRoot:) withObject:self];
		}
		#pragma clang diagnostic pop
	}
}


- (void)loadCategoryList:(NSString *)categoryName
{
	UINavigationController *navVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ProceduresListVC"];
	ProceduresTableViewController *pc = (ProceduresTableViewController *)navVC.topViewController;
	
	[self.rootViewController loadNewContentView:navVC];
	
	if (categoryName != nil) {
		[pc restrictProceduresToCategory:categoryName];
	}
	
	navVC = nil;
}

- (void)refreshFavorites
{
}

- (void)adjustCategoryHeight:(NSInteger)categoryHeight
{
	self.categoryContainer.frame = CGRectMake(0, 0, self.view.frame.size.width, categoryHeight);
	self.favoritesContainer.frame = CGRectMake(0, categoryHeight, self.view.frame.size.width,
													self.favoritesContainer.frame.size.height);
	
	[self setScrollingContentSize];
}


- (void)adjustFavoritesHeight:(NSInteger)favoritesHeight
{
	if (favoritesHeight < 200) {
		favoritesHeight = 200;
	}
	
	self.favoritesContainer.frame = CGRectMake(0, self.favoritesContainer.frame.origin.y, self.view.frame.size.width,
											   favoritesHeight);
	
	[self setScrollingContentSize];
}


- (void)setScrollingContentSize
{
	NSInteger categoryHeight = self.categoryContainer.frame.size.height;
	NSInteger favoritesHeight = self.favoritesContainer.frame.size.height;
	
	self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, categoryHeight + favoritesHeight);
}


@end
