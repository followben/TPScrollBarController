//
//  TestController.h
//  TPScrollBarControllerExample
//
//  Copyright 2011 Ben Stovold. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPScrollBarDelegate.h"

// This is an example view controller for illustration purposes,
// ie. it doesn't do anything fancy. Scroll bar delegate method just
// writes to the log.
@interface TestController : UIViewController <TPScrollBarDelegate> {
    
@protected
    __weak UILabel *label_;
}

@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, strong) UIColor *defaultColor;

- (void)turnMePurple;
- (void)turnMeOrange;
- (void)scrollToPageTwo;

@end
