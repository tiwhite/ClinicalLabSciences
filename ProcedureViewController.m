//
//  ProcedureViewController.m
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 11/5/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import "ProcedureViewController.h"
#import "ProcedureSectionView.h"
#import "SwipeBackInteractionController.h"
#import "FavoritesManager.h"
#import "FavoritesConfirmationViewController.h"
#import "HelpPopupViewController.h"
#import "UserDefaultsConsts.h"
#import <MediaPlayer/MediaPlayer.h>


@interface ProcedureViewController ()

// variables for manipulating sections
@property (nonatomic, strong) IBOutlet UIView *firstSectionWrapper;	// sections added as subviews
@property (nonatomic, strong) NSMutableArray *sectionViewWrappers;			// sections added as subviews
@property (nonatomic, weak) IBOutlet UIView *sectionTopAnchor;		// the area where an "open" section should go
@property (nonatomic, weak) IBOutlet UIView *sectionBottomAnchor;	// area for the section following the open one
@property (nonatomic, assign) NSInteger sectionSpacing;				// distance between sections while closed
@property (nonatomic, weak) IBOutlet UIView *blockerView;			// when sections are closed, hides the content

@property (nonatomic, strong) NSMutableArray *procedureSections;	// the sections that have been added

@property (nonatomic, assign) NSInteger currentlyOpenSection;		// the index of the current section
@property (nonatomic, assign) CGPoint dragStartPosition;			// finger position at start of drag
@property (nonatomic, strong) NSMutableArray *draggedSectionStartPositions;	// position of subviews at start of drag

// UIKit Dynamics
@property (nonatomic) UIDynamicAnimator *dynamicAnimator;
@property (nonatomic, strong) NSMutableArray *resistanceBehaviors;
@property (nonatomic, strong) NSMutableArray *attachmentBehaviors;
@property (nonatomic, assign) CGFloat attachmentSpringFrequency;
@property (nonatomic, assign) CGFloat attachmentSpringDamping;

// title view
@property (nonatomic, weak) IBOutlet UIScrollView *titleScrollView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIView *titleBackground;

// other UI elements
@property (nonatomic, weak) IBOutlet UIView *tabBarView;

// videos
@property (nonatomic, strong) MPMoviePlayerViewController *videoVC;

// favorites
@property (nonatomic, weak) IBOutlet UIButton *btnFavorites;

// other
@property (nonatomic, assign) BOOL hasViewLoaded;		// used during initialization
@property (nonatomic, assign) NSInteger usePanToGoBack;	// how should pan be used: 0 = undecided, -1 = NO, 1 = YES
@property (nonatomic, assign) BOOL hasHelpBeenShown;

@end


@implementation ProcedureViewController


#pragma mark - Initialization


// ---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	[self configureAppearance];
	[self loadSections];
	
	self.attachmentSpringFrequency = 3;
	self.attachmentSpringDamping = 0.75;
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
{
	// the dynamic behaviors should only be initialized once, but viewDidLoad is too early
	if (!self.hasViewLoaded) {
		self.hasViewLoaded = YES;
		[self initializeDynamicBehaviors];
	}
	[self.titleScrollView performSelector:@selector(flashScrollIndicators) withObject:nil afterDelay:0.01];
	[self configureTitleSize];
	
	
	if (!self.hasHelpBeenShown) {
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		self.hasHelpBeenShown = [[userDefaults objectForKey:kDefaultsHelpProcedureShown] boolValue];
		
		if (!self.hasHelpBeenShown) {
			[userDefaults setObject:[NSNumber numberWithBool:YES] forKey:kDefaultsHelpProcedureShown];
			[userDefaults synchronize];
			[HelpPopupViewController showHelpForProcedureOverView:self];
		}
		self.hasHelpBeenShown = YES;
	}
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)configureAppearance
{
	NSString *procedureName = [self.procedureDictionary objectForKey:@"Name"];
	
	// title
	self.titleLabel.text = procedureName;
	[self configureTitleSize];
	
	// nav bar
	UIImageView *titleImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"NavigationTitle"]];
	self.navigationItem.titleView = titleImage;
	
	UIImage *buttonImage = [[UIImage imageNamed:@"btnBack_normal"]
							imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
	UIBarButtonItem *backBtn = [[UIBarButtonItem alloc] initWithImage:buttonImage
																style:UIBarButtonItemStylePlain
															   target:self
															   action:@selector(goBack:)];
	self.navigationItem.leftBarButtonItem = backBtn;
	
	// tab bar
	self.btnFavorites.titleLabel.numberOfLines = 0;
	self.btnFavorites.titleLabel.textAlignment = NSTextAlignmentCenter;
	if ([[FavoritesManager favoritesManagerInstance] isProcedureAFavorite:procedureName]) {
		[self toggleFavButtonText:YES];
	} else {
		[self toggleFavButtonText:NO];
	}
	
	// other
	self.view.backgroundColor = [UIColor whiteColor];
	self.sectionSpacing = 46;
	self.currentlyOpenSection = -1;
}


// ---------------------------------------------------------------------------------------------------------------------
// some titles are longer than the screen allows.  A scroll view allows the user to see them in their entirety, but the
// size of the scroll view needs to be determined
- (void)configureTitleSize
{
	NSString *procedureName = [self.procedureDictionary objectForKey:@"Name"];
	CGFloat titleWidth = [procedureName sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}].width + 4;
	
	// title has 2 lines - if width is greater than label's size but less than 2x label size, it will all fit on screen
	// and there is no reason to scroll.  If width is greater than 2x label size, cut it in half to account for 2nd line
	if (titleWidth > self.titleLabel.frame.size.width * 2) {
		titleWidth = titleWidth / 2;
	} else if (titleWidth > self.titleLabel.frame.size.width) {
		titleWidth = self.titleLabel.frame.size.width;
	}
	
	// set the label's frame and scrollview's content size according to the new width
	self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, self.titleLabel.frame.origin.y,
									   titleWidth, self.titleLabel.frame.size.height);
	self.titleScrollView.contentSize = CGSizeMake(titleWidth + 40, self.titleLabel.frame.size.height);
}


// ---------------------------------------------------------------------------------------------------------------------
// load the nib file containing the section layout into each of the section wrapper views
- (void)loadSections
{
	NSDictionary *subheadings = [self.procedureDictionary objectForKey:@"SubHeadings"];
	NSArray *subheadingsTitles = [subheadings allKeys];
	
	self.procedureSections = [[NSMutableArray alloc] init];
	self.sectionViewWrappers = [[NSMutableArray alloc] init];
	
	CGRect wrapperFrame = self.firstSectionWrapper.frame;
	
	// load the section nib file into each wrapper view
	for (int i = 0; i < subheadingsTitles.count; i++)
	{
		wrapperFrame.origin.y = self.firstSectionWrapper.frame.origin.y + (self.sectionSpacing * i);
		UIView *wrapper = [[UIView alloc] initWithFrame:wrapperFrame];
		
		if (i == 0) {
			[self.view insertSubview:wrapper aboveSubview:self.firstSectionWrapper];
		} else {
			[self.view insertSubview:wrapper aboveSubview:[self.sectionViewWrappers objectAtIndex:i - 1]];
		}
		[self.sectionViewWrappers addObject:wrapper];
		
		NSArray *bundle = [[NSBundle mainBundle] loadNibNamed:@"ProcedureSectionView" owner:self options:nil];
		for (id object in bundle)
		{
			// find the section view and add it to the wrapper view
			if ([object isKindOfClass:[ProcedureSectionView class]])
			{
				ProcedureSectionView *procedureSection = (ProcedureSectionView *)object;
				[procedureSection setTitle:[subheadingsTitles objectAtIndex:i]];
				procedureSection.delegate = self;
				procedureSection.index = i;
				CGRect sectionFrame = wrapper.frame;
				procedureSection.frame = CGRectMake(0, 0, sectionFrame.size.width, sectionFrame.size.height);
				[wrapper addSubview:procedureSection];
				[self.procedureSections addObject:procedureSection];
			}
		}
	}
	
	wrapperFrame.origin.y = self.firstSectionWrapper.frame.origin.y + (self.sectionSpacing * subheadingsTitles.count);
	self.blockerView.frame = wrapperFrame;
	[self.sectionViewWrappers addObject:self.blockerView];
}


// ---------------------------------------------------------------------------------------------------------------------
// each section contains a webview to display content to the user - load those webviews
- (void)loadWebViews
{
	NSDictionary *subheadings = [self.procedureDictionary objectForKey:@"SubHeadings"];
	NSArray *subheadingsTitles = [subheadings allKeys];
	
	for (int i = 0; i < subheadingsTitles.count; i++)
	{
		NSString *subheadingsPath = [subheadings objectForKey:[subheadingsTitles objectAtIndex:i]];
		[((ProcedureSectionView *)[self.procedureSections objectAtIndex:0]) loadWebPage:subheadingsPath];
	}
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)initializeDynamicBehaviors
{
	if (self.dynamicAnimator == nil) {
		UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
		self.dynamicAnimator = animator;
	}
	
	// need an attachment and resistance behavior for each section
	self.attachmentBehaviors = [[NSMutableArray alloc] init];
	self.resistanceBehaviors = [[NSMutableArray alloc] init];
	
	for (int i = 0; i < self.sectionViewWrappers.count; i++)
	{
		// get the focus of the behaviors
		UIView *sectionView = [self.sectionViewWrappers objectAtIndex:i];
		
		// find the attachment point (center of the section's "header")
		CGPoint centerPoint = sectionView.center;
		UIOffset offsetFromSectionCenter = [self calculateSectionAnchorOffset];
		centerPoint.y += offsetFromSectionCenter.vertical;
		
		// configure the attachment behavior
		UIAttachmentBehavior *attach = [[UIAttachmentBehavior alloc] initWithItem:sectionView
																 offsetFromCenter:offsetFromSectionCenter
																 attachedToAnchor:centerPoint];
		[self.attachmentBehaviors addObject:attach];
		[self.dynamicAnimator addBehavior:attach];
		
		// configure the resistance behavior
		UIDynamicItemBehavior *resist = [[UIDynamicItemBehavior alloc]
										 initWithItems:@[[self.sectionViewWrappers objectAtIndex:i]]];
		resist.resistance = 5;
		resist.angularResistance = 100000;
		[self.resistanceBehaviors addObject:resist];
		[self.dynamicAnimator addBehavior:resist];
		
		// add colliders on the left and right sides of the screen to help keep sections aligned properly
		UICollisionBehavior *leftBorder = [[UICollisionBehavior alloc] initWithItems:@[sectionView]];
		[leftBorder addBoundaryWithIdentifier:@"leftBorder"
									fromPoint:CGPointMake(self.view.frame.origin.x, self.view.frame.origin.y)
									  toPoint:CGPointMake(self.view.frame.origin.x, self.view.frame.size.height * 2)];
		[self.dynamicAnimator addBehavior:leftBorder];
		
		UICollisionBehavior *rightBorder = [[UICollisionBehavior alloc] initWithItems:@[sectionView]];
		[leftBorder addBoundaryWithIdentifier:@"rightBorder"
									fromPoint:CGPointMake(self.view.frame.size.width, self.view.frame.origin.y)
									  toPoint:CGPointMake(self.view.frame.size.width, self.view.frame.size.height * 2)];
		[self.dynamicAnimator addBehavior:rightBorder];
	}
}


// ---------------------------------------------------------------------------------------------------------------------
// find the offset from the section's center to the center of its header
- (UIOffset)calculateSectionAnchorOffset
{
	NSInteger baseHeight = ((UIView *)[self.sectionViewWrappers objectAtIndex:0]).frame.size.height / 2;
	NSInteger tappableAreaOffset = 44;	// NOTE: consider replacing hardcode
	
	NSInteger offsetVal = -baseHeight + (tappableAreaOffset / 2);
	
	return UIOffsetMake(0, offsetVal);
}


#pragma mark - Intro Animation
// the procedure view becomes visible using a crossfade.  However, the title needs to become visible at a different rate
// than the other elements.  So, the title will remain opaque, allowing its animation to coincide with the main view's
// animation.  Each of the other elements will fade in separately


// ---------------------------------------------------------------------------------------------------------------------
// make everything but the title very faint
- (void)prepareIntro
{
	for (int i = 0; i < self.sectionViewWrappers.count; i++)
	{
		UIView *view = ((UIView *)[self.sectionViewWrappers objectAtIndex:i]);
		view.alpha = 0.25;
	}
	
	self.tabBarView.alpha = 0.25;
}


// ---------------------------------------------------------------------------------------------------------------------
// unfade everything but the title
- (void)animateIntro
{
	// the section wrappers
	for (int i = 0; i < self.sectionViewWrappers.count; i++)
	{
		UIView *view = ((UIView *)[self.sectionViewWrappers objectAtIndex:i]);
		
		[UIView animateWithDuration:.2
						 animations:^{
							 view.alpha = 1;
						 }
						 completion:^(BOOL finished) {
							 if (i == 0) {
								 [self loadWebViews];
							 }
						 }
		 ];
	}
	
	// the tab bar
	[UIView animateWithDuration:0.2
					 animations:^{
						 self.tabBarView.alpha = 1;
					 }];
}


#pragma mark - Procedure Section Delegate


// ---------------------------------------------------------------------------------------------------------------------
- (void)procedureSection:(ProcedureSectionView *)procedureSection handleTapGesture:(UITapGestureRecognizer *)tapGesture
{
	if (procedureSection.index == self.currentlyOpenSection) {
		[self closeAllSections];
	} else {
		[self openSection:procedureSection.index];
	}
}


// ---------------------------------------------------------------------------------------------------------------------
// this method is called by pan gesture recognizers in each of the sections.  Depending on the direction of the pan,
// the behavior desired might be different
- (void)procedureSection:(ProcedureSectionView *)procedureSection handlePanGesture:(UIPanGestureRecognizer *)panGesture
{
	// if user is swiping to go back, use the SwipeBackInteractionController to return to the list view
	if (self.usePanToGoBack == 1)
	{
		[self.swipeBackInteractionController handlePanGesture:panGesture];
		
		if (panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateEnded)
		{
			self.usePanToGoBack = 0;
		}
		
		return;
	}
	
	switch (panGesture.state)
	{
		case UIGestureRecognizerStateBegan:
			// figure out where the drag began and where each wrapper is at the start of the pan
			self.dragStartPosition = [panGesture locationInView:self.view];
			self.draggedSectionStartPositions = [[NSMutableArray alloc] init];
			for (int i = 0; i < self.sectionViewWrappers.count; i++) {
				CGPoint startingPos = ((UIAttachmentBehavior *) [self.attachmentBehaviors objectAtIndex:i]).anchorPoint;
				NSValue *pointObject = [NSValue valueWithCGPoint:startingPos];
				[self.draggedSectionStartPositions addObject:pointObject];
			}
			break;
		case UIGestureRecognizerStateChanged:
			{
				NSInteger deltaY = [panGesture locationInView:self.view].y - self.dragStartPosition.y;
				
				// there are two behaviors that can result from a pan: going back, and moving the sections up/down
				// if undecided, need to decide
				if (self.usePanToGoBack == 0)
				{
					NSInteger deltaX = [panGesture locationInView:self.view].x - self.dragStartPosition.x;
					
					// if swiping from left edge AND swipe is horizontal, treat it as "back" gesture
					if (self.dragStartPosition.x < 25 && deltaX > 20 && deltaY < 8)
					{
						self.usePanToGoBack = 1;
						[self.swipeBackInteractionController beginTransitionFromOtherClass];
					// if not swiping from left edge, or if gesture is too vertical, treat as attempt to move sections
					} else if (self.dragStartPosition.x > 25 || (deltaX < 20 && deltaY > 8)) {
						self.usePanToGoBack = -1;
					}
				}
				
				// move the section, even if purpose of gesture is undetermined
				[self dragSection:procedureSection.index toPosition:deltaY];
			}
			break;
		case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateEnded:
			{
				self.usePanToGoBack = 0;
				NSInteger location = [panGesture locationInView:self.view].y;
				NSInteger velocity = [panGesture velocityInView:self.view].y;
				[self finishedDraggingSection:procedureSection.index position:location velocity:velocity];
			}
			break;
		default:
			break;
	}
}


#pragma mark - Manipulate Sections


// ---------------------------------------------------------------------------------------------------------------------
// move the selected section to the top anchor.  All previous sections should move with it.
// move the following section to the bottom anchor.  All following sections should move with it.
- (void)openSection:(NSInteger)sectionIndex
{
	// all sections will need to be moved
	for (int i = 0; i < self.sectionViewWrappers.count; i++)
	{
		// get the attachment associated with the current section
		UIAttachmentBehavior *currentAttachment = (UIAttachmentBehavior *)[self.attachmentBehaviors objectAtIndex:i];
		
		// set the frequency and damping so the attachment will act as a spring rather than be instantaneous
		currentAttachment.frequency = self.attachmentSpringFrequency;
		currentAttachment.damping = self.attachmentSpringDamping;
		
		// the final location of the attachment
		CGPoint dock;
		
		// the selected attachment should go to the top, all previous attachments proportionately higher
		if (i <= sectionIndex) {
			dock = CGPointMake(self.sectionTopAnchor.frame.size.width / 2,
						self.sectionTopAnchor.frame.origin.y + (self.sectionTopAnchor.frame.size.height / 2));
			dock.y -= self.sectionSpacing * (sectionIndex - i);
			
		// the next attachment should go to the bottom, all following attachments proportionately lower
		} else {
			dock = CGPointMake(self.sectionBottomAnchor.frame.size.width / 2,
						self.sectionBottomAnchor.frame.origin.y + self.sectionBottomAnchor.frame.size.height / 2);
			dock.y += self.sectionSpacing * (i - sectionIndex - 1);
		}
		
		// set the attachment destination to move the section
		[currentAttachment setAnchorPoint:dock];
		
		// set the disclosure indicator on the section
		if (i < self.procedureSections.count) {
			ProcedureSectionView *openedSection = [self.procedureSections objectAtIndex:i];
			[openedSection adjustAppearanceForExpansion:(i == sectionIndex)];
		}
	}
	
	// record the section that just moved
	self.currentlyOpenSection = sectionIndex;
}


// ---------------------------------------------------------------------------------------------------------------------
// return all sections to their original positions
- (void)closeAllSections
{
	for (int i = 0; i < self.sectionViewWrappers.count; i++)
	{
		// get the attachment for the current section, and set it to behave as a spring
		UIAttachmentBehavior *currentAttachment = (UIAttachmentBehavior *)[self.attachmentBehaviors objectAtIndex:i];
		currentAttachment.frequency = self.attachmentSpringFrequency;
		currentAttachment.damping = self.attachmentSpringDamping;
		
		// set the position based on the section's index
		CGPoint dock = CGPointMake(self.sectionTopAnchor.frame.size.width / 2,
							self.sectionTopAnchor.frame.origin.y + self.sectionTopAnchor.frame.size.height / 2);
		dock.y += self.sectionSpacing * i;
		
		[currentAttachment setAnchorPoint:dock];
		
		// set the disclosure indicator on the section
		if (i < self.procedureSections.count) {
			ProcedureSectionView *openedSection = [self.procedureSections objectAtIndex:i];
			[openedSection adjustAppearanceForExpansion:NO];
		}
	}
	
	// no section is currently "open"
	self.currentlyOpenSection = -1;
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)dragSection:(NSInteger)sectionIndex toPosition:(NSInteger)yPosition
{
	// all the sections will be moving
	for (int i = 0; i < self.sectionViewWrappers.count; i++)
	{
		if (i == sectionIndex || (self.currentlyOpenSection == -1))
		{
			// get the attachment for the current section
			UIAttachmentBehavior *currentAttachment = (UIAttachmentBehavior*)[self.attachmentBehaviors objectAtIndex:i];
		
			// remove any prior spring behavior - want view to follow finger exactly
			currentAttachment.frequency = 0;
			currentAttachment.damping = 0;
		
			// section should follow the finger's movements exactly if:
			//	- the section is the one the user began dragging
			//	- the section precedes the one the user dragged, AND the user is dragging up
			//	- the section follows the one the user dragged, AND the user is dragging down
			if ((i == sectionIndex) || (i < sectionIndex && yPosition <= 0) || (i > sectionIndex && yPosition >= 0))
			{
				CGPoint newAnchorPos = [[self.draggedSectionStartPositions objectAtIndex:i] CGPointValue];
				newAnchorPos.y += yPosition;
			
				[currentAttachment setAnchorPoint:newAnchorPos];
			// otherwise, the section should move in the direction opposite the drag.  The amount moved is based on
			// percentages rather than matching the user's movements
			} else {
				// get the total distance between the starting position of the CURRENT anchor and the correct dock
				CGPoint targetPoint;
				if (i < sectionIndex) {
					targetPoint = self.sectionTopAnchor.center;
					targetPoint.y -= (sectionIndex - 1 - i) * self.sectionSpacing;
				} else {
					targetPoint = self.sectionBottomAnchor.center;
					targetPoint.y += (i - sectionIndex - 1) * self.sectionSpacing;
				}
				NSInteger fullDistance = [[self.draggedSectionStartPositions objectAtIndex:i] CGPointValue].y
											- targetPoint.y;
				
				// get the total distance between DRAGGED anchor's starting position and the dock it's moving towards
				CGPoint dragTargetPoint;
				if (yPosition > 0) {
					dragTargetPoint = self.sectionBottomAnchor.center;
				} else {
					dragTargetPoint = self.sectionTopAnchor.center;
				}
				NSInteger dragFullDistance =
				[[self.draggedSectionStartPositions objectAtIndex:sectionIndex] CGPointValue].y - dragTargetPoint.y;
				
				// patch to fix bug that occurs when user drags the top section up
				if (dragFullDistance == 0) {
					dragFullDistance = 25;
				}
				
				// get the percent complete of the DRAGGED anchor
				NSInteger dragCurrentDistance =
						((UIAttachmentBehavior *)[self.attachmentBehaviors objectAtIndex:sectionIndex]).anchorPoint.y
						- [[self.draggedSectionStartPositions objectAtIndex:sectionIndex] CGPointValue].y;
				
				CGFloat percent = (CGFloat)dragCurrentDistance / dragFullDistance;
				// move the CURRENT anchor a corresponding percent
				CGFloat currentDistance = fullDistance * percent;
				CGPoint newPosition = [[self.draggedSectionStartPositions objectAtIndex:i] CGPointValue];
				newPosition.y += currentDistance;
				[currentAttachment setAnchorPoint:newPosition];
			}
		}
	}
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)finishedDraggingSection:(NSInteger)sectionIndex position:(NSInteger)yPosition velocity:(NSInteger)yVelocity
{
	NSInteger indexToOpen = -1;
	NSInteger velocityThreshold = 200;
	NSInteger distanceThreshold = 125;
	
	if (sectionIndex > 0)
	{
		// first check the speed
		// if moving quickly down, open the section BEFORE the current one
		if (yVelocity > velocityThreshold) {
			indexToOpen = sectionIndex - 1;
		// if moving quickly up, open CURRENT section or close
		} else if (yVelocity < -velocityThreshold) {
			if (self.currentlyOpenSection != -1 || yPosition <
				[[self.draggedSectionStartPositions objectAtIndex:sectionIndex] CGPointValue].y)
			{
				indexToOpen = sectionIndex;
			}
		// if not moving quickly, use position to decide
		} else {
			NSInteger delta = [[self.draggedSectionStartPositions objectAtIndex:sectionIndex] CGPointValue].y
								- yPosition;
			if (delta < -distanceThreshold) {
				indexToOpen = sectionIndex - 1;
			} else if (delta > distanceThreshold) {
				indexToOpen = sectionIndex;
			} // else = little movement, keep reset
		}
	// if swiping down on top section, and if a section is open, close all of them
	} else if (self.currentlyOpenSection != -1) {
		NSInteger delta = [[self.draggedSectionStartPositions objectAtIndex:sectionIndex] CGPointValue].y
								- yPosition;
		if (yVelocity > velocityThreshold || delta < -distanceThreshold) {
			[self closeAllSections];
			return;
		}
	}
	
	if (indexToOpen == -1) {
		[self resetSectionsFromDrag];
	} else {
		[self openSection:indexToOpen];
	}
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)resetSectionsFromDrag
{
	// move the selected section and all following ones
	for (int i = 0; i < self.sectionViewWrappers.count; i++)
	{
		// get the attachment for the current section
		UIAttachmentBehavior *currentAttachment = (UIAttachmentBehavior *)[self.attachmentBehaviors objectAtIndex:i];
		
		// remove any prior spring behavior - want view to follow finger exactly
		currentAttachment.frequency = 3;
		currentAttachment.damping = .75;
		
		CGPoint newAnchorPos = [[self.draggedSectionStartPositions objectAtIndex:i] CGPointValue];
		
		[currentAttachment setAnchorPoint:newAnchorPos];
	}
}


#pragma mark - Favorites


// ---------------------------------------------------------------------------------------------------------------------
- (void)toggleFavButtonText:(BOOL)isProcedureFavorite
{
	if (isProcedureFavorite) {
		[self.btnFavorites setImage:[UIImage imageNamed:@"btnRemoveFavorite_normal"] forState:UIControlStateNormal];
		[self.btnFavorites removeTarget:self
								 action:@selector(addProcedureToFavorites)
					   forControlEvents:UIControlEventTouchUpInside];
		[self.btnFavorites addTarget:self
							  action:@selector(removeProcedureFromFavorites)
					forControlEvents:UIControlEventTouchUpInside];
	} else {
		[self.btnFavorites setImage:[UIImage imageNamed:@"btnAddFavorite_normal"] forState:UIControlStateNormal];
		[self.btnFavorites removeTarget:self
								 action:@selector(removeProcedureFromFavorites)
					   forControlEvents:UIControlEventTouchUpInside];
		[self.btnFavorites addTarget:self
							  action:@selector(addProcedureToFavorites)
					forControlEvents:UIControlEventTouchUpInside];
	}
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)addProcedureToFavorites
{
	[FavoritesConfirmationViewController showConfirmation:YES overView:self.view];
	[[FavoritesManager favoritesManagerInstance] addProcedureToFavorites:[self.procedureDictionary objectForKey:@"Name"]];
	[self toggleFavButtonText:YES];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)removeProcedureFromFavorites
{
	[FavoritesConfirmationViewController showConfirmation:NO overView:self.view];
	[[FavoritesManager favoritesManagerInstance] removeProcedureFromFavorites:[self.procedureDictionary objectForKey:@"Name"]];
	[self toggleFavButtonText:NO];
}


#pragma mark - Other


// ---------------------------------------------------------------------------------------------------------------------
- (void)goBack:(id)sender
{
	[self.navigationController popViewControllerAnimated:YES];
}


// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)playVideo:(id)sender
{
	NSString *filePath = [[NSBundle mainBundle] pathForResource:[self.procedureDictionary objectForKey:@"VideoPath"] ofType:@"mp4"];
	NSURL *fileURL = [NSURL fileURLWithPath:filePath];
	self.videoVC = [[MPMoviePlayerViewController alloc] initWithContentURL:fileURL];
	[self presentMoviePlayerViewControllerAnimated:self.videoVC];
	[self.videoVC.moviePlayer play];
}


@end
