//
//  HelpPopupViewController.m
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 12/5/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import "HelpPopupViewController.h"

@interface HelpPopupViewController ()

@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) UIImage *snapshot;
@property (nonatomic, weak) IBOutlet UIView *overlayView;

@end


@implementation HelpPopupViewController


// ---------------------------------------------------------------------------------------------------------------------
+ (void)showHelpForCollapsedListOverView:(UIViewController *)callingViewController
{
	[HelpPopupViewController showPopupWithImage:@"helpListCollapsed" OverView:callingViewController];
}


// ---------------------------------------------------------------------------------------------------------------------
+ (void)showHelpForExpandedListOverView:(UIViewController *)callingViewController
{
	[HelpPopupViewController showPopupWithImage:@"helpListExpanded" OverView:callingViewController];
}


// ---------------------------------------------------------------------------------------------------------------------
+ (void)showHelpForProcedureOverView:(UIViewController *)callingViewController
{
	[HelpPopupViewController showPopupWithImage:@"helpProcedure" OverView:callingViewController];
}


// ---------------------------------------------------------------------------------------------------------------------
+ (void)showPopupWithImage:(NSString *)imageName OverView:(UIViewController *)callingViewController
{
	// first take a snapshot of the existing screen - this is because a presented view controller automatically
	// hides the presenting view controller, so we'll fake the appearance of transparency
	CGRect windowRect = callingViewController.view.window.frame;
	UIGraphicsBeginImageContextWithOptions(windowRect.size, NO, 0);
	[callingViewController.view.window drawViewHierarchyInRect:windowRect afterScreenUpdates:YES];
	UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	HelpPopupViewController *popupView = [[HelpPopupViewController alloc] initWithNibName:@"HelpPopupViewController"
																				   bundle:[NSBundle mainBundle]];
	
	popupView.imageName = imageName;
	popupView.snapshot = snapshot;
	[callingViewController presentViewController:popupView animated:NO completion:nil];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)fadeIn
{
	[UIView animateWithDuration:0.25
						  delay:0
						options:UIViewAnimationOptionCurveLinear
					 animations:^{
						 self.overlayView.alpha = 1;
					 } completion:^(BOOL finished) {
						 UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
															   initWithTarget:self action:@selector(fadeOut)];
						 [self.view addGestureRecognizer:tapGesture];
					 }];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)fadeOut
{
	[UIView animateWithDuration:0.3
					 animations:^{
						 self.overlayView.alpha = 0;
					 } completion:^(BOOL finished) {
						 [self dismissHelpView];
					 }];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)dismissHelpView
{
	[self dismissViewControllerAnimated:NO completion:nil];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	UIImageView *snapshotView = [[UIImageView alloc] initWithImage:self.snapshot];
	[self.view insertSubview:snapshotView belowSubview:self.overlayView];
	 
	UIImageView *overlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.imageName]];
	[self.overlayView addSubview:overlay];
	self.overlayView.alpha = 0;
	[self fadeIn];

}

// ---------------------------------------------------------------------------------------------------------------------
// for now, only support portrait
- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskPortrait;
}


@end
