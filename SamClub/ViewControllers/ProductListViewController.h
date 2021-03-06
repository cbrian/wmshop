//
//  ProductListViewController.h
//  SamClub
//
//  Created by Brian Cao on 12/9/17.
//  Copyright © 2017 Brian Cao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductListViewController: UIViewController <UITableViewDelegate, UITableViewDataSource>

-(void)fetchDataCompleted:(NSDictionary *)jsonResponse;
-(void)fetchImageCompleted:(NSData *) imgData urlStr:(NSString *)urlString;

@end

