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
@property(nonatomic, strong)  NSSet            *viewControllers;
@property(nonatomic, strong)  NSArray          *barButtons;
@property(nonatomic, strong)  NSArray          *scrollBarPageArray;
@property(nonatomic, strong)  NSArray          *registry;
@property(nonatomic, assign)  BOOL             shouldForwardAppearanceAndRotationMethodsToChildViewControllers;

- (void)performSelectorOnDelegate:(SEL)aSelector withObject:(id)param1 andObject:(id)param2;
- (void)initaliseContainerViews;
- (void)layoutBarButtons;
- (void)registerBarButtonTargetsAsChildViewControllers;
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
@synthesize viewControllers = viewControllers_;
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
    [self registerBarButtonTargetsAsChildViewControllers];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Now we can forward events.
    self.shouldForwardAppearanceAndRotationMethodsToChildViewControllers = YES;

    [self initaliseContainerViews];
    [self resizeScrollBarForNumberOfPages:((NSNumber *)[self.scrollBarPageSet lastObject]).intValue];
    [self layoutBarButtons];

    self.selectedScrollBarPage = 1;
    [self.contentView addSubview:self.selectedViewController.view];
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

- (void)setViewControllers:(NSSet *)viewControllers
            WithBarButtons:(NSArray *)barButtons
          onScrollBarPages:(NSArray *)pageNumbers
{
    NSAssert([barButtons count] == [pageNumbers count], @"barButton and pageNumber arrays must contain the same number of objects");
    for (UIButton *barButton in barButtons) {
        NSAssert([[barButton allTargets] count] > 0, @"barButtons must have a target");
        NSAssert([[barButton allTargets] count] < 2, @"barButtons can only have one target");
        NSAssert([[[[barButton allTargets] allObjects] objectAtIndex:0] isKindOfClass:[UIViewController class]], @"barButton target must be a UIViewController");
    }
    for (NSNumber *pageNumber in pageNumbers) {
        NSAssert([pageNumber integerValue] > 0, @"pageNumbers must be greater than zero");
    }
    
    NSSortDescriptor *ascending = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    NSMutableArray *numbers = [NSMutableArray arrayWithArray:pageNumbers];
    [numbers sortUsingDescriptors:[NSArray arrayWithObject:ascending]];
    self.scrollBarPageSet = [NSOrderedSet orderedSetWithArray:numbers];
    self.viewControllers = viewControllers;
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
    self.contentView.clipsToBounds = NO;
    [self.view addSubview:self.contentView];
    
    // Add drop shadow. 
    // TODO: consider using an image to improve performance & get the shadow running the whole screen
    self.contentView.layer.masksToBounds = NO;
    self.contentView.layer.shadowOffset = CGSizeMake(0, 5);
    self.contentView.layer.shadowRadius = 5;
    self.contentView.layer.shadowOpacity = 2;
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

- (void)registerBarButtonTargetsAsChildViewControllers
{
    // For each bar button
    for (UIButton *barButton in self.barButtons) {
        
        if (self.viewControllers) {
            
            __block NSMutableSet *controllers = [NSMutableSet setWithArray:self.childViewControllers];
            [[barButton allTargets] enumerateObjectsUsingBlock:^(id target, BOOL *stop) {

                // View Controller setter asserts that there is only one target.
                // That is, there should only be one target to 'enumerate'.
                UIViewController *controller = (UIViewController *)target;
                
                // If the target isn't already a child viewController, add it.
                if (![controllers containsObject:target]) {
                    [self addChildViewController:controller];
                    [controller didMoveToParentViewController:self];
                    if (!self.selectedViewController) self.selectedViewController = controller;
                    [controllers addObject:target];
                }
                
                // Register the button/ target/ action combination
                NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:barButton, @"barButton", target, @"target", nil];
                self.registry = [self.registry arrayByAddingObject:entry];

            }];
            
            // Add self as a target for touch events
            [barButton addTarget:self action:@selector(barButtonReceivedTouchDown:) forControlEvents:UIControlEventTouchDown];
            [barButton addTarget:self action:@selector(barButtonReceivedTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
            
        }
    }
}

- (void)barButtonReceivedTouchDown:(UIButton *)sender
{
    // Get the registry entry for the target
    NSUInteger idx = [self.registry indexOfObjectPassingTest: ^(id dictionary, NSUInteger idx, BOOL *stop) {
                return [[dictionary objectForKey: @"barButton"] isEqual:sender];
    }];
    UIViewController *targetViewController = (UIViewController *)[[self.registry objectAtIndex:idx] objectForKey:@"target"];
    
    // If the target isn't the current viewController, transition to the new view
    if (![self.selectedViewController isEqual:targetViewController]) [self selectViewController:targetViewController];
}

- (void)barButtonReceivedTouchUpInside:(UIButton *)sender
{
    // Inform delegate of button selection.
    [self performSelectorOnDelegate:@selector(scrollBar:DidTouchUpInsideBarButton:) withObject:self andObject:sender];
}

@end
