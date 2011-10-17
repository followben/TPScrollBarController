//
//  TestController.m
//  TPScrollBarController
//
//  Created by Ben Stovold on 16/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TestController.h"

@implementation TestController

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

- (void)toggleBackgroundColor:(UIColor *)color
{
    if ([self.view backgroundColor] == self.defaultColor) {
        [self.view setBackgroundColor:color];
    } else {
        [self.view setBackgroundColor:self.defaultColor];
    }
}

- (void)toggleMePurple
{
    [self toggleBackgroundColor:[UIColor purpleColor]];
}

- (void)toggleMeOrange
{
    [self toggleBackgroundColor:[UIColor orangeColor]];
}

@end
