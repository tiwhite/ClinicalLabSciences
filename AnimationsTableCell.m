//
//  AnimationsTableCell.m
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 11/22/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import "AnimationsTableCell.h"
#import "UIColor+AppDefinedColors.h"


@interface AnimationsTableCell ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end


@implementation AnimationsTableCell


// ---------------------------------------------------------------------------------------------------------------------
- (void)setTitle:(NSString *)title
{
	self.titleLabel.text = title;
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)configureAppearance
{
	UIView *selectedView = [[UIView alloc] init];
	selectedView.backgroundColor = [UIColor appCellHighlightedColor];
	[self setSelectedBackgroundView:selectedView];
}


@end
