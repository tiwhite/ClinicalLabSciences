//
//  AnimationsTableViewController.h
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 11/21/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import <UIKit/UIKit.h>
@class RootViewController;


/*
	Displays a list of animations, sorted alphabetically, to choose from.
 
	For now, tapping a procedure loads a corresponding video.
*/


@interface AnimationsTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>


@property (nonatomic, weak) RootViewController *rootViewController;


@end
