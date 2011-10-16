//
//  TestController.h
//  TPScrollBarController
//
//  Created by Ben Stovold on 16/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestController : UIViewController {
    
@protected
    __weak UILabel *label_;
}

@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, strong) UIColor *defaultColor;

- (void)toggleMePurple;
- (void)toggleMeOrange;

@end
