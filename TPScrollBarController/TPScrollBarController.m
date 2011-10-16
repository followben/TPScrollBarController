//
//  TPScrollBarController.m
//  TPScrollBarController
//
//  Created by Ben Stovold on 16/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TPScrollBarController.h"
#import <objc/message.h>

#pragma mark Constants and enums
CGFloat         const   kScrollBarHeight = 88.f;

#pragma mark -
@interface TPScrollBarController ()

@property(nonatomic)  UIScrollView     *scrollBar;
@property(nonatomic)  UIView           *contentView;
@property(nonatomic)  UIViewController *selectedViewController;
@property(nonatomic)  NSOrderedSet     *scrollBarPageSet;
@property(nonatomic)  NSSet            *viewControllers;
@property(nonatomic)  NSArray          *barButtons;

@property(nonatomic, strong)  NSArray               *scrollBarPageArray;
@property(nonatomic, strong)  NSArray               *registry;

- (void)performSelectorOnDelegate:(SEL)aSelector withObject:(id)param1 andObject:(id)param2;
- (void)initaliseContainerViews;
- (void)resizeScrollBarForNumberOfPages;
- (void)layoutBarButtons;
- (void)registerBarButtonTargets;

@end


#pragma mark -
@implementation TPScrollBarController

#pragma mark Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        registry_ = [NSArray array];
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
@synthesize contentView = contentView_;
@synthesize selectedViewController = selectedViewController_;
@synthesize scrollBarPageSet = scrollBarPageSet_;
@synthesize selectedScrollBarPage = selectedScrollBarPage_;
@synthesize viewControllers = viewControllers_;
@synthesize barButtons = barButtons_;

@synthesize scrollBarPageArray = scrollBarPageArray_;
@synthesize registry = registry_;


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self initaliseContainerViews];
    [self resizeScrollBarForNumberOfPages];
    [self layoutBarButtons];
    [self registerBarButtonTargets];
    [self selectScrollBarPage:self.selectedScrollBarPage animated:YES];
}

- (void)viewDidUnload
{
//    self.contentView = nil;
//    self.scrollBar = nil;
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
    for (UIButton *barButton in barButtons) {
        NSAssert([[barButton allTargets] count] == 1, @"barButtons can only have one target");
        NSAssert([[[[barButton allTargets] allObjects] objectAtIndex:0] isKindOfClass:[UIViewController class]], @"a barButton's target must be a UIViewController");
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

- (void)selectScrollBarPage:(NSUInteger)pageNumber animated:(BOOL)animated
{

}


#pragma mark - Private methods

- (void)performSelectorOnDelegate:(SEL)aSelector withObject:(id)param1 andObject:(id)param2;
{
    if ([self.delegate respondsToSelector:aSelector])
        objc_msgSend(self.delegate, aSelector, param1, param2); // performSelector: generates compiler warnings under ARC
}

// Initialises an empty scrollBar and contentView and adds them as subviews.
- (void)initaliseContainerViews
{
    CGFloat xpos = 0.f;
    CGFloat width = [[UIScreen mainScreen] applicationFrame].size.width;
    CGFloat ypos = [[UIScreen mainScreen] applicationFrame].size.height - kScrollBarHeight;
    self.scrollBar = [[UIScrollView alloc] initWithFrame:CGRectMake(xpos, ypos, width, kScrollBarHeight)];
    [self.scrollBar setBackgroundColor:[UIColor redColor]];
    self.scrollBar.clipsToBounds = YES;
    self.scrollBar.scrollEnabled = YES;
	self.scrollBar.pagingEnabled = YES;
    self.scrollBar.showsHorizontalScrollIndicator = YES;
    self.scrollBar.showsVerticalScrollIndicator = YES;
    [self.view addSubview:self.scrollBar];

    
    ypos = [[UIScreen mainScreen] bounds].origin.y;
    CGFloat height = [[UIScreen mainScreen] applicationFrame].size.height - kScrollBarHeight;
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(xpos, ypos, width, height)];
    [self.contentView setBackgroundColor:[UIColor greenColor]];
    self.contentView.clipsToBounds = YES;
    [self.view addSubview:self.contentView];
}

- (void)resizeScrollBarForNumberOfPages
{
    // Size the scroll bar
    CGSize size = self.scrollBar.frame.size;
    size.width = [[UIScreen mainScreen] applicationFrame].size.width * ((NSNumber *)[self.scrollBarPageSet lastObject]).integerValue;
    self.scrollBar.contentSize = size;
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
        
        NSUInteger numberOfButtonsOnThisPage = [buttonIndexSet count];
        
        // Calculate how far to offset each button from the left of the last one.
        NSUInteger offset = (pageWidth - widthOfButtonsOnThisPage) / (numberOfButtonsOnThisPage + 1);
        
        // Set the x position for the first button.
        __block NSUInteger xpos = offset + (pageWidth * (page.integerValue - 1));
        
        // For each button on the page (in order)
        [buttonIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            
            UIButton *barButton = [self.barButtons objectAtIndex:idx];
            
            // place it on the scrollBar according to the page offset.
            CGRect newFrame = barButton.frame;
            newFrame.origin.x = xpos;
            newFrame.origin.y = barButton.frame.size.height / 2;
            barButton.frame = newFrame;
            [self.scrollBar addSubview:barButton];
            
            // Calculate the x origin for the next pass through
            xpos = xpos + barButton.frame.size.width + xpos;
            
        }];
    }
}

- (void)registerBarButtonTargets
{
    // For each bar button
    for (UIButton *barButton in self.barButtons) {
        
        if (self.viewControllers) {
            
            __block NSMutableSet *controllers = [NSMutableSet setWithArray:self.childViewControllers];
            [[barButton allTargets] enumerateObjectsUsingBlock:^(id target, BOOL *stop) {

                UIViewController *controller = (UIViewController *)target;
                
                // If the target isn't already a child viewController, add it.
                if (![controllers containsObject:target]) {
                    [self addChildViewController:controller];
                    [self.contentView addSubview:controller.view];
                    [controllers addObject:target];
                }
                
                // Register the button/ target/ action combination
                NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:barButton, @"barButton", target, @"target", nil];
                self.registry = [self.registry arrayByAddingObject:entry];

            }];
        }
    }
}

@end
