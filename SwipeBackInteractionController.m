//
//  SwipeBackInteractionController.m
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 11/13/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import "SwipeBackInteractionController.h"


@interface SwipeBackInteractionController ()

@property (nonatomic, assign) BOOL shouldCompleteTransition;
@property (nonatomic, weak) UINavigationController *navigationController;

@end


@implementation SwipeBackInteractionController


#pragma mark - Initialization


// ---------------------------------------------------------------------------------------------------------------------
- (void)connectToViewController:(UIViewController *)viewController
{
	self.navigationController = viewController.navigationController;
	[self prepareGestureRecognizerInView:viewController.view];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)prepareGestureRecognizerInView:(UIView *)view
{
	UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
																				 action:@selector(handlePanGesture:)];
	[view addGestureRecognizer:panGesture];
}


#pragma mark - Transition


// ---------------------------------------------------------------------------------------------------------------------
- (CGFloat)completionSpeed
{
	return 1 - self.percentComplete;
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)beginTransitionFromOtherClass
{
	self.isTransitionInProgress = YES;
	[self.navigationController popViewControllerAnimated:YES];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
	switch (gestureRecognizer.state) {
		case UIGestureRecognizerStateBegan:
			if ([gestureRecognizer locationInView:gestureRecognizer.view.superview].x < 25) {
				self.isTransitionInProgress = YES;
				[self.navigationController popViewControllerAnimated:YES];
			}
			break;
		case UIGestureRecognizerStateChanged:
			if (self.isTransitionInProgress) {
				CGPoint delta = [gestureRecognizer translationInView:gestureRecognizer.view.superview];
				CGFloat percent = 0.68 * (delta.x / gestureRecognizer.view.superview.frame.size.width);
				percent = fminf(fmaxf(percent, 0.0), 1.0);
				
				[self updateInteractiveTransition:percent];
			}
			break;
		case UIGestureRecognizerStateCancelled:
			if (self.isTransitionInProgress) {
				[self cancelInteractiveTransition];
				self.isTransitionInProgress = NO;
			}
			break;
		case UIGestureRecognizerStateEnded:
			if (self.isTransitionInProgress)
			{
				CGFloat xPosition = [gestureRecognizer locationInView:gestureRecognizer.view.superview].x;
				xPosition = xPosition / gestureRecognizer.view.superview.frame.size.width;
				NSInteger xVelocity = [gestureRecognizer velocityInView:gestureRecognizer.view.superview].x;
				
				self.isTransitionInProgress = NO;
				[self panGestureEndedWithRelativePosition:xPosition velocity:xVelocity];
			}
			break;
		default:
			break;
	}
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)panGestureEndedWithRelativePosition:(CGFloat)xPosition velocity:(NSInteger)xVelocity
{
	BOOL shouldComplete = NO;
	
	// first check velocity - quick swipe to right = complete, quick swipe to left = cancel
	if (xVelocity > 200) {
		shouldComplete = YES;
	} else if (xVelocity < -200) {
		shouldComplete = NO;
	// if inconclusive, check position
	} else {
		// show some slight bias towards completion
		if (xPosition > 0.4) {
			shouldComplete = YES;
		} else {
			shouldComplete = NO;
		}
	}
	
	if (shouldComplete) {
		[self finishInteractiveTransition];
	} else {
		[self cancelInteractiveTransition];
	}
}


@end
