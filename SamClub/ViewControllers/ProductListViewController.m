//
//  ProductListViewController.m
//  SamClub
//
//  Created by Brian Cao on 12/9/17.
//  Copyright © 2017 Brian Cao. All rights reserved.
//

#import "ProductListViewController.h"
#import "ProductDetailParentViewController.h"
#import "NSString+SCExtensions.h"
#import "WalmartGetProducts.h"

#define kMaxProductPerPage 30
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

const NSString * apiKey = @"f545c4be-0f79-42c9-8616-3baff5c8aa5a";
const NSString * hostAPIURLPrefix = @"https://walmartlabs-test.appspot.com/_ah/api/walmart/v1/walmartproducts";

const NSString *CellIdentifier = @"LazyTableCell";
const NSString *PlaceholderCellIdentifier = @"PlaceholderCell";

@interface ProductListViewController () <getProductsProtocol>
@property (nonatomic, strong) NSMutableArray *products;
@property (nonatomic, assign) NSInteger totalProducts;
@property (nonatomic, assign) NSInteger numProducts;
@property (nonatomic, assign) int curentPageNumber;
@property (nonatomic, assign) bool isListingFinished;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSCache *cacheProductImages;
@property (strong, nonatomic) UITableViewCell *saveCell;
@end

@implementation ProductListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isListingFinished = false;
    self.products = [[NSMutableArray alloc] init];
    self.curentPageNumber = 1;
    self.cacheProductImages = [[NSCache alloc] init];
    [self requestProductList:self.curentPageNumber PageSize:kMaxProductPerPage];
}

-(IBAction) requestProductList:(int)pageNumber PageSize:(int)pageSize
{
    // To append with apiKey/1/1" as suffix
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%d/%d", hostAPIURLPrefix, apiKey, pageNumber, pageSize];
    NSURL *url = [NSURL URLWithString:urlString];
    WalmartGetProducts *productGetService = [WalmartGetProducts sharedInstance];
    productGetService.delegate = self;
    [productGetService requestProductListAPI:url];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) fetchDataCompleted:(NSDictionary *)jsonResponse
{
    //NSLog(@"jsonResponse Results are %@", jsonResponse);

    if (jsonResponse) {
        [self.products addObjectsFromArray:[jsonResponse objectForKey:@"products"]];
        self.totalProducts = [[jsonResponse objectForKey:@"totalProducts"] integerValue];
        self.numProducts += [jsonResponse[@"pageSize"] integerValue];
        [self.tableView reloadData];
    }
    else
    {
        self.isListingFinished = true;
    }
}

// Datasource delegate methods
 - (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.products count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    //NSLog(@"product count = %ul", self.products.count);
    if (self.products.count == 0 && indexPath.row == 0)
    {
        // Add a placeholder cell while waiting on table data
        cell = [tableView dequeueReusableCellWithIdentifier:PlaceholderCellIdentifier];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault  reuseIdentifier:CellIdentifier];
            cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:17.0];
        }
        NSDictionary *indexProduct = self.products[indexPath.row];
        NSString * productName = indexProduct[@"productName"];
        NSString* trimASCIISet = [NSString filter_ASCIISet_String: productName];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@\nPrice: %@", trimASCIISet, self.products[indexPath.row][@"price"]];
        [self fetchProductImage:indexProduct Cell:cell];
    }
    return cell;
}

-(void) fetchProductImage:(NSDictionary *) theProduct Cell: (UITableViewCell *) cell
{
    // Fetch and cache large images and move all requests to WalmartGetProducts later
    NSString * urlString = theProduct[@"productImage"];
    NSData *cachedImageData = [self.cacheProductImages objectForKey:urlString];
    if (cachedImageData)
    {
        cell.imageView.image = [UIImage imageWithData:cachedImageData];
    }
    else
    {
        WalmartGetProducts *service = [WalmartGetProducts sharedInstance];
        service.delegate = self;
        [service requestProductImageAPI:urlString];
        self.saveCell = cell;
    }
}

- (void)fetchImageCompleted:(NSData *) imgData urlStr:(NSString *)urlString
{
    //STORE IN FILESYSTEM for app quit or offline
    NSString* cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *file = [cachesDirectory stringByAppendingPathComponent:urlString];
    [imgData writeToFile:file atomically:YES];
    
    // STORE IN MEMORY
    [self.cacheProductImages setObject:imgData forKey:urlString];
    __weak ProductListViewController *weakself = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakself.saveCell.imageView.image = [UIImage imageWithData:imgData];
        [weakself.tableView reloadData]; // Todo: Change to refresh cell later if UI slows
    });
}

// UITableViewDelegate methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"row = %d", (int)indexPath.row);
    ProductDetailParentViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DetailParentViewControllerID"];
    detailViewController.pageIndex = indexPath.row;
    detailViewController.products = self.products;
    detailViewController.cachedImages = self.cacheProductImages;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger lastSectionIndex = [tableView numberOfSections] - 1;
    NSInteger lastRowIndex = [tableView numberOfRowsInSection:lastSectionIndex] - 1;
    //NSLog(@" **** Current count = %lu, current page number = %d", [self.products count], self.curentPageNumber);
    if (!self.isListingFinished && (indexPath.row == lastRowIndex)) {
        // This is the last cell
        [self loadMore];
    }
}

// Load next next page when reaching bottom`
- (void)loadMore {
    NSUInteger nextPageSize = self.products.count+kMaxProductPerPage;
    if (nextPageSize < self.totalProducts)
    {
        [self requestProductList:++self.curentPageNumber PageSize:kMaxProductPerPage];
    }
    else
    {
        nextPageSize = self.totalProducts - self.products.count;
        [self requestProductList:self.curentPageNumber PageSize:(int)nextPageSize];
        self.isListingFinished = true;
        NSLog(@"Finished");
    }
    
    // TODO: Save to add offline support later if requested
//    [self.fetchedResultsController.fetchRequest setFetchLimit:newFetchLimit];
//    [NSFetchedResultsController deleteCacheWithName:@"cache name"];
//    NSError *error;
//    if (![self.fetchedResultsController performFetch:&error]) {
//        // Update to handle the error appropriately.
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//    }
}

@end
