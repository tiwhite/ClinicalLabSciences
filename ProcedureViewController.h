//
//  ProcedureViewController.h
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 11/5/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ProcedureSectionView.h"
@class SwipeBackInteractionController;


/*
	View for displaying info about a particular procedure.  When a procedure is selected from the list, it is passed
	to this view controller, which uses the info from the procedure's plist file to display a set of html files to the
	user.
 
	Each procedure has several subsections: General Info, Diagnostic, Pre-Procedure, etc.  Each subsection is shown as a
	row in a list.  Tapping or swiping a subsection will move it so the header is at the top of the view, and the header
	for the next subsection is at the bottom.  Below the selected header is a webview that displays the subsection's
	info to the user.
*/


@interface ProcedureViewController : UIViewController <ProcedureSectionDelegate>


@property (nonatomic, weak) IBOutlet UIView *titleParent;
@property (nonatomic, strong) NSDictionary *procedureDictionary;
@property (nonatomic, weak) SwipeBackInteractionController *swipeBackInteractionController;


// used by the transition controller to animate the appearance of the procedure view
- (void)prepareIntro;
- (void)animateIntro;


@end
