//
//  WWHBaseHomeViewController.m
//  Test
//
//  Created by Wu on 16/5/10.
//  Copyright © 2016年 Wu. All rights reserved.
//

#import "WWHBaseHomeViewController.h"
#import "WWHSlideController.h"

@interface WWHBaseHomeViewController ()

@end

@implementation WWHBaseHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *left = [[UIBarButtonItem alloc]initWithTitle:@"Left" style:UIBarButtonItemStylePlain target:self action:@selector(tapShowLeftMenu)];
    self.navigationItem.leftBarButtonItem = left;
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc]initWithTitle:@"Right" style:UIBarButtonItemStylePlain target:self action:@selector(tapShowRightMenu)];
    self.navigationItem.rightBarButtonItem = right;
    
    self.slideController.enableShadow = YES;
    self.slideController.enablePanGuesture = YES;
    self.slideController.homeScaleEnabled = YES;
    self.slideController.menuScaleEnabled = YES;
    self.slideController.anchorOffset = 100;
    self.slideController.menuOffset = 100;
}

//- (WWHSlideSide)supportedSlideSide {
//    return WWHSlideSideLeft;
//}

- (void)tapShowLeftMenu {
    [self.slideController tapShowOrHideLeftAnimated];
}

- (void)tapShowRightMenu {
    [self.slideController tapShowOrHideRightAnimated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
