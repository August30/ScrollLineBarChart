//
// Created by freedom on 2016/11/14.
// Copyright (c) 2016 freedom. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface XKSrollLineChart : UIView

@property (nonatomic, assign) BOOL canScroll;
@property (nonatomic, strong) NSArray <NSNumber *>*datas;
@property (nonatomic, strong) NSArray <NSString *>*xLabelNames;
@property (nonatomic, strong) UIColor *apperColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) NSInteger selectIndex;

- (void)strokeChart;

@end
