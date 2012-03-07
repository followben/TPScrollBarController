//
//  TPScrollBarController.m
//  TPScrollBarController
//
//  Copyright 2011 Ben Stovold. All rights reserved.
//

#import "TPScrollBarController.h"
#import <objc/message.h>
#import <QuartzCore/QuartzCore.h>

#pragma mark Constants and enums
static  CGFloat const   kDefaultScrollBarHeight = 66.f;
static  BOOL    const   kDefaultScrollBarShouldShowScrollIndicators = YES;
static  BOOL    const   kDefaultScrollBarShouldAlwaysBounce = YES;

#pragma mark -
@interface TPScrollBarController ()

@property(nonatomic)  UIViewController *selectedViewController;
@property(nonatomic)  NSUInteger       selectedScrollBarPage;

@property(nonatomic, strong)  UIScrollView     *scrollBar;
@property(nonatomic, strong)  UIView           *contentView;
@property(nonatomic, strong)  NSOrderedSet     *scrollBarPageSet;
@property(nonatomic, strong)  NSArray          *barButtons;
@property(nonatomic, strong)  NSArray          *scrollBarPageArray;
@property(nonatomic, strong)  NSArray          *registry;
@property(nonatomic, assign)  BOOL             shouldForwardAppearanceAndRotationMethodsToChildViewControllers;

- (void)performSelectorOnDelegate:(SEL)aSelector withObject:(id)param1 andObject:(id)param2;
- (void)initaliseContainerViews;
- (void)layoutBarButtons;
- (void)barButtonReceivedTouchDown:(UIButton *)sender;
- (void)barButtonReceivedTouchUpInside:(UIButton *)sender;

@end


#pragma mark -
@implementation TPScrollBarController

#pragma mark Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        registry_ = [NSArray array];
        scrollBarHeight_ = kDefaultScrollBarHeight;
        scrollBarShouldDisplayScrollIndicators_ = kDefaultScrollBarShouldShowScrollIndicators;
        scrollBarShouldAlwaysBounce_ = kDefaultScrollBarShouldAlwaysBounce;
        
        // Don't forward these methods until the root view has been loaded
        // (i.e. we set this to YES in viewWillAppear)
        shouldForwardAppearanceAndRotationMethodsToChildViewControllers_ = NO;
        selectedScrollBarPage_ = 1;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark Accessors and mutators

@synthesize delegate = delegate_;
@synthesize scrollBar = scrollBar_;
@synthesize scrollBarHeight = scrollBarHeight_;
@synthesize scrollBarShouldDisplayScrollIndicators = scrollBarShouldDisplayScrollIndicators_;
@synthesize scrollBarShouldAlwaysBounce = scrollBarShouldAlwaysBounce_;
@synthesize contentView = contentView_;
@synthesize selectedViewController = selectedViewController_;
@synthesize scrollBarPageSet = scrollBarPageSet_;
@synthesize selectedScrollBarPage = selectedScrollBarPage_;
@synthesize barButtons = barButtons_;

@synthesize scrollBarPageArray = scrollBarPageArray_;
@synthesize registry = registry_;
@synthesize shouldForwardAppearanceAndRotationMethodsToChildViewControllers = shouldForwardAppearanceAndRotationMethodsToChildViewControllers_;


#pragma mark - View lifecycle

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
{
    return self.shouldForwardAppearanceAndRotationMethodsToChildViewControllers;
}

- (void)loadView
{
    [super loadView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Now we can forward events.
    self.shouldForwardAppearanceAndRotationMethodsToChildViewControllers = YES;
    
    [self initaliseContainerViews];
    [self resizeScrollBarForNumberOfPages:((NSNumber *)[self.scrollBarPageSet lastObject]).intValue];
    [self layoutBarButtons];
    [self.contentView addSubview:self.selectedViewController.view];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    self.scrollBar = nil;
    self.contentView = nil;
    [super viewDidUnload];
}


#pragma mark - UIInterfaceOrientation methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Public methods

- (void)setBarButtons:(NSArray *)barButtons
     onScrollBarPages:(NSArray *)pageNumbers
    withDefaultButton:(UIButton *)defaultButton
{
    NSAssert([barButtons count] == [pageNumbers count], @"barButton and pageNumber arrays must contain the same number of objects");
    for (UIButton *barButton in barButtons) {
        [barButton addTarget:self action:@selector(barButtonReceivedTouchDown:) forControlEvents:UIControlEventTouchDown];
        [barButton addTarget:self action:@selector(barButtonReceivedTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    }

    for (NSNumber *pageNumber in pageNumbers) {
        NSAssert([pageNumber integerValue] > 0, @"pageNumbers must be greater than zero");
    }
    
    NSSortDescriptor *ascending = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    NSMutableArray *numbers = [NSMutableArray arrayWithArray:pageNumbers];
    [numbers sortUsingDescriptors:[NSArray arrayWithObject:ascending]];
    self.scrollBarPageSet = [NSOrderedSet orderedSetWithArray:numbers];
    self.selectedViewController = [self viewControllerForButton:defaultButton];
    self.barButtons = barButtons;
    self.scrollBarPageArray = pageNumbers;

    
}

- (void)resizeScrollBarForNumberOfPages:(NSUInteger)pages
{
    CGSize size = self.scrollBar.frame.size;
    size.width = [[UIScreen mainScreen] applicationFrame].size.width * pages;
    if (pages == 1 && self.scrollBarShouldAlwaysBounce) size.width = size.width + 1.0f;
    self.scrollBar.contentSize = size;
}

- (void)selectScrollBarPage:(NSUInteger)pageNumber animated:(BOOL)animated
{
    NSUInteger pageWidth = [[UIScreen mainScreen] applicationFrame].size.width;
    CGRect frame = self.scrollBar.bounds;
    frame.origin.x = pageWidth * (pageNumber - 1);
    [self.scrollBar scrollRectToVisible:frame animated:animated];
    self.selectedScrollBarPage = pageNumber;
}

- (void)selectViewController:(UIViewController *)childViewController
{
    [self transitionFromViewController:self.selectedViewController toViewController:childViewController duration:0 options:UIViewAnimationTransitionNone animations:^{} completion:^(BOOL finished) {
        self.selectedViewController = childViewController;
    }];
}

- (void)setFullScreenMode:(BOOL)moveToFullScreen animated:(BOOL)animated
{
    // If full the view is already in full screen mode
    if (moveToFullScreen && (self.contentView.frame.size.height == [[UIScreen mainScreen] applicationFrame].size.height))
        return;
    
    // Hide the scroll bar before growing the content frame
    if (!moveToFullScreen)
        self.scrollBar.hidden = NO;
    
    CGRect __block frame = self.contentView.frame;
    if (moveToFullScreen)
        frame.size.height = [[UIScreen mainScreen] applicationFrame].size.height;
    else
        frame.size.height = [[UIScreen mainScreen] applicationFrame].size.height - self.scrollBarHeight;
    
    if (animated) {
        UIViewAnimationCurve animationCurve = moveToFullScreen ? UIViewAnimationCurveEaseOut : UIViewAnimationCurveEaseIn;
        [UIView animateWithDuration:0.3 delay:0 options:animationCurve animations:^{
            self.contentView.frame = frame;
        } completion: ^(BOOL finished) {
            if (moveToFullScreen)
                self.scrollBar.hidden = YES;
        }];
    } else {
        self.contentView.frame = frame;
        if (moveToFullScreen)
            self.scrollBar.hidden = YES;
    }
}


#pragma mark - Private methods

- (void)performSelectorOnDelegate:(SEL)aSelector withObject:(id)param1 andObject:(id)param2;
{
    if ([delegate_ respondsToSelector:aSelector])
        objc_msgSend(delegate_, aSelector, param1, param2); // performSelector: generates compiler warnings under ARC
}

// Initialises an empty scrollBar and contentView and adds them as subviews.
- (void)initaliseContainerViews
{
    CGFloat xpos = 0.f;
    CGFloat width = [[UIScreen mainScreen] applicationFrame].size.width;
    CGFloat ypos = [[UIScreen mainScreen] applicationFrame].size.height - self.scrollBarHeight;
    self.scrollBar = [[UIScrollView alloc] initWithFrame:CGRectMake(xpos, ypos, width, self.scrollBarHeight)];
    self.scrollBar.backgroundColor = [UIColor clearColor];
    self.scrollBar.opaque = NO;
    self.scrollBar.clipsToBounds = YES;
    self.scrollBar.scrollEnabled = YES;
	self.scrollBar.pagingEnabled = YES;
    self.scrollBar.showsHorizontalScrollIndicator = self.scrollBarShouldDisplayScrollIndicators;
    self.scrollBar.showsVerticalScrollIndicator = self.scrollBarShouldDisplayScrollIndicators;
    [self.view addSubview:self.scrollBar];

    
    ypos = [[UIScreen mainScreen] bounds].origin.y;
    CGFloat height = [[UIScreen mainScreen] applicationFrame].size.height - self.scrollBarHeight;
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(xpos, ypos, width, height)];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.contentView.opaque = NO;
    self.contentView.clipsToBounds = YES;
    [self.view addSubview:self.contentView];
}

- (void)layoutBarButtons
{
    // For each page (in order)
    for (NSNumber *page in self.scrollBarPageSet) {
        
        NSUInteger pageWidth = [[UIScreen mainScreen] applicationFrame].size.width;
        
        // Get indicies of buttons for this page
        NSIndexSet *buttonIndexSet = [self.scrollBarPageArray indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return obj == page;
        }];
        
        // Calculate the total width of buttons on this page.
        __block NSUInteger widthOfButtonsOnThisPage = 0;
        [buttonIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            UIButton *barButton = [self.barButtons objectAtIndex:idx];
            widthOfButtonsOnThisPage = widthOfButtonsOnThisPage + barButton.frame.size.width;
        }];
        
        NSAssert(widthOfButtonsOnThisPage < pageWidth, @"Can't fit barButtons on page %f", page);
        
        NSUInteger numberOfButtonsOnThisPage = [buttonIndexSet count];
        
        __block NSUInteger offset;
        
        // Calculate how far to offset each button from the left of the last one.
        offset = (pageWidth - widthOfButtonsOnThisPage) / (numberOfButtonsOnThisPage + 1);
        
        // Set the x position for the first button.
        __block NSUInteger xpos = offset + (pageWidth * (page.integerValue - 1));
        
        // For each button on the page (in order)
        [buttonIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            
            UIButton *barButton = [self.barButtons objectAtIndex:idx];
            
            // place it on the scrollBar according to the page offset.
            CGRect newFrame = barButton.frame;
            newFrame.origin.x = xpos;
            if (newFrame.origin.y == 0) newFrame.origin.y = (self.scrollBarHeight - barButton.frame.size.height) / 2;
            barButton.frame = newFrame;
            [self.scrollBar addSubview:barButton];
            
            // Calculate the x origin for the next pass through
            xpos = xpos + barButton.frame.size.width + offset;
            
        }];
    }
}

- (void)barButtonReceivedTouchDown:(UIButton *)sender
{
    UIViewController *targetViewController = [self viewControllerForButton:sender];
    SEL selector = [self selectorForButton:sender];
    
    if (targetViewController) {
        // If the target isn't the current viewController, transition to the new view
        if (![self.selectedViewController isEqual:targetViewController])
            [self selectViewController:targetViewController];

        if (selector) {
            // If we have a targetViewController AND a selector for the button, assign them to the UIControlEventTouchUpInside
            // (if one has not already been assigned)
            if (![sender.allTargets containsObject:targetViewController]) {

                [sender addTarget:targetViewController
                           action:selector
                 forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}

- (void)barButtonReceivedTouchUpInside:(UIButton *)sender
{    
    // Inform delegate of button selection.
    [self performSelectorOnDelegate:@selector(scrollBar:DidTouchUpInsideBarButton:) withObject:self andObject:sender];
}


#pragma mark - Methods subclass should override

- (UIViewController *)viewControllerForButton:(UIButton *)button
{
    NSLog(@"viewControllerForButton: '%@' was pressed. Override this method in subclass to provide the appropriate view controller for the button.", button.titleLabel);
    
    return nil;
}

- (SEL)selectorForButton:(UIButton *)button
{
    NSLog(@"selectorForButton: '%@' was pressed. Override this method in subclass to provide the appropriate selector name for the button's target view controller.", button.titleLabel);
    
    return nil;
}

#pragma mark - Property setters and getters

- (void)setFullScreenMode:(BOOL)fullScreen
{
    [self setFullScreenMode:fullScreen animated:NO];
}

- (BOOL)fullScreenMode
{
    return self.contentView.frame.size.height == [[UIScreen mainScreen] applicationFrame].size.height;
}

@end
