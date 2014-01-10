//
//  HiddenPanelCell.h
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 10/30/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HiddenPanelCellDelegate;


/*
	UITableViewCell that contains a "hidden" section that is revealed using a leftward swipe.  A ViewController using
	this class should implement a method to enable/disable scrolling of the TableView used, as well as a way to
	trigger the closing of the hidden panel when finished.
*/


@interface HiddenPanelCell : UITableViewCell <UIGestureRecognizerDelegate>


@property (nonatomic, weak) id <HiddenPanelCellDelegate> delegate;
@property (nonatomic, assign) BOOL isHiddenPanelExposed;
@property (nonatomic, assign) NSInteger hiddenPanelWidth;	// hidden panel's edge to screen edge distance when open
@property (nonatomic, assign) NSInteger hiddenPanelMaxWidth;// distance user can drag before forcing hidden panel open
@property (nonatomic, strong) NSIndexPath *indexPath;		// each cell should track its own index path (needed to
															// forward user interactions to table - regular "select"
															// functionality needs to be disabled for cells to work

- (void)willRotate;	// cell cannot detect rotation on its own - needs controller of tableview to alert it
- (void)didRotate;
- (void)exposeHiddenPanel;	// let the tableview force cell to open/close
- (void)hideHiddenPanel;
- (void)handleTapGesture:(UITapGestureRecognizer *)gestureRecognizer;	// needed by subclasses to handle taps


@end


// define the protocol required to use this class
@protocol HiddenPanelCellDelegate <NSObject>

// temporarily freeze scrolling while a swipe-to-reveal is in progress
- (void)hiddenPanelCell:(HiddenPanelCell *)hiddenPanelCell toggleScrolling:(BOOL)isScrollingAllowed;

// tell the delegate that the hidden panel has been opened/closed, so that the delegate can respond accordingly
- (void)hiddenPanelCellOpened:(HiddenPanelCell *)hiddenPanelCell;
- (void)hiddenPanelCellClosed:(HiddenPanelCell *)hiddenPanelCell;

// tell the delegate that the cell was tapped
- (void)hiddenPanelCellTapped:(HiddenPanelCell *)hiddenPanelCell;


@end
