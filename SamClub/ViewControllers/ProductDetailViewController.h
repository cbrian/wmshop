//
//  ProductDetailViewController.h
//  SamClub
//
//  Created by Brian Cao on 12/10/17.
//  Copyright © 2017 Brian Cao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductDetailViewController : UIViewController
@property  (assign, nonatomic) NSUInteger pageIndex;
@property  (strong, nonatomic) NSDictionary *selectedProduct;
@property  (nonatomic, strong) NSCache *cachedImages;
@end
