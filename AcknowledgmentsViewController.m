//
//  AcknowledgmentsViewController.m
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 11/15/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//

#import "AcknowledgmentsViewController.h"
#import "RootViewController.h"
#import "UIColor+AppDefinedColors.h"

@interface AcknowledgmentsViewController ()

@property (nonatomic, assign) BOOL isUserDraggingLeftEdge;
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIToolbar *menuBar;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *menuButton;

@end

@implementation AcknowledgmentsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSString *filePath = [[NSBundle mainBundle]pathForResource:@"Acknowledgements" ofType:@"html"];
	NSURL *url = [NSURL fileURLWithPath:filePath];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	[self.webView loadRequest:requestObj];
	
	[self.menuBar setBarTintColor:[UIColor appNavBarColor]];
	self.view.backgroundColor = [UIColor appNavBarColor];
	self.menuBar.clipsToBounds = YES;
	
	UIImage *buttonImage = [[UIImage imageNamed:@"btnMenu_normal"]
							imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
	self.menuButton.image = buttonImage;
	
	UIImageView *titleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavigationTitle"]];
	UIBarButtonItem *titleImageItem = [[UIBarButtonItem alloc] initWithCustomView:titleImage];
	UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			target:nil action:nil];
	NSMutableArray *currentItems = [self.menuBar.items mutableCopy];
	NSArray *newItems = @[spacer, titleImageItem, spacer];
	[currentItems addObjectsFromArray:newItems];
	[self.menuBar setItems:currentItems];
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

@end
