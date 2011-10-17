//
//  TestController.h
//  TPScrollBarController
//
//  Created by Ben Stovold on 16/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPScrollBarDelegate.h"

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
