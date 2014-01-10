//
//  ProcedureTransitionManager.m
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 11/12/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import "ProcedureTransitionManager.h"
#import "ProcedureViewController.h"


@interface ProcedureTransitionManager ()

// views and viewControllers that are part of the transition
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;
@property (nonatomic, weak) UIView *transitionContainerView;
@property (nonatomic, weak) UIViewController *fromVC;
@property (nonatomic, weak) UIViewController *toVC;
@property (nonatomic, weak) UIView *fromView;
@property (nonatomic, weak) UIView *toView;

// snapshots used for animation purposes
@property (nonatomic, strong) UIView *listCellSnapshot;
@property (nonatomic, strong) UIView *listViewSnapshot;

@end


@implementation ProcedureTransitionManager


// ---------------------------------------------------------------------------------------------------------------------
- (NSTimeInterval) transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
	return .5;
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
	self.transitionContext = transitionContext;
	self.transitionContainerView = [transitionContext containerView];
	self.fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	self.toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	self.fromView = self.fromVC.view;
	self.toView = self.toVC.view;
	
	[self.transitionContainerView addSubview:self.toView];
	
	if (self.isTransitionPush) {
		[self animatePush];
	} else {
		[self animatePop];
	}
}


// ---------------------------------------------------------------------------------------------------------------------
// NOTE: there is a discrepency (caused by the navigation and status bars) in the frames of the list view and procedure
// view.  As a result, some of the animated elements need to be shifted +- 64 px to compensate
- (void)animatePush
{
	ProcedureViewController *detailVC = (ProcedureViewController *)self.toVC;
	UIView *detailTitleView = detailVC.titleParent;
	
	// take snapshots of both the selected cell and the list view as a whole.  These will need to be saved for later,
	// when the user wants to return to the list view
	self.listCellSnapshot = [self.listCellView snapshotViewAfterScreenUpdates:NO];
	self.listViewSnapshot = [self.fromView snapshotViewAfterScreenUpdates:NO];
	[self.transitionContainerView addSubview:self.listViewSnapshot];
	[self.transitionContainerView addSubview:self.listCellSnapshot];
	
	// shift the screenshot down to compensate for the view discrepencies
	CGRect snapshotRect = self.listViewSnapshot.frame;
	snapshotRect.origin.y += 64;
	self.listViewSnapshot.frame = snapshotRect;
	
	// set the initial state of the animations
	self.fromView.hidden = YES;							// hide the FROM view - the animation will only use the snapshot
	self.listCellSnapshot.frame = self.listCellRect;	// the starting position of selected cell
	self.toView.alpha = 0;								// the TO view starts hidden and then fades into view
	
	// the detail view may have animations of its own to perform.
	[detailVC prepareIntro];
	
	// move the detail view's title to the same position as the selected cell
	CGRect detailTitleFinalRect = detailTitleView.frame;	// remember its starting position first
	CGRect shiftedTitleFinalRect = detailTitleFinalRect;
	shiftedTitleFinalRect.origin.y += 64;
	detailTitleView.frame = CGRectMake(0, self.listCellSnapshot.frame.origin.y - 64,
									   detailTitleView.frame.size.width, detailTitleView.frame.size.height);
	
	// create a slight delay for cells closer to the bottom of the screen
	CGFloat timeOffset = 0.08 * (self.listCellRect.origin.y / self.transitionContainerView.frame.size.height);

	// perform the animations
	[UIView animateKeyframesWithDuration:.3 + timeOffset
								   delay:0
								 options:UIViewKeyframeAnimationOptionCalculationModeLinear
							  animations:^{
								  // fade and shrink the list view
								  [UIView addKeyframeWithRelativeStartTime:0
														  relativeDuration:.5
																animations:^{
																	self.listViewSnapshot.alpha = 0;
																	self.listViewSnapshot.frame = CGRectMake(
																	 self.transitionContainerView.frame.size.width / 2,
																	 self.transitionContainerView.frame.size.height / 2,
																	 0, 0);
																}];
								  // unfade the detail view, move the selected cell towards the detail view's title
								  // position while morphing it into the title (cell fades while title unfades)
								  [UIView addKeyframeWithRelativeStartTime:0
														  relativeDuration:1
																animations:^{
																	self.toView.alpha = 1;
																	self.listCellSnapshot.alpha = 0;
																	self.listCellSnapshot.frame = shiftedTitleFinalRect;
																	detailTitleView.frame = detailTitleFinalRect;
																}];
							  } completion:^(BOOL finished) {
								  // have the detail view complete any remaining animations
								  [detailVC animateIntro];
								  
								  // remove the snapshots
								  [self.listViewSnapshot removeFromSuperview];
								  [self.listCellSnapshot removeFromSuperview];
								  
								  // now that the list view is safely "behind" the detail view, we can unhide it
								  self.fromView.hidden = NO;
								  
								  // signal the completion of the transition
								  [self.transitionContext completeTransition:
								   ![self.transitionContext transitionWasCancelled]];
							  }];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)animatePop
{
	ProcedureViewController *detailVC = (ProcedureViewController *)self.fromVC;
	UIView *detailTitleView = detailVC.titleParent;
	
	// get a snapshot of the detail view's title (since the detail view is going away)
	UIView *toLabelSnapshot = [detailTitleView snapshotViewAfterScreenUpdates:NO];
	toLabelSnapshot.frame = detailTitleView.frame;
	
	// shift the title snapshot down
	CGRect shiftedFrame = toLabelSnapshot.frame;
	shiftedFrame.origin.y += 64;
	toLabelSnapshot.frame = shiftedFrame;
	
	// set the starting states in preparation for the animations
	self.listCellSnapshot.alpha = 1;	// unhide the selected cell snapshot
	self.toView.hidden = YES;			// hide TO view until end - animation handled by snapshots
	self.listViewSnapshot.alpha = 0;	// list snapshot starts hidden and shrunk and fades into view while growing
	self.listViewSnapshot.frame = CGRectMake(self.transitionContainerView.frame.size.width / 10,
											 self.transitionContainerView.frame.size.height / 10,
											 self.transitionContainerView.frame.size.width * .8,
											 self.transitionContainerView.frame.size.height * .8);
	
	// add all the snapshots that will be used (taken during "push" animation)
	[self.transitionContainerView addSubview:self.listViewSnapshot];
	[self.transitionContainerView addSubview:self.listCellSnapshot];
	[self.transitionContainerView addSubview:toLabelSnapshot];
	
	// create a slight delay for cells closer to the bottom of the screen
	CGFloat timeOffset = 0.08 * (self.listCellRect.origin.y / self.transitionContainerView.frame.size.height);

	// perform the animations
	[UIView animateWithDuration:.25 + timeOffset
						  delay:0
						options:UIViewAnimationOptionCurveLinear
					 animations:^{
						 // fade out the detail view and fade in the list view
						 self.fromView.alpha = 0;
						 self.listViewSnapshot.alpha = 1;
						 self.listViewSnapshot.frame = self.toView.frame;
						 
						 // move the cell to its starting position while morphing it from detail's title
						 self.listCellSnapshot.frame = self.listCellRect;
						 toLabelSnapshot.frame = self.listCellRect;
						 toLabelSnapshot.alpha = 0;
					 } completion:^(BOOL finished) {
						 // unhide the list view
						 self.toView.hidden = NO;
						 
						 // remove all snapshots
						 [self.listViewSnapshot removeFromSuperview];
						 [self.listCellSnapshot removeFromSuperview];
						 [toLabelSnapshot removeFromSuperview];
						 
						 // signal the completion of the transition
						 [self.transitionContext completeTransition:![self.transitionContext transitionWasCancelled]];
					 }];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)animationEnded:(BOOL)transitionCompleted
{
//	NSLog(@"animation complete");
}


@end
