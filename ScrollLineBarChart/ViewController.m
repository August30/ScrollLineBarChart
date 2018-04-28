//
//  ViewController.m
//  ScrollLineBarChart
//
//  Created by CygMac on 2018/4/28.
//  Copyright © 2018年 XunKu. All rights reserved.
//

#import "ViewController.h"
#import "XKSrollLineChart.h"
#import "XKSrollBarChart.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 可以滚动，点击x轴显示值
    
    // 折线图
    XKSrollLineChart *lineChart = [[XKSrollLineChart alloc] initWithFrame:CGRectMake(0, 80, SCREEN_WIDTH, 155)];
    lineChart.apperColor = [UIColor colorWithRed:43.f / 255.f green:73.f / 255.f blue:135.f / 255.f alpha:1];
    lineChart.textColor = [UIColor colorWithRed:122.f / 255.f green:143.f / 255.f blue:153.f / 255.f alpha:1];
    lineChart.canScroll = YES;
    lineChart.showBackground = NO;
    lineChart.xLabelNames = @[@"9:00", @"9:30", @"10:00", @"10:30", @"11:00", @"11:30", @"12:00", @"12:30"];
    lineChart.datas = @[@(1.0), @(1.5), @(2.0), @(0.1), @(0.5), @(3.0), @(1.5), @(1.0)];
    [lineChart strokeChart];
    [self.view addSubview:lineChart];
    
    // 柱状图
    XKSrollBarChart *barChart = [[XKSrollBarChart alloc] initWithFrame:CGRectMake(0, 80 + 155 + 10, SCREEN_WIDTH, 155)];
    barChart.apperColor = [UIColor colorWithRed:43.f / 255.f green:73.f / 255.f blue:135.f / 255.f alpha:1];
    barChart.textColor = [UIColor colorWithRed:122.f / 255.f green:143.f / 255.f blue:153.f / 255.f alpha:1];
    barChart.canScroll = YES;
    barChart.xLabelNames = @[@"9:00", @"9:30", @"10:00", @"10:30", @"11:00", @"11:30", @"12:00", @"12:30"];
    barChart.datas = @[@(1.0), @(1.5), @(2.0), @(0.1), @(0.5), @(3.0), @(1.5), @(1.0)];
    [barChart strokeChart];
    [self.view addSubview:barChart];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
