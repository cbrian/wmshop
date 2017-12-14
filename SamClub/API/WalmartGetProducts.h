//
//  WalmartGetProducts.h
//  SamClub
//
//  Created by Brian Cao on 12/10/17.
//  Copyright © 2017 Brian Cao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WalmartGetProducts : NSObject

+ (void) requestProductListAPI:(NSURL *)url Delegate:(id)callDelegate;
+ (void) requestProductImage:(NSString *)urlString Delegate:(id)callDelegate;

@end
