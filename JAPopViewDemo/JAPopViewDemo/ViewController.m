//
//  ViewController.m
//  JAPopViewDemo
//
//  Created by Jason on 16/07/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import "ViewController.h"
#import <JAPopView/JAPopView.h>

@interface ViewController () <JAPopViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    JAPopView *popView = [JAPopView popViewWithType:JAPopViewTypeAverage delegate:self];
    UIButton *btn1 = [popView actionWithTitle:@"取消" style:JAPopViewActionStyleCancel handler:^(UIButton * _Nonnull btn) {
        
    }];
    
    UIButton *btn2 = [popView actionWithTitle:@"确定" style:JAPopViewActionStyleEnsure handler:^(UIButton * _Nonnull btn) {
        
    }];
    
    
    [popView addAction:btn1];
    [popView addAction:btn2];
    
    [self.view addSubview:popView];
}

- (UIView *)popViewProviderContent:(JAPopView *)popView {
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 120)];
    UILabel *descMoneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 80, 30)];
    descMoneyLabel.font = [UIFont systemFontOfSize:13];
    descMoneyLabel.text = @"剩余金额";
    [contentView addSubview:descMoneyLabel];
    
    UITextField *moneyField = [[UITextField alloc] initWithFrame:CGRectMake(70, 20, 200, 35)];
    moneyField.borderStyle = UITextBorderStyleRoundedRect;
    [contentView addSubview:moneyField];
    
    UILabel *reasonLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, 60, 30)];
    reasonLabel.font =  [UIFont systemFontOfSize:13];
    reasonLabel.text = @"修改理由";
    [contentView addSubview:reasonLabel];
    
    UITextField *reasonField = [[UITextField alloc] initWithFrame:CGRectMake(70, 70, 200, 35)];
    reasonField.borderStyle = UITextBorderStyleRoundedRect;
    [contentView addSubview:reasonField];
    
    return contentView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
