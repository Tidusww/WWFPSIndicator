//
//  RootTableViewController.m
//  TidusWWDemo
//
//  Created by Tidus on 16/3/11.
//  Copyright © 2016年 Tidus. All rights reserved.
//

#import <objc/runtime.h>
#import "RootTableViewController.h"

#define StatusBarHeight ([UIApplication sharedApplication].statusBarFrame.size.height)
#define NavigationBarHeight (self.navigationController.navigationBar.frame.size.height)
#define TabBarHeight (self.tabBarController.tabBar.frame.size.height)

#define ScreenWidth ([[UIScreen mainScreen] bounds].size.width)
#define ScreenHeight ([[UIScreen mainScreen] bounds].size.height)

@interface RootTableViewController ()

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataList;

@end

@implementation RootTableViewController

- (void)loadView
{
    [super loadView];
    [self.view addSubview:self.tableView];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewDidLoad
{
    [self setupDataList];
//    [self.tableView reloadData];
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

- (NSMutableArray *)dataList
{
    if(!_dataList){
        _dataList = [[NSMutableArray alloc] init];
    }
    return _dataList;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseId = @"CELLID";
    UITableViewCell *cell;
    
    cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    
    cell.textLabel.text = self.dataList[indexPath.row];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 44.f;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    NSInteger row = indexPath.row;
    NSString *rowName = self.dataList[row];
    
    
    if(rowName && rowName.length != 0){
        NSArray *nameArray = [rowName componentsSeparatedByString:@"-"];
        NSString *className;
        if(nameArray.count == 2){
            className = nameArray[1];
        }
        UIViewController *vc = (UIViewController *)[[NSClassFromString(className) alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark -
- (void)setupDataList
{
    
    [self.dataList addObject:@"ContactList-FirstViewController"];
    [self.dataList addObject:@"CardAnimation-WWCardAnimateController"];
    
}
@end
