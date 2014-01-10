//
//  NavigationMenuTableCell.h
//  ClinicalLabSciences
//
//  Created by tiwhite on 1/9/14.
//  Copyright (c) 2014 tiwhite. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface NavigationMenuCategoryTableCell : UITableViewCell


- (void)setTitle:(NSString *)titleString;
- (void)setCategoryCount:(NSInteger)numberOfItems;
- (void)configureAppearance;

@end
