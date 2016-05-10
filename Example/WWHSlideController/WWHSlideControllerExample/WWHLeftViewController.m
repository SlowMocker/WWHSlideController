//
//  WWHLeftViewController.m
//  Test
//
//  Created by Wu on 16/5/10.
//  Copyright © 2016年 Wu. All rights reserved.
//

#import "WWHLeftViewController.h"

@interface WWHLeftViewController ()
{
    UIImageView *_imageView;
}

@end

@implementation WWHLeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    _imageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    _imageView.image = [UIImage imageNamed:@"1"];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.layer.masksToBounds = YES;
    _imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:_imageView];
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
