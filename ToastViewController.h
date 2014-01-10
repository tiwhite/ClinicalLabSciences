//
//  ToastViewController.h
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 11/25/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import <UIKit/UIKit.h>


/*
	Class for displaying an alert similar to Android's "Toast" view.  The alert appears for a specified length of time,
	then disappears.
 
	This class is intended to act as a superclass.  Create a subclass to customize the appearance of the alert.  The
	subclass will also contain 
*/


@interface ToastViewController : UIViewController


// public method to display to toast view.  Uses as parameters the name of the nib file to use, 
- (void)displayToastOverView:(UIView *)callingView
					 forTime:(CGFloat)seconds
			 allowTapToAbort:(BOOL)allowTapToAbort;


@end
