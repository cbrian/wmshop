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

static id delegate;

@implementation WalmartGetProducts

+ (void) requestProductListAPI:(NSURL *) url Delegate:(id)callDelegate
{
    delegate = callDelegate;
    NSURLRequest *request = [NSURLRequest requestWithURL: url];
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response,NSError *error)
      {
          if (data.length > 0 && error == nil)
          {
              NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                                           options:0
                                                                             error:&error];
              [self performSelectorOnMainThread:@selector(retrieveDataList:)
                                     withObject:jsonResponse waitUntilDone:YES];
          }
          else
          {
              NSLog(@"Response error = %@", error);
          }
      }
      ] resume];
}

+ (void) retrieveDataList:(NSDictionary *)dataResult {
    
    if ([delegate respondsToSelector:@selector(returnAllData:)]) {
        [delegate returnAllData:dataResult];
    }
    
}

+ (void) requestProductImage:(NSString *)urlString Delegate: (id)callDelegate
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        if (imgData) {
            if ([delegate respondsToSelector:@selector(returnImageData:urlStr:)])
            {
                [delegate returnImageData:imgData urlStr:urlString];
            }
        }
    });
}
@end
