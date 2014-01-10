//
//  ExpandableTableSectionHeaderView.m
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 10/24/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import "ExpandableTableSectionHeaderView.h"


@implementation ExpandableTableSectionHeaderView


// ---------------------------------------------------------------------------------------------------------------------
- (void)awakeFromNib
{
	// create a tap gesture recognizer to detect input
	UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
																				 action:@selector(toggleSectionOpen)];
	[self addGestureRecognizer:recognizer];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)toggleSectionOpen
{
	[self.delegate toggleExpandableSectionView:self];
}

- (void)adjustAppearanceForExpansion:(BOOL)isSectionExpanded
{
	// overwrite in subclass
}

@end
