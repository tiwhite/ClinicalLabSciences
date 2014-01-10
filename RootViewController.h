//
//  RootViewController.h
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 10/31/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import <UIKit/UIKit.h>


/*
	The base view controller for the app.  Uses two container views to present the user with either their desired
	content or a menu allowing them to navigate to different sections.
 
	The menu container is placed behind the content container and to the left.  When the menu view is brought into
	focus, the content container is slid to the right, and the menu is slid from the left to the center.  When the menu
	is closed, the content is slid back to the center and the menu is slid to the left.
 
	The opening and closing of the menu is handled using UIKitDynamics.
*/


@interface RootViewController : UIViewController


// these methods for revealing the menu should be used by whichever view controller currently occupies the
// content container.  Hiding the menu will be controlled by the RootViewController.

- (void)revealMenu;	// slide the content and menu all the way to the right to bring the menu into view
- (void)dragMenuToPoint:(CGPoint)targetPoint;	// used by a drag gesture to manually position the menu
- (void)releaseMenuAtPoint:(CGPoint)point withVelocity:(CGPoint)velocity; // called when the drag gesture ends

// used to change the content being displayed
- (void)loadNewContentView:(UIViewController *)newViewController;


@end
