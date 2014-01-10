//
//  ProcTableViewController.h
//  ClinicalLabSciences
//
//  Created by tiwhite on 1/8/14.
//  Copyright (c) 2014 tiwhite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HiddenPanelCell.h"
@class RootViewController;


/*
	Displays a list of procedures to choose from.  The procedures are divided into categories, and can be shown all at
	once or limited to only a single category.
 
	Individual procedures can be favorited or un-favorited by swiping left on their rows.

	There is also a search bar at the top of the table, which can be used to filter the list.  This search bar is
	normally hidden, but can be accessed by swiping down while at the top of the list.
*/


@interface ProceduresTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,
																UISearchBarDelegate, HiddenPanelCellDelegate,
																UIViewControllerTransitioningDelegate,
																UINavigationControllerDelegate>


@property (nonatomic, weak) RootViewController *rootViewController;


- (BOOL)restrictProceduresToCategory:(NSString *)categoryName;


@end
