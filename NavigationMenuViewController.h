//
//  NavigationMenuViewController.h
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 11/15/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import <UIKit/UIKit.h>
@class RootViewController;


/*
	Menu to navigate between different sections of the app.  The menu contains a series of buttons to load different
	types of content.  Tapping one of the buttons initializes the matching viewController, and then tells the
	RootViewController to load it.
 
	Also displays the number of items in each section for the user (for example, number of "favorites" the user has
	marked.
*/


@interface NavigationMenuViewController : UIViewController


@property (nonatomic, weak) RootViewController *rootViewController;


- (void)refreshFavoritesCount;	// needed by the RootViewController to keep the number of favorites updated


@end
