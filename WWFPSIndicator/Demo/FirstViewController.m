//
//  ViewController.m
//  testAnimation
//
//  Created by Tidus on 15/10/7.
//  Copyright (c) 2015年 Tidus. All rights reserved.
//

#import "FirstViewController.h"


#define StatusBarHeight ([UIApplication sharedApplication].statusBarFrame.size.height)
#define NavigationBarHeight (self.navigationController.navigationBar.frame.size.height)
#define TabBarHeight (self.tabBarController.tabBar.frame.size.height)

#define ScreenWidth ([[UIScreen mainScreen] bounds].size.width)
#define ScreenHeight ([[UIScreen mainScreen] bounds].size.height)

@interface FirstViewController ()

@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation FirstViewController

- (void)loadView
{
    [super loadView];
    [self.view addSubview:self.tableView];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *array = [NSMutableArray array];
    
    for (int i = 0; i< 1000; i++) {
        [array addObject:@{@"name": [self randomName], @"image": [self randomAvatar]}];
    }
    
    self.items = array;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getter
- (UITableView *)tableView
{
    if(!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-StatusBarHeight-NavigationBarHeight)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
    }
    return _tableView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSDictionary *item = self.items[indexPath.row];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:item[@"image"] ofType:@"png"];
    
    //name and image
    cell.imageView.image = [UIImage imageWithContentsOfFile:filePath];
//    cell.imageView.image = [UIImage imageNamed:item[@"image"]];
    cell.textLabel.text = item[@"name"];
    
    //image shadow
    cell.imageView.layer.shadowOffset = CGSizeMake(0, 5);
    cell.imageView.layer.shadowOpacity = 1;
    cell.imageView.layer.cornerRadius = 5.0f;
    cell.imageView.layer.masksToBounds = YES;
    
    
    
    //text shadow
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.layer.shadowOffset = CGSizeMake(0, 2);
    cell.textLabel.layer.cornerRadius = 5.0f;
    cell.textLabel.layer.shadowOpacity = 1;
    

//    cell.layer.shouldRasterize = YES;
//    cell.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    return cell;
}

- (NSString *)randomName {
    NSArray *first = @[@"Alice",@"Bob",@"Bill"];
    NSArray *last = @[@"Appleseed",@"Bandicoot",@"Caravan"];
    NSUInteger index1 = (rand()/(double)INT_MAX) * [first count];
    NSUInteger index2 = (rand()/(double)INT_MAX) * [last count];
    return [NSString stringWithFormat:@"%@ %@", first[index1], last[index2]];
}

- (NSString *)randomAvatar {
    NSArray *images = @[@"A",@"B",@"C"];
    NSUInteger index = (rand()/(double)INT_MAX) * [images count];
    return images[index];
}
@end
