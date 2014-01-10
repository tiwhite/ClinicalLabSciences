//
//  NavigationMenuTableCell.m
//  ClinicalLabSciences
//
//  Created by tiwhite on 1/9/14.
//  Copyright (c) 2014 tiwhite. All rights reserved.
//

#import "NavigationMenuCategoryTableCell.h"

@interface NavigationMenuCategoryTableCell ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UILabel *itemCountLabel;

@end


@implementation NavigationMenuCategoryTableCell


// ---------------------------------------------------------------------------------------------------------------------
- (void)setTitle:(NSString *)titleString
{
	self.titleLabel.text = titleString;
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)setCategoryCount:(NSInteger)numberOfItems
{
	self.itemCountLabel.text = [NSString stringWithFormat:@"%ld", (long)numberOfItems];
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)configureAppearance
{
	[self setBackgroundColor:[UIColor lightGrayColor]];
}

@end
