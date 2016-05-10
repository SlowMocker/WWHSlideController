//
//  WWHHomeViewController.m
//  Test
//
//  Created by Wu on 16/5/10.
//  Copyright © 2016年 Wu. All rights reserved.
//

#import "WWHHomeViewController.h"
#import "WWHSlideController.h"

@interface WWHHomeViewController ()<WWHSlideControllerDelegate>
{
    UIButton *_btn;
}
@end

@implementation WWHHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Home";
    self.view.backgroundColor = [UIColor yellowColor];
    
    self.slideController.slideDelegate = self;
    
    
    _btn = [UIButton buttonWithType:UIButtonTypeCustom];
    _btn.backgroundColor = [UIColor blackColor];
    _btn.frame = CGRectMake(64, 64, 100, 100);
    [self.view addSubview:_btn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (WWHSlideSide)supportedSlideSide {
    return WWHSlideSideLeft | WWHSlideSideRight;
}

#pragma mark- WWHSlideControllerDelegate
//- (void)slideControllerScrollingBackHome:(WWHSlideController *)slideController {
//    _btn.alpha = self.slideController.zoomFactor;
//    NSLog(@"%lf",self.slideController.zoomFactor);
//    self.view.alpha = self.slideController.zoomFactor;
//}
//
//- (void)slideControllerScrollingShowMenu:(WWHSlideController *)slideController {
//    _btn.alpha =1 - self.slideController.zoomFactor;
//    self.view.alpha =1 - self.slideController.zoomFactor / 2;
//}
//
//
//
//
//
//
//- (void)slideControllerDidHome:(WWHSlideController *)slideController {
//    self.navigationItem.leftBarButtonItem.tintColor = [UIColor purpleColor];
//}
//
//- (void)slideControllerDidShowLeftMenu:(WWHSlideController *)slideController {
//    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
//}
//
//- (void)slideControllerDidShowRightMenu:(WWHSlideController *)slideController {
//    
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
