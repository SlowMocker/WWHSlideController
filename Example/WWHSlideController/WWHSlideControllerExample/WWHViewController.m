//
//  ViewController.m
//  Test
//
//  Created by Wu on 16/5/5.
//  Copyright © 2016年 Wu. All rights reserved.
//

#import "WWHViewController.h"
#import "WWHSlideController.h"
#import "WWHHomeViewController.h"
#import "WWHLeftViewController.h"
#import "WWHRightViewController.h"

@interface WWHViewController ()
{
    WWHHomeViewController *_home;
    WWHLeftViewController *_left;
    WWHRightViewController *_right;
    
    UIButton *_startBtn;
}
@end

@implementation WWHViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _home = [[WWHHomeViewController alloc]init];
    _left = [[WWHLeftViewController alloc]init];
    _right = [[WWHRightViewController alloc]init];
    self.slideController = [[WWHSlideController alloc]initWithRootViewController:_home leftViewController:_left rightViewController:_right];
    
    
    
    UIButton *startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    startBtn.frame = self.view.frame;
    [startBtn setTitle:@"Start" forState:UIControlStateNormal];
    startBtn.backgroundColor = [UIColor grayColor];
    [startBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    _startBtn = startBtn;
    [self.view addSubview:_startBtn];
}

- (void)btnAction:(UIButton *)sender {
        [self presentViewController:self.slideController animated:YES completion:nil];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
