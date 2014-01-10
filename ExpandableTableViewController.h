//
//  ExpandableTableViewController.h
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 10/24/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ExpandableTableSectionHeaderView.h"


/*
	Superclass for a UIViewController containing a UITableView, where the table is meant to have expandable/collapsable
	sections.  The expansion/collapse is done by inserting/deleting all the rows in a section, using an animation to
	create the illusion that they are always present and are simply being revealed or hidden.
 
	This class contains the code to expand/collapse the sections, but it is assumed that the subclass will contain the
	table logic (UITableViewDelegate, UITableViewDataSource, any code pertaining to cell/section appearance, etc).
 
	This class is meant to be used in conjunction with the ExpandableTableSectionHeaderView class (or a subclass).  The
	ExpandableTableSectionHeaderView assigns a GestureRecognizer to the section header, which is used to trigger the
	section's expansion/collapse.
*/


@interface ExpandableTableViewController : UIViewController <ExpandableTableSectionHeaderViewDelegate>


@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong, readonly) NSMutableArray *sectionStatus;	// array of BOOLs - is section open or closed
@property (nonatomic, strong, readonly) NSMutableArray *sectionCurrentLength; // array of INTs - rows visible in section
@property (nonatomic, assign) BOOL *shouldLimitOpenSections; // set to true if only one section can be open at a time


// inform the class how many rows are in each section, and optionally set the state (expanded/collapsed) of each
// section.  Must be called at least once prior to changing a section's state.  Both arrays must only contain NSNumbers.
// First array --> NSNumber = number of rows in each section.  Second array --> NSNumber = bool, YES = expanded.
- (void)setSectionAndRowCount:(NSArray *)numberOfItemsInSection andSectionStatus:(NSArray *)statusOfSection;

// required by the ExpandableTableSectionHeaderViewDelegate.  Called by a section that wants to be expanded/collapsed.
// can be optionally overridden by a subclass.
- (void)toggleExpandableSectionView:(ExpandableTableSectionHeaderView *)sectionHeaderView;

// normally, the section views will control whether their respective sections are activated or not (using a tap gesture
// recognizer). However, there may be a need by the subclasses to manually activate a section.  The following methods
// are provided for this case
- (void)expandExpandableSectionNumber:(NSInteger)sectionNumber animated:(BOOL)animated;
- (void)collapseExpandableSectionNumber:(NSInteger)sectionNumber animated:(BOOL)animated;
- (void)toggleExpandableSectionNumber:(NSInteger)sectionNumber animated:(BOOL)animated;

// can be used by subclass to monitor state changes
- (void)sectionExpanded:(NSInteger)sectionNumber;
- (void)sectionCollapsed:(NSInteger)sectionNumber;


@end
