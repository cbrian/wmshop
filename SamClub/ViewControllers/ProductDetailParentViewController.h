//
//  ProductDetailParentViewController.h
//  SamClub
//
//  Created by Brian Cao on 12/12/17.
//  Copyright © 2017 Brian Cao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductDetailParentViewController : UIViewController <UIPageViewControllerDataSource>
@property (nonatomic, strong) NSArray *products;
@property (nonatomic, strong) NSCache *cachedImages;
@property (assign, nonatomic) NSUInteger pageIndex;
@end
