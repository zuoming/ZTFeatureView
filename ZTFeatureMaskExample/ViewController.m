//
//  ViewController.m
//  ZTFeatureMaskExample
//
//  Created by zuo ming on 16/1/25.
//  Copyright © 2016年 zuo ming. All rights reserved.
//

#import "ViewController.h"
#import "ZTFeatureMaskView.h"

@interface ViewController ()<UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView; /**<  */
@property (nonatomic, strong) UIButton *button; /**<  */

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:nil action:nil];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    self.button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.button.titleLabel.textColor = [UIColor blackColor];
    [self.button setTitle:@"Button0" forState:UIControlStateNormal];
    [self.view addSubview:self.button];
}


-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.button.frame = CGRectMake(50.0f, 130.0f, 60.0f, 30.0f);
    
    self.tableView.frame = CGRectMake(0.0f, 120.0f, self.view.frame.size.width, self.view.frame.size.height - 120.0f);
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self showFeatures];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cellidentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"第 %zd 行", indexPath.row + 1];
    
    return cell;
}

- (void)showFeatures
{
    ZTFeatureMaskView *featureView = [[ZTFeatureMaskView alloc] init];
    [featureView setMaskedView:[[UIApplication sharedApplication] keyWindow]];
    
    /* 给 button 添加新特性指引 */
    [featureView addTransparencyInReferenceView:self.button radius:5.0];
    [featureView addImage:[UIImage imageNamed:@"feature0"] referenceView:self.button withOuterSpacingRight:5.0f spacingBottom:-self.button.frame.size.height / 2];
    
    /* 给 rightBarButtonItem 添加新特性指引 */
    UIView *rightItemView = nil;
    if ([self.navigationItem.rightBarButtonItem respondsToSelector:@selector(view)]) {
        rightItemView = (UIView *)[self.navigationItem.rightBarButtonItem performSelector:@selector(view)];
    }
    
    if (rightItemView) {
        [featureView addTransparencyInReferenceView:rightItemView radius:5.0f];
        [featureView addImage:[UIImage imageNamed:@"feature1"] referenceView:rightItemView withOuterSpacingLeft:0.0f spacingBottom:5.0f];
    }
    
    /* 给 整个 Cell 高亮 */
    UITableViewCell *cell0 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (cell0) {
        [featureView addTransparencyInReferenceView:cell0];
        [featureView addImage:[UIImage imageNamed:@"feature3"] referenceView:cell0 withOuterSpacingLeft:-cell0.frame.size.width / 2 spacingBottom:5.0f];
    }
    
    /* 在 Cell 内部高亮 */
    UITableViewCell *cell1 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    if (cell1) {
        [featureView addTransparencyInReferenceView:cell1 innerRect:CGRectMake(100.0f, 5.0f, 60.0f, 30.0f)];
        [featureView addImage:[UIImage imageNamed:@"feature2"] referenceView:cell1 withInnerSpacingLeft:5.0f spacingTop:5.0f];
    }
    
    /** 添加关闭按钮 */
    [featureView addCloseButtonWithImage:[UIImage imageNamed:@"feature4"] referenceView:cell1 withInnerSpacingLeft:100.0f spacingTop:100.0f];
    
    [featureView show];
}

@end
