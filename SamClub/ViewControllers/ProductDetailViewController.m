//
//  ProductDetailViewController.m
//  SamClub
//
//  Created by Brian Cao on 12/10/17.
//  Copyright © 2017 Brian Cao. All rights reserved.
//

#import "ProductDetailViewController.h"
#import "NSString+SCExtensions.h"
#import "WalmartGetProducts.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

@interface ProductDetailViewController () <UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *productName;
@property (strong, nonatomic) IBOutlet UILabel *productCost;
@property (strong, nonatomic) IBOutlet UILabel *productRating;
@property (strong, nonatomic) IBOutlet UILabel *productAvailableStatus;
@property (strong, nonatomic) IBOutlet UILabel *productID;
@property (strong, nonatomic) IBOutlet UIImageView *productImage;
@property (strong, nonatomic) IBOutlet UIWebView *shortWKWebView;
@property (strong, nonatomic) IBOutlet UIWebView *longDescription;
@end

@implementation ProductDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupTopContent];
    [self loadProductImage];
    [self setupBottomContent];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:NO];
    [UIView setAnimationsEnabled:NO];
    
    // Force portrait orientation for now
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (void)setupTopContent
{
    self.productName.text = [NSString filter_ASCIISet_String:self.selectedProduct[@"productName"]];
    self.shortWKWebView.scrollView.scrollEnabled = NO;
    
    NSString *htmlString = [NSString filter_ASCIISet_String: self.selectedProduct[@"shortDescription"]];
    [self.shortWKWebView loadHTMLString:htmlString baseURL:nil];
    self.productCost.text = self.selectedProduct[@"price"];
}

- (void)loadProductImage
{
    // Set up the main product image
    NSString * urlStr = (NSString *) self.selectedProduct[@"productImage"];
    NSData *cachedProductImageData = [self.cachedImages objectForKey:urlStr];
    if (cachedProductImageData)
    {
        self.productImage.image = [UIImage imageWithData:cachedProductImageData];
    }
    else
    {
        WalmartGetProducts *wmGetService = [WalmartGetProducts sharedInstance];
        [wmGetService requestProductImageAPI:urlStr];
        __weak ProductDetailViewController *weakself = self;
        dispatch_async(kBgQueue, ^{
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlStr]];
            dispatch_async(dispatch_get_main_queue(), ^{
                weakself.productImage.image = [UIImage imageWithData:imgData];
            });
        });
    }
}

-(void)setupBottomContent
{
    // Set up the product detail page bottom content
    self.productRating.text = [NSString stringWithFormat: @"Rating %@/5.0 (%@ reviews)",  [self.selectedProduct[@"reviewRating"] stringValue], [self.selectedProduct[@"reviewCount"] stringValue]];
    NSMutableString *availableStatus = [[NSMutableString alloc] init];
    [availableStatus appendString:@"Available: "];
    bool isInStock = self.selectedProduct[@"inStock"];
    [availableStatus appendString:isInStock?@"InStock":@"OutOfStock"];
    self.productAvailableStatus.text = availableStatus;
    [self.longDescription loadHTMLString:[NSString filter_ASCIISet_String: self.selectedProduct[@"longDescription"]] baseURL:nil];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
