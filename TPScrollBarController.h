//
//  TPScrollBarController.h
//  TPScrollBarController
//
//  Copyright 2011 Ben Stovold. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPScrollBarDelegate.h"

// A root container view controller in the vein of UITabBarController.
// Has a scrolling menubar at the bottom and allows:
//      * multiple bar buttons per controller
//      * bar buttons to be enabled or disabled
@interface TPScrollBarController : UIViewController {

@protected
    id<TPScrollBarDelegate> delegate_;
    
    UIScrollView            *scrollBar_;
    NSUInteger              scrollBarHeight_;
    BOOL                    scrollBarShouldDisplayScrollIndicators_;
    BOOL                    scrollBarShouldAlwaysBounce_;
    UIView                  *contentView_;
    UIViewController        *selectedViewController_;
    NSArray                 *scrollBarPageArray_;
    NSOrderedSet            *scrollBarPageSet_;
    NSArray                 *barButtons_;
    NSUInteger              selectedScrollBarPage_;
    NSArray                 *registry_;
    BOOL                    shouldForwardAppearanceAndRotationMethodsToChildViewControllers_;

}

@property(nonatomic, strong)            id<TPScrollBarDelegate>     delegate;
@property(nonatomic, assign)            NSUInteger                  scrollBarHeight;
@property(nonatomic, assign)            BOOL                        scrollBarShouldDisplayScrollIndicators;
@property(nonatomic, assign)            BOOL                        scrollBarShouldAlwaysBounce;
@property(nonatomic, assign)            BOOL                        fullScreenMode;

@property(nonatomic, readonly)  UIViewController                *selectedViewController;
@property(nonatomic, readonly)  NSUInteger                      selectedScrollBarPage;

- (void)setBarButtons:(NSArray *)barButtons
     onScrollBarPages:(NSArray *)pageNumbers
    withDefaultButton:(UIButton *)defaultButton;

- (void)selectScrollBarPage:(NSUInteger)pageNumber animated:(BOOL)animated;
- (void)resizeScrollBarForNumberOfPages:(NSUInteger)pages;
- (void)selectViewController:(UIViewController *)childViewController;
- (void)setFullScreenMode:(BOOL)moveToFullScreen animated:(BOOL)animated;

// Subclass should override these methods to provide the correct view controller for the given button
- (UIViewController *)viewControllerForButton:(UIButton *)button;
- (SEL)selectorForButton:(UIButton *)button;

@end