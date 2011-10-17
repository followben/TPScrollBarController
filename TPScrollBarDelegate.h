//
//  TPScrollBarDelegate.h
//  TPScrollBarController
//
//  Copyright 2011 Ben Stovold. All rights reserved.
//

@protocol TPScrollBarDelegate <NSObject>

- (void)scrollBar:(id)scrollBarController DidTouchUpInsideBarButton:(UIButton *)barButton;

@end
