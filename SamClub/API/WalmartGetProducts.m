//
//  WalmartGetProducts.m
//  SamClub
//
//  Created by Brian Cao on 12/10/17.
//  Copyright © 2017 Brian Cao. All rights reserved.
//

#import "WalmartGetProducts.h"
#import "ProductListViewController.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@implementation WalmartGetProducts

+ (WalmartGetProducts *)sharedInstance {
    static WalmartGetProducts *sharedInstance = nil;
    static dispatch_once_t onceToken; // onceToken = 0
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WalmartGetProducts alloc] init];
    });
    
    return sharedInstance;
}

- (void) requestProductListAPI:(NSURL *) url
{
    NSURLRequest *request = [NSURLRequest requestWithURL: url];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response,NSError *error)
      {
          if (data.length > 0 && error == nil)
          {
              NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                           options:0
                                                                             error:&error];
     
              dispatch_async(dispatch_get_main_queue(), ^{
                  [self.delegate fetchDataCompleted:jsonResponse];
              });
          }
          else
          {
              NSLog(@"Response error = %@", error);
          }
      }
      ] resume];
}

- (void) requestProductImage:(NSString *)urlString
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        if (imgData) {
            if ([self.delegate respondsToSelector:@selector(returnImageData:urlStr:)])
            {
                [self.delegate returnImageData:imgData urlStr:urlString];
            }
        }
    });
}
@end
