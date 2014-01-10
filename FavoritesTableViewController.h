//
//  FavoritesTableViewController.h
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 11/18/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "FavoritesTableCell.h"
@class RootViewController;


/*
	Displays a list of favorited procedures, sorted alphabetically, to choose from.
 
	Procedures can be un-favorited by swiping left on their rows.
 
	There is also a search bar at the top of the table, which can be used to filter the list.  This search bar is
	normally hidden, but can be accessed by swiping down while at the top of the list.
*/


@interface FavoritesTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,
															UISearchBarDelegate, FavoritesCellDelegate,
															UIViewControllerTransitioningDelegate,
															UINavigationControllerDelegate>


@property (nonatomic, weak) RootViewController *rootViewController;


@end
