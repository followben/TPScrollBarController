//
//  TestController.m
//  TPScrollBarControllerExample
//
//  Copyright 2011 Ben Stovold. All rights reserved.
//

#import "ContentViewController.h"
#import "TPScrollBarController.h"

@implementation ContentViewController

@synthesize label = label_;
@synthesize defaultColor = defaultColor_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        defaultColor_ = [UIColor whiteColor];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:self.defaultColor];
    // Do any additional setup after loading the view from its nib.
    
    [self.label setText:self.title];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"viewWillAppear called for %@", self.title);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Custom methods for sample

- (void)turnMePurple
{
    [self.view setBackgroundColor:[UIColor purpleColor]];
}

- (void)turnMeOrange
{
    [self.view setBackgroundColor:[UIColor orangeColor]];
}

- (void)scrollBar:(id)scrollBarController DidTouchUpInsideBarButton:(UIButton *)barButton
{
    NSLog(@"%@ fired scrollBarViewControllerDidSelectBarButton: %@", self.title, barButton);
}

- (void)scrollToPageTwo
{
    [(TPScrollBarController *)self.parentViewController selectScrollBarPage:2 animated:YES];
}

@end
