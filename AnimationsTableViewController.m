//
//  AnimationsTableViewController.m
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 11/21/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import "AnimationsTableViewController.h"
#import "UIColor+AppDefinedColors.h"
#import "RootViewController.h"
#import "AnimationsTableCell.h"
#import "ProcedureModel.h"
#import <MediaPlayer/MediaPlayer.h>


@interface AnimationsTableViewController ()

@property (nonatomic, weak) IBOutlet UIToolbar *menuBar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *menuButton;
@property (nonatomic, assign) BOOL isUserDraggingLeftEdge;
@property (nonatomic, strong) NSArray *animationsArray;
@property (nonatomic, strong) MPMoviePlayerViewController *videoVC;
@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end


static NSString *const kTableCellIdentifier = @"AnimationsTableCellIdentifier";


@implementation AnimationsTableViewController


// ---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self.menuBar setBarTintColor:[UIColor appNavBarColor]];
	self.view.backgroundColor = [UIColor appNavBarColor];
	self.menuBar.clipsToBounds = YES;
	
	UIImageView *titleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavigationTitle"]];
	UIBarButtonItem *titleImageItem = [[UIBarButtonItem alloc] initWithCustomView:titleImage];
	UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			target:nil action:nil];
	NSMutableArray *currentItems = [self.menuBar.items mutableCopy];
	NSArray *newItems = @[spacer, titleImageItem, spacer];
	[currentItems addObjectsFromArray:newItems];
	[self.menuBar setItems:currentItems];
	
	NSString *filePath = [[NSBundle mainBundle]pathForResource:@"Animations" ofType:@"plist"];
	self.animationsArray = [[NSArray alloc] initWithContentsOfFile:filePath];
	
	// register nib files for the table's cells
	UINib *tableCellNib = [UINib nibWithNibName:@"AnimationsTableCell" bundle:nil];
	[self.tableView registerNib:tableCellNib forCellReuseIdentifier:kTableCellIdentifier];
	
	UIImage *buttonImage = [[UIImage imageNamed:@"btnMenu_normal"]
							imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
	self.menuButton.image = buttonImage;
}


// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)openMenu:(id)sender
{
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


// ---------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}


// ---------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.animationsArray.count;
}


// ---------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	AnimationsTableCell *cell = (AnimationsTableCell *)
									[self.tableView dequeueReusableCellWithIdentifier:kTableCellIdentifier];
	
	[cell setTitle:(NSString *)[[self.animationsArray objectAtIndex:indexPath.row] objectForKey:@"Name"]];
	[cell configureAppearance];
	
	return cell;
}


#pragma mark - UITableView Delegate


// ---------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *animation = [self.animationsArray objectAtIndex:indexPath.row];
	NSString *filePath = [[NSBundle mainBundle] pathForResource:[animation objectForKey:@"VideoPath"] ofType:@"mp4"];
	NSURL *fileURL = [NSURL fileURLWithPath:filePath];
	self.videoVC = [[MPMoviePlayerViewController alloc] initWithContentURL:fileURL];
	[self presentMoviePlayerViewControllerAnimated:self.videoVC];
	[self.videoVC.moviePlayer play];
}


@end
