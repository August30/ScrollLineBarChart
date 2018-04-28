//
//  XKSrollBarChart.m
//  YiLink
//
//  Created by CygMac on 2018/4/10.
//  Copyright © 2018年 xunku_mac. All rights reserved.
//

#import "XKSrollBarChart.h"
#import "UIView+Extension.h"

NSInteger const BarMinCount = 6;

static NSInteger const xBarBeginTag = 0;
static NSInteger const yBarBeginTag = 100;

static CGFloat const BarBottomMargin = 40;
static CGFloat const BarTopMargin = 30;

@interface XKSrollBarChart ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *scrollViewContentView;

@property (nonatomic, strong) NSArray *xArray;
@property (nonatomic, strong) NSArray *yArray;

@property (nonatomic, strong) NSArray *xLabelArray;
@property (nonatomic, strong) NSArray *valueLabelArray;

@property (nonatomic, assign) CGFloat maxY;
@property (nonatomic, strong) NSArray *yLabelNames;

@property (nonatomic, strong) CAShapeLayer *barShaperLayer;
@property (nonatomic, strong) CAShapeLayer *bgSHaperLayer;

@property (nonatomic, strong) UIView *pointView;

@end

@implementation XKSrollBarChart


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.selectIndex = -1;
    }
    return self;
}


- (void)strokeChart {
    for (UIView *view in self.scrollViewContentView.subviews) {
        [view removeFromSuperview];
    }
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
    
    [self.barShaperLayer removeFromSuperlayer];
    [self.bgSHaperLayer removeFromSuperlayer];
    
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.scrollViewContentView];
    [self scrollViewInitSize];
    [self XYLabelInit];
    [self XYInit];
//    [self drawLine];
    [self drawBar];
    [self drawDotLine];
    [self addSelectPoint];
    [self valueLabelInit];
}

- (void)scrollViewInitSize {
    self.scrollView.frame = CGRectMake(52,0,self.frame.size.width - 52,self.frame.size.height);
    CGFloat itemWidth = self.scrollView.frame.size.width / BarMinCount;
    CGFloat width = itemWidth * self.datas.count;
    CGSize contentSize = CGSizeMake(width,self.scrollView.frame.size.height);
    self.scrollView.contentSize = contentSize;
    self.scrollViewContentView.frame =  CGRectMake(0,0,width,self.scrollView.frame.size.height);
    if (self.datas.count > BarMinCount) {
        [self.scrollView setContentOffset:CGPointMake(itemWidth * (self.datas.count - BarMinCount), 0)];
    }
}

- (void)XYInit {
    NSMutableArray *xArray = [NSMutableArray array];
    CGFloat width =  self.scrollViewContentView.frame.size.width;
    CGFloat height = self.scrollViewContentView.frame.size.height;
    CGFloat xLabelWidth = (width)/self.xLabelNames.count;
    [self.xLabelNames enumerateObjectsUsingBlock:^(NSString *xName, NSUInteger idx, BOOL *stop) {
        [xArray addObject:@(idx * xLabelWidth + xLabelWidth/2)];
    }];
    self.xArray = xArray;
    
    CGFloat chartHeight = height - BarTopMargin - BarBottomMargin;
    // 每一份高度
    CGFloat eachHeight  = chartHeight/([[self.yLabelNames lastObject] floatValue]);
    NSMutableArray *yArray = [NSMutableArray array];
    [self.datas enumerateObjectsUsingBlock:^(NSNumber *yNumber, NSUInteger idx, BOOL *stop) {
        CGFloat yHeight = [yNumber floatValue] *eachHeight;
        CGFloat y = height - yHeight - BarBottomMargin;
        [yArray addObject:@(y)];
    }];
    self.yArray = yArray;
}

- (void)XYLabelInit {
    CGFloat width =  self.scrollViewContentView.frame.size.width;
    CGFloat height = self.scrollViewContentView.frame.size.height;
    CGFloat xLabelWidth = (width )/self.xLabelNames.count;
    NSMutableArray *marr = [NSMutableArray array];
    [self.xLabelNames enumerateObjectsUsingBlock:^(NSString *xName, NSUInteger idx, BOOL *stop) {
        UILabel *xLabel = [[UILabel alloc] init];
        xLabel.font = [UIFont systemFontOfSize:12];
        xLabel.textAlignment = NSTextAlignmentCenter;
        xLabel.tag = xBarBeginTag + idx;
        xLabel.text = xName;
        xLabel.textColor = self.textColor;
        [self.scrollViewContentView addSubview:xLabel];
        xLabel.x = xLabelWidth * idx;
        xLabel.y = self.height - 45;
        xLabel.width = xLabelWidth;
        xLabel.height = 45;
        xLabel.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapXLabel:)];
        [xLabel addGestureRecognizer:tap];
        [marr addObject:xLabel];
        // 分割线
//        UIImageView *lineImageView = [[UIImageView alloc] init];
//        lineImageView.backgroundColor = UIColorFromRGB(0xE1E1E1);
//        [self.scrollViewContentView addSubview:lineImageView];
//        [lineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerX.mas_equalTo(xLabel);
//            make.bottom.mas_equalTo(-BarBottomMargin + 4);
//            make.width.mas_equalTo(1);
//            make.height.mas_equalTo(4);
//        }];
    }];
    self.xLabelArray = marr;
    
    NSInteger maxY = [[self.datas valueForKeyPath:@"@max.integerValue"] integerValue];
    if (maxY >= 1000) {
        maxY = (maxY + 1000) / 1000 * 1000;
    }
    CGFloat gap = (maxY)/3;
    gap = gap ?: 1;
    NSMutableArray *ylableNames =  [NSMutableArray array];
    for (int i = 1; i <= 3 ; ++i) {
        [ylableNames addObject:@(gap * i)];
    }
    self.yLabelNames = ylableNames;
    self.maxY = maxY;
    NSArray *withZeroYlabelNames = [@[@0] arrayByAddingObjectsFromArray:self.yLabelNames];
    CGFloat  yLabelGap = (height - BarTopMargin - BarBottomMargin) / 3;
    
    
    [withZeroYlabelNames enumerateObjectsUsingBlock:^(NSNumber *yNumber, NSUInteger idx, BOOL *stop) {
        UILabel *yLabel = [[UILabel alloc] init];
        yLabel.font = [UIFont systemFontOfSize:12];
        yLabel.textColor = self.textColor;
        yLabel.text = yNumber.integerValue == 0 ? @"" : [NSString stringWithFormat:@"¥%.2f", yNumber.floatValue];
        yLabel.textAlignment = NSTextAlignmentRight;
        yLabel.tag = yBarBeginTag + idx;
        [self addSubview:yLabel];
        yLabel.x = 10;
        yLabel.y = self.height - (BarBottomMargin + idx * yLabelGap) - 10;
        yLabel.width = 40;
        yLabel.height = 20;
        // 分割线
//        UIImageView *lineImageView = [[UIImageView alloc] init];
//        lineImageView.backgroundColor = UIColorFromRGB(0xE1E1E1);
//        [self.scrollViewContentView addSubview:lineImageView];
//        [lineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(1);
//            make.left.mas_equalTo(yLabel.mas_right).offset(10);
//            make.right.mas_equalTo(0);
//            make.centerY.mas_equalTo(yLabel);
//        }];
    }];
}

- (void)valueLabelInit {
    NSMutableArray *marr = [NSMutableArray array];
    // 对应的值
    [self.datas enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger idx, BOOL *stop) {
        UILabel *valueLabel = [[UILabel alloc] init];
        valueLabel.font = [UIFont systemFontOfSize:12];
        valueLabel.textColor = self.textColor;
        valueLabel.textAlignment = NSTextAlignmentCenter;
        valueLabel.tag = xBarBeginTag + idx;
        valueLabel.text = [NSString stringWithFormat:@"%.2f", value.floatValue];
        [self.scrollViewContentView addSubview:valueLabel];
        CGFloat W = 60;
        CGFloat H = 20;
        valueLabel.x = [self.xArray[idx] floatValue] - W / 2;
        valueLabel.y = [self.yArray[idx] floatValue] - (H + 3);
        valueLabel.width = W;
        valueLabel.height = H;
        valueLabel.hidden = YES;
        [marr addObject:valueLabel];
    }];
    self.valueLabelArray = marr;
}

// 点击了xLabel
- (void)tapXLabel:(UITapGestureRecognizer *)tap {
    for (UILabel *label in self.valueLabelArray) {
        label.hidden = YES;
    }
    UILabel *tapLabel = (UILabel *)tap.view;
    UILabel *valueLabel = self.valueLabelArray[tapLabel.tag];
    valueLabel.hidden = NO;
}

- (void)drawLine {
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake([self.xArray[0] floatValue], [self.yArray[0] floatValue])];
    for (int i = 1; i < self.xArray.count ; ++i) {
        [bezierPath addLineToPoint:CGPointMake([self.xArray[i] floatValue], [self.yArray[i] floatValue])];
    }
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.frame = self.bounds;
    shapeLayer.lineWidth = 3;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = self.apperColor.CGColor;
    [self.scrollViewContentView.layer addSublayer:shapeLayer];
    shapeLayer.path = bezierPath.CGPath;
    [bezierPath stroke];
    self.barShaperLayer = shapeLayer;
}

- (void)drawBar {
    CGFloat width =  self.scrollViewContentView.frame.size.width;
    CGFloat xLabelWidth = (width )/self.xLabelNames.count;
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    CGFloat height = self.frame.size.height;
    [bezierPath moveToPoint:CGPointMake([self.xArray[0] floatValue] - xLabelWidth/4, height - BarBottomMargin)];
    for (int i = 0; i < self.xArray.count ; ++i) {
        [bezierPath moveToPoint:CGPointMake([self.xArray[i] floatValue] - xLabelWidth/4, height - BarBottomMargin)];
        [bezierPath addLineToPoint:CGPointMake([self.xArray[i] floatValue] - xLabelWidth/4, [self.yArray[i] floatValue])];
        [bezierPath addLineToPoint:CGPointMake([self.xArray[i] floatValue] + xLabelWidth/4, [self.yArray[i] floatValue])];
        [bezierPath addLineToPoint:CGPointMake([self.xArray[i] floatValue] + xLabelWidth/4, height - BarBottomMargin)];
    }
    [bezierPath addLineToPoint:CGPointMake([self.xArray.lastObject floatValue],height - BarBottomMargin)];
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.frame = self.bounds;
    shapeLayer.fillColor = self.apperColor.CGColor;
    shapeLayer.strokeColor = [UIColor clearColor].CGColor;
    [self.scrollViewContentView.layer addSublayer:shapeLayer];
    shapeLayer.path = bezierPath.CGPath;
    [bezierPath stroke];
    self.bgSHaperLayer = shapeLayer;
}

// 虚线
- (void)drawDotLine {
    if (self.selectIndex >= 0) {
        CGFloat selectPointX = [self.xArray[self.selectIndex] floatValue];
        UIBezierPath *dotline = [UIBezierPath bezierPath];
        [dotline moveToPoint:CGPointMake(selectPointX , 0)];
        [dotline addLineToPoint:CGPointMake(selectPointX , self.height - BarBottomMargin)];
        dotline.lineWidth = 1;
        [[UIColor clearColor] set];
        [dotline stroke];
        
        CAShapeLayer *dotShapeLine = [[CAShapeLayer alloc]init];
        dotShapeLine.strokeColor = [UIColor colorWithRed:151.f / 255.f green:151.f / 255.f blue:151.f / 255.f alpha:1].CGColor;
        dotShapeLine.lineWidth = 1;
        [dotShapeLine setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:6], [NSNumber numberWithInt:4], nil]];
        [self.layer addSublayer:dotShapeLine];
        dotShapeLine.path = dotline.CGPath;
    }
}

- (void)addSelectPoint {
    if (self.selectIndex >= 0) {
        CGFloat selectPointX = [self.xArray[self.selectIndex] floatValue];
        CGFloat selectPointY = [self.yArray[self.selectIndex] floatValue];
        self.pointView.center = CGPointMake(selectPointX - 6, selectPointY - 6);
        self.pointView.backgroundColor = self.apperColor;
        self.pointView.size = CGSizeMake(12,12);
        [self addSubview:self.pointView];
    }
}

#pragma mark - Get

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.clipsToBounds = YES;
        _scrollView.bounces = NO;
    }
    return _scrollView;
}

- (UIView *)scrollViewContentView {
    if (!_scrollViewContentView) {
        _scrollViewContentView = [[UIView alloc] init];
    }
    return _scrollViewContentView;
}

- (UIColor *)apperColor {
    if (!_apperColor) {
        _apperColor = [UIColor colorWithRed:43.f / 255.f green:73.f / 255.f blue:135.f / 255.f alpha:1];
    }
    return _apperColor;
}

- (UIView *)pointView {
    if (!_pointView) {
        _pointView = [[UIView alloc] init];
        _pointView.layer.cornerRadius = 6;
        _pointView.layer.masksToBounds = YES;
    }
    return _pointView;
}

@end
