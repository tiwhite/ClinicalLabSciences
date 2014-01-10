//
//  NavigationMenuViewController.m
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 11/15/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import "NavigationMenuViewController.h"
#import "RootViewController.h"
#import "AcknowledgmentsViewController.h"
#import "ProceduresTableViewController.h"
#import "FavoritesTableViewController.h"
#import "UserDefaultsConsts.h"
#import "FavoritesManager.h"


@interface NavigationMenuViewController ()

@property (nonatomic, weak) IBOutlet UILabel *lblNumProcedures;
@property (nonatomic, weak) IBOutlet UILabel *lblNumFavorites;
@property (nonatomic, weak) IBOutlet UILabel *lblNumAnimations;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end


@implementation NavigationMenuViewController


#pragma mark - Initialization


// ---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self refreshProceduresCount];
	[self refreshAnimationsCount];
}


#pragma mark - Refresh Counters


// ---------------------------------------------------------------------------------------------------------------------
- (void)refreshProceduresCount
{
	NSString *proceduresListFilePath = [[NSBundle mainBundle] pathForResource:@"Procedures" ofType:@"plist"];
	NSDictionary *proceduresDictionary = [[NSDictionary alloc] initWithContentsOfFile:proceduresListFilePath];
	NSInteger numProcedures = 0;
	
	for (NSString *key in proceduresDictionary)
	{
		NSArray *array = [proceduresDictionary objectForKey:key];
		numProcedures += array.count;
	}
	
	self.lblNumProcedures.text = [NSString stringWithFormat:@"%ld", (long)numProcedures];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)refreshAnimationsCount
{
	NSString *animationsListFilePath = [[NSBundle mainBundle] pathForResource:@"Animations" ofType:@"plist"];
	NSArray *animationsArray = [[NSArray alloc] initWithContentsOfFile:animationsListFilePath];
	self.lblNumAnimations.text = [NSString stringWithFormat:@"%ld", (long)animationsArray.count];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)refreshFavoritesCount
{
	NSInteger numFavorites = [[FavoritesManager favoritesManagerInstance] numberOfFavorites];
	self.lblNumFavorites.text = [NSString stringWithFormat:@"%ld", (long)numFavorites];
}


#pragma mark - Load New Content


// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)loadAcknowledgmentsPage:(id)sender
{
	AcknowledgmentsViewController *ac = [self.storyboard instantiateViewControllerWithIdentifier:@"AcknowledgmentsVC"];
	[self.rootViewController loadNewContentView:ac];
}


// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)loadProceduresList:(id)sender
{
	UINavigationController *pc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProceduresListVC"];
	[self.rootViewController loadNewContentView:pc];
	pc = nil;
}


// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)loadFavoritesList:(id)sender
{
	UINavigationController *fc = [self.storyboard instantiateViewControllerWithIdentifier:@"FavoritesListVC"];
	[self.rootViewController loadNewContentView:fc];
}


// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)loadAnimationsList:(id)sender
{
	UINavigationController *ac = [self.storyboard instantiateViewControllerWithIdentifier:@"AnimationsVC"];
	[self.rootViewController loadNewContentView:ac];
}


@end
