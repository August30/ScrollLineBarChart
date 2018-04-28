//
//  XKSrollBarChart.h
//  YiLink
//
//  Created by CygMac on 2018/4/10.
//  Copyright © 2018年 xunku_mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XKSrollBarChart : UIView

@property (nonatomic, assign) BOOL canScroll;
@property (nonatomic, strong) NSArray <NSNumber *>*datas;
@property (nonatomic, strong) NSArray <NSString *>*xLabelNames;
@property (nonatomic, strong) UIColor *apperColor;
@property (nonatomic, strong) UIColor *textColor;

- (void)strokeChart;

@end
