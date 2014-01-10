//
//  ProcedureTransitionManager.h
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 11/12/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import <Foundation/Foundation.h>


/*
	A custom transition for loading a detail view after making a selection from a list.
 
	During a "push" animation, the table view fades and shrinks slightly, as if moving into the background.  At the same
	time, the selected cell begins moving towards the detail view's title position.  While moving, it morphs into the
	actual title view.  When the cell has reached its final position, the detail view animates into view.  The detail
	view is in charge of its own animation.
 
	During a "pop" animation, the detail view cross-fades into the table view.  At the same time, the detail view's
	title morphs back into the table view cell as it returns to its previous position.
*/


@interface ProcedureTransitionManager : NSObject <UIViewControllerAnimatedTransitioning>


@property (nonatomic, assign) BOOL isTransitionPush;	// animation differs between "push" and "pop" transitions
@property (nonatomic, weak) UIView *listCellView;		// the cell selected from the list
@property (nonatomic, assign) CGRect listCellRect;		// the cell's rect - can't use frame b/c cell is inside table
@property (nonatomic, weak) UIView *detailTitleView;	// the title of the detail page


@end
