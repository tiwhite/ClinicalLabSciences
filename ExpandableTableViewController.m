//
//  ExpandableTableViewController.m
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 10/24/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import "ExpandableTableViewController.h"


@interface ExpandableTableViewController ()


@property (nonatomic, strong, readwrite) NSMutableArray *sectionStatus;	// array of BOOLs - is section open or closed
@property (nonatomic, strong) NSArray *sectionLength;			// array of INTs - number of rows in section when open
@property (nonatomic, strong, readwrite) NSMutableArray *sectionCurrentLength;	// array of INTs - number of rows
																				// in section now
@property (nonatomic, assign) NSInteger currentlyOpenSection;	// only used when only one section can be open at a time

@end


@implementation ExpandableTableViewController


#pragma mark - Initialization


// ---------------------------------------------------------------------------------------------------------------------
// defines the size and state of each section
- (void)setSectionAndRowCount:(NSArray *)numberOfItemsInSection andSectionStatus:(NSArray *)statusOfSection
{
	// reset each section
	self.sectionStatus = [[NSMutableArray alloc] init];
	self.sectionCurrentLength = [[NSMutableArray alloc] init];
	
	// make sure the status array is either nil or the same size as the row count array
	if (statusOfSection && numberOfItemsInSection.count != statusOfSection.count)
	{
		NSException *mismatchedArrayException = [NSException exceptionWithName:@"Mismatched Arrays"
														reason:@"Status array must be nil or same size as count array"
													  userInfo:nil];
		@throw mismatchedArrayException;
		return;
	}
	
	// iterate through the arrays, make sure they're valid, and assign status
	for (int i = 0; i < numberOfItemsInSection.count; i++)
	{
		// first make sure the only items in the array are numbers (status array can also be nil)
		BOOL isNumVal = ([[numberOfItemsInSection objectAtIndex:i] isKindOfClass:[NSNumber class]]);
		BOOL isStatVal = (statusOfSection == nil || [[statusOfSection objectAtIndex:i] isKindOfClass:[NSNumber class]]);
		if (!isNumVal || !isStatVal)
		{
			NSException *badInputException = [NSException exceptionWithName:@"Not a number"
																	 reason:@"Arrays must only contain NSNumber objects"
																   userInfo:nil];
			@throw badInputException;
			return;
		}
		
		// if the status array is not nil, use it to pre-define the expanded/collapsed state of each section (let the
		// subclass trigger the actual state change)
		if (statusOfSection)
		{
			[self.sectionStatus addObject:[statusOfSection objectAtIndex:i]];
			
			// set the currentSectionLength.  If status is expanded, use the value passed in.  Otherwise use 0.
			if ([[statusOfSection objectAtIndex:i] boolValue] == YES) {
				[self.sectionCurrentLength addObject:[numberOfItemsInSection objectAtIndex:i]];
			} else {
				[self.sectionCurrentLength addObject:@0];
			}
		// if the status array is nil, pre-define all sections to be collapsed, and set currentSectionLength to 0.
		} else {
			[self.sectionStatus addObject:[NSNumber numberWithBool:NO]];
			[self.sectionCurrentLength addObject:@0];
		}
	}
	
	// set the "full" length of each section
	self.sectionLength = numberOfItemsInSection;
}


#pragma mark - Expand and Collapse Sections


// ---------------------------------------------------------------------------------------------------------------------
// required by the ExpandableTableSectionHeaderViewDelegate.  Called by an ExpandableTableSectionHeaderView that needs
// to be either expanded or collapsed
- (void)toggleExpandableSectionView:(ExpandableTableSectionHeaderView *)sectionHeaderView
{
	// retrieve the number of the header and use it to switch the appropriate section
	[self toggleExpandableSectionNumber:sectionHeaderView.sectionNum animated:YES];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)toggleExpandableSectionNumber:(NSInteger)sectionNumber animated:(BOOL)animated
{
	// first flip the current status of the section
	BOOL isSectionOpen = [[self.sectionStatus objectAtIndex:sectionNumber] boolValue];
	isSectionOpen = !isSectionOpen;
	[self.sectionStatus replaceObjectAtIndex:sectionNumber
								  withObject:[NSNumber numberWithBool:isSectionOpen]];
	
	// expand or collapse the section according to its new status
	if (isSectionOpen) {
		[self expandSection:sectionNumber animated:animated];
	} else {
		[self collapseSection:sectionNumber animated:animated];
	}
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)expandExpandableSectionNumber:(NSInteger)sectionNumber animated:(BOOL)animated
{
	// if the section is already expanded, do nothing
	if ([[self.sectionStatus objectAtIndex:sectionNumber] boolValue]) {
		return;
	}
	
	// expand the section
	[self.sectionStatus replaceObjectAtIndex:sectionNumber withObject:[NSNumber numberWithBool:YES]];
	[self expandSection:sectionNumber animated:animated];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)collapseExpandableSectionNumber:(NSInteger)sectionNumber animated:(BOOL)animated
{
	// if the section is already collapsed, do nothing
	if (![[self.sectionStatus objectAtIndex:sectionNumber] boolValue]) {
		return;
	}
	
	// collapse the section
	[self.sectionStatus replaceObjectAtIndex:sectionNumber withObject:[NSNumber numberWithBool:NO]];
	[self collapseSection:sectionNumber animated:animated];
}


#pragma mark - Perform the Actual Expansion/Collapse


// ---------------------------------------------------------------------------------------------------------------------
// Expand a section to display the rows "inside."  In actuality, the sections are normally empty.  This method inserts
// the necessary table rows, and animates the insertion to create the appearance of the section expanding
- (void)expandSection:(NSInteger)section animated:(BOOL)animated
{
	// collapse the currently open section if required
	if (self.shouldLimitOpenSections)
	{
		if (section != self.currentlyOpenSection) {
			[self collapseExpandableSectionNumber:self.currentlyOpenSection animated:animated];
		}
	}
	
	// create an array of index paths to for the rows to be inserted
    NSInteger numberOfRowsToInsert = [[self.sectionLength objectAtIndex:section] integerValue];
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < numberOfRowsToInsert; i++) {
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:section]];
    }
	
	// set the animation to be used
	UITableViewRowAnimation animation;
	if (animated) {
		animation = UITableViewRowAnimationFade;
	} else {
		animation = UITableViewRowAnimationNone;
	}
	
    // insert the new rows.  Record the number as the section's current length.
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:animation];
	[self.sectionCurrentLength setObject:[NSNumber numberWithInteger:numberOfRowsToInsert] atIndexedSubscript:section];
    [self.tableView endUpdates];

	// remember this section so that if only one section can be open this one can be closed later
	self.currentlyOpenSection = section;
	
	// make any necessary appearance changes
	ExpandableTableSectionHeaderView *sectionView =
									(ExpandableTableSectionHeaderView *)[self.tableView headerViewForSection:section];
	[sectionView adjustAppearanceForExpansion:YES];
	
	[self sectionExpanded:section];
	
}


// ---------------------------------------------------------------------------------------------------------------------
// Collapse a section to hide the rows "inside."  In actuality, this method deletes all rows from a section, animating
// the process so it appears the section is collapsing
- (void)collapseSection:(NSInteger)section animated:(BOOL)animated
{
    NSInteger numberOfRowsToDelete = [self.tableView numberOfRowsInSection:section];
	
	// set the animation to be used
	UITableViewRowAnimation animation;
	if (animated) {
		animation = UITableViewRowAnimationFade;
	} else {
		animation = UITableViewRowAnimationNone;
	}
	
	// delete the rows.  Set the section's current length to 0
    if (numberOfRowsToDelete > 0)
	{
        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < numberOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:section]];
        }
		[self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:animation];
		[self.sectionCurrentLength setObject:[NSNumber numberWithInt:0] atIndexedSubscript:section];
		[self.tableView endUpdates];
    }
	
	// make any necessary appearance changes
	ExpandableTableSectionHeaderView *sectionView =
									(ExpandableTableSectionHeaderView *)[self.tableView headerViewForSection:section];
	[sectionView adjustAppearanceForExpansion:NO];
	
	[self sectionCollapsed:section];
}


#pragma mark - Notifications


// ---------------------------------------------------------------------------------------------------------------------
- (void)sectionExpanded:(NSInteger)sectionNumber
{
	// doesn't actually do anything - subclass can overwrite so that it knows when a section's state has changed
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)sectionCollapsed:(NSInteger)sectionNumber
{
	// doesn't actually do anything - subclass can overwrite so that it knows when a section's state has changed
}


@end
