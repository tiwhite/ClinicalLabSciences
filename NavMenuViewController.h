//
//  NavMenuViewController.h
//  ClinicalLabSciences
//
//  Created by tiwhite on 1/8/14.
//  Copyright (c) 2014 tiwhite. All rights reserved.
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


@interface NavMenuViewController : UIViewController


@property (nonatomic, weak) RootViewController *rootViewController;

- (void)loadCategoryList:(NSString *)categoryName;
- (void)adjustCategoryHeight:(NSInteger)categoryHeight;		// set the height of the category table, and the origin
															// of the favorites table
- (void)adjustFavoritesHeight:(NSInteger)favoritesHeight;	// set the height of the favorites table
- (void)refreshFavorites;

@end
