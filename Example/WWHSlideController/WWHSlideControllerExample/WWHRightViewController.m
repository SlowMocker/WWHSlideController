//
//  WWHRightViewController.m
//  Test
//
//  Created by Wu on 16/5/10.
//  Copyright © 2016年 Wu. All rights reserved.
//

#import "WWHRightViewController.h"
#import "WWHSlideController.h"
#import "WWHNewHomeViewController.h"

NSString *const cellIdentifier = @"WWHTableViewCellIdentifier";

@interface WWHRightViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView *_tableView;
    WWHNewHomeViewController *_newHome;
}
@property(nonatomic , strong)NSArray *dataSource;
@end

@implementation WWHRightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor greenColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_tableView];
    
    UIEdgeInsets insets = _tableView.contentInset;
    insets.top = 64;
    _tableView.contentInset = insets;
    
    _newHome = [[WWHNewHomeViewController alloc]init];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [self.dataSource objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        if (_newHome) {
            [self.slideController changeHome:_newHome needCloseSide:YES complete:^{
                NSLog(@"Smicro");
            }];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)dataSource {
    if (_dataSource == nil) {
        _dataSource = @[@"changeHome"];
    }
    return _dataSource;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
