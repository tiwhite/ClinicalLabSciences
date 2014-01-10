//
//  NavigationMenuCategoryTableViewController.h
//  ClinicalLabSciences
//
//  Created by tiwhite on 1/9/14.
//  Copyright (c) 2014 tiwhite. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NavMenuViewController;

@interface NavigationMenuCategoryTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) NavMenuViewController *navigationMenuRoot;

@end
