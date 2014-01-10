//
//  ProcedureView.h
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 11/6/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import <UIKit/UIKit.h>
@protocol ProcedureSectionDelegate;


/*
	UIView for the different headings in procedure view.  Each procedure page contains several topics: General Info,
	Diagnostic, etc.  Each topic is displayed as a header above a webview.  The section as a whole can be moved up
	or down, in order to focus the user's attention on one section in particular.
*/


@interface ProcedureSectionView : UIView <UIWebViewDelegate>

@property (nonatomic, weak) id <ProcedureSectionDelegate> delegate;
@property (nonatomic, assign) NSInteger index;

- (void)setTitle:(NSString *)title;
- (void)loadWebPage:(NSString *)webPagePath;
- (void)adjustAppearanceForExpansion:(BOOL)isSectionOpen;

@end


@protocol ProcedureSectionDelegate <NSObject>

- (void)procedureSection:(ProcedureSectionView *)procedureSection handleTapGesture:(UITapGestureRecognizer *)tapGesture;
- (void)procedureSection:(ProcedureSectionView *)procedureSection handlePanGesture:(UIPanGestureRecognizer *)panGesture;

@end
