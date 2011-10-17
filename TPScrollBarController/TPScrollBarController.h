//
//  TPScrollBarController.h
//  TPScrollBarController
//
//  Created by Ben Stovold on 16/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPScrollBarDelegate.h"

// A root container view controller in the vein of UITabBarController.
// Has a scrolling menubar at the bottom and allows:
//      * multiple bar buttons per controller
//      * bar buttons to be enabled or disabled
@interface TPScrollBarController : UIViewController {

@private
    __unsafe_unretained   id<TPScrollBarDelegate> delegate_;
                          UIScrollView            *scrollBar_;
                          UIView                  *contentView_;
                          UIViewController        *selectedViewController_;
                          NSArray                 *scrollBarPageArray_;
                          NSOrderedSet            *scrollBarPageSet_;
                          NSSet                   *viewControllers_;
                          NSArray                 *barButtons_;
                          NSUInteger              selectedScrollBarPage_;
                          NSArray                 *registry_;
}

@property(nonatomic, assign)    id<TPScrollBarDelegate> delegate;

@property(nonatomic, readonly)  UIScrollView     *scrollBar;
@property(nonatomic, readonly)  UIView           *contentView;
@property(nonatomic, readonly)  UIViewController *selectedViewController;
@property(nonatomic, readonly)  NSOrderedSet     *scrollBarPageSet;
@property(nonatomic, readonly)  NSSet            *viewControllers;
@property(nonatomic, readonly)  NSArray          *barButtons;
@property(nonatomic, readonly)  NSUInteger       selectedScrollBarPage;

- (void)setViewControllers:(NSSet *)viewControllers
            WithBarButtons:(NSArray *)barButtons
          onScrollBarPages:(NSArray *)pageNumbers;

- (void)selectScrollBarPage:(NSUInteger)pageNumber animated:(BOOL)animated;

@end