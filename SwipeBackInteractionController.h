//
//  SwipeBackInteractionController.h
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 11/13/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import <UIKit/UIKit.h>


/*
	An interactive transition for returning from a single procedure back to a list of procedures.  Uses the regular
	"pop" transition, but rather than performing it all at once, it only applies a percent of it as the user swipes
	from the left side of the screen.
 
	This class creates a pan gesture recognizer that will drive the transition, and then inserts it into the view that
	will trigger the transition.
*/


@interface SwipeBackInteractionController : UIPercentDrivenInteractiveTransition


@property (nonatomic, assign) BOOL isTransitionInProgress;


- (void)connectToViewController:(UIViewController *)viewController;	 // prepares a viewcontroller to use this transition
- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer;// use the gesture recognizer to advance transition
- (void)beginTransitionFromOtherClass;	// used when the connected class needs to control the transition manually


@end
