//
//  WalmartGetProducts.h
//  SamClub
//
//  Created by Brian Cao on 12/10/17.
//  Copyright © 2017 Brian Cao. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol getProductsProtocol <NSObject>
@required
- (void)fetchCompleted:(NSDictionary *)responseDict;
- (void)fetchImageCompleted:(NSData *) imgData urlStr:(NSString *)urlString;
@end

@interface WalmartGetProducts : NSObject

@property (nonatomic, weak) id delegate;

+ (WalmartGetProducts *)sharedInstance;
- (void) requestProductListAPI:(NSURL *)url;
- (void) requestProductImageAPI:(NSString *)urlString;

@end
