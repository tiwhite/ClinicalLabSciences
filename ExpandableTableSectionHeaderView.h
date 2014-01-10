//
//  ExpandableTableSectionHeaderView.h
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 10/24/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import <UIKit/UIKit.h>
@protocol ExpandableTableSectionHeaderViewDelegate;


/*
	UITableViewHeaderFooterView for an expandable table.  Uses a UITapGestureRecognizer to trigger the expansion/
	collapse of the section.  Meant to be used in conjunction with an ExpandableTableViewController.
*/


@interface ExpandableTableSectionHeaderView : UITableViewHeaderFooterView

@property (nonatomic, weak) id <ExpandableTableSectionHeaderViewDelegate> delegate;
@property (nonatomic, assign) NSInteger sectionNum;	// set by the table view controller - the index of this header

- (void)adjustAppearanceForExpansion:(BOOL)isSectionExpanded;	// overwrite in subclass to modify appearance when
																// changing between collapsed/expanded state

@end


// define the protocol required to use this class
@protocol ExpandableTableSectionHeaderViewDelegate <NSObject>

// called by this header when wanting to expand/collapse
- (void)toggleExpandableSectionView:(ExpandableTableSectionHeaderView *)sectionHeaderView;

@end