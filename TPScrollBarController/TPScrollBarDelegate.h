//
//  TPScrollBarDelegate.h
//  TPScrollBarController
//
//  Created by Ben Stovold on 16/10/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TPScrollBarController.h"

@protocol TPScrollBarDelegate <NSObject>

- (void)scrollBar:(UIScrollView *)scrollBar didSelectItem:(UIButton *)item;

@end
