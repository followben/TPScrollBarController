//
//  TPScrollBarDelegate.h
//  TPScrollBarController
//
//  Created by Ben Stovold on 16/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

@protocol TPScrollBarDelegate <NSObject>

- (void)scrollBar:(id)scrollBarController DidTouchUpInsideBarButton:(UIButton *)barButton;

@end
