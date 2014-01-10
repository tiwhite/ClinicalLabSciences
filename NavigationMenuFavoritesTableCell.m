//
//  NavigationMenuFavoritesTableCell.m
//  ClinicalLabSciences
//
//  Created by tiwhite on 1/10/14.
//  Copyright (c) 2014 tiwhite. All rights reserved.
//


#import "NavigationMenuFavoritesTableCell.h"

@interface NavigationMenuFavoritesTableCell ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end


@implementation NavigationMenuFavoritesTableCell


// ---------------------------------------------------------------------------------------------------------------------
- (void)setTitle:(NSString *)titleString
{
	self.titleLabel.text = titleString;
}

// ---------------------------------------------------------------------------------------------------------------------
- (void)configureAppearance
{
	[self setBackgroundColor:[UIColor lightGrayColor]];
}

@end
