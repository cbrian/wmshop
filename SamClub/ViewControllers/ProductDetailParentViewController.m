//
//  ProductDetailParentViewController.m
//  SamClub
//
//  Created by Brian Cao on 12/12/17.
//  Copyright © 2017 Brian Cao. All rights reserved.
//

#import "ProductDetailParentViewController.h"
#import "ProductDetailViewController.h"

@interface ProductDetailParentViewController ()
@property (nonatomic,strong) UIPageViewController *pageViewController;
@end

@implementation ProductDetailParentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Product Detail", @"Product Detail string");
    [self setupPageViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupPageViewController
{
    // Create page view controller
    self.PageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController.dataSource = self;
    
    ProductDetailViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
    
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

#pragma mark - Page View Datasource Methods
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ProductDetailViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound))
    {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ProductDetailViewController*) viewController).pageIndex;
    
    if (index == NSNotFound)
    {
        return nil;
    }
    
    index++;
    if (index == [self.products count])
    {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

#pragma mark - Other Methods
- (ProductDetailViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.products count] == 0) || (index >= [self.products count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    ProductDetailViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ProductDetailViewControllerID"];
    pageContentViewController.pageIndex = index;
    pageContentViewController.selectedProduct = self.products[index];
    pageContentViewController.cachedImages = self.cachedImages;
    
    return pageContentViewController;
}

#pragma mark - No of Pages Methods
- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.products count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

@end
