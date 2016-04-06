//
//  ViewController.m
//  XWCurveView
//
//  Created by wazrx on 16/4/1.
//  Copyright © 2016年 wazrx. All rights reserved.
//

#import "ViewController.h"
#import "XWCurveView.h"
#import "Masonry.h"

#define colorWithAlpha(r, g, b, a) [UIColor colorWithRed:(r) / 255.0 green:(g) / 255.0 blue:(b) / 255.0 alpha:(a)]

@interface ViewController ()<XWCurveViewDelegate>
@property (nonatomic, weak) XWCurveView *curveView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    XWCurveView *curveView = [XWCurveView new];
    _curveView = curveView;
    curveView.pointValues = [self xwp_makeArray];
    curveView.backgroundColor = [UIColor whiteColor];
    //如果不设置最值，会根据传入的pointValues自动计算
//    curveView.rowMaxValue = 50;
//    curveView.rowMinValue = 0;
    curveView.columnMaxValue = 100;
//    curveView.columnMinValue = 50;
    curveView.columnNames = @[@"2016-03-01", @"2016-03-05", @"2016-03-10"];
    curveView.rowNames = @[@"100", @"50", @"0"];
//    curveView.rowLabelsWidth = 40;
    curveView.delegate = self;
    curveView.gridRowCount = 20;
    [self.view addSubview:curveView];
    [curveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(250, 0, 80, 5));
    }];
    [curveView xw_drawCurveView];
    UIButton *reDrawButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [reDrawButton setTitle:@"点击重新绘制" forState:UIControlStateNormal];
    [reDrawButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [reDrawButton addTarget:self action:@selector(xwp_reDraw) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:reDrawButton];
    [reDrawButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-10);
    }];
}

/**
 *  构造数据
 */
- (NSArray *)xwp_makeArray{
    NSMutableArray *temp = @[].mutableCopy;
    for (int i = 0; i < 50; i ++) {
        //字典必须包含下面两个key值
        [temp addObject:@{XWCurveViewPointValuesRowValueKey : @(1.25 * i),
                          XWCurveViewPointValuesColumnValueKey : @(arc4random() % 80)}];
    }
    return temp.copy;
}

- (void)xwp_reDraw{
    _curveView.pointValues = [self xwp_makeArray];
    _curveView.curveLineColor = colorWithAlpha(arc4random() % 255, arc4random() % 255, arc4random() % 255, 1);
    [_curveView xw_drawCurveView];
}

#pragma mark - <XWCurveViewDelegate>

- (void)curveView:(XWCurveView *)view longGestureBeganAtcurrentLocation:(CGPoint)location value:(NSDictionary *)value{
    //使用location请先convert，location的值是相对于curveView的，可使用[self.view convertPoint:location fromView:view];
    NSLog(@"%@,%@", NSStringFromCGPoint([self.view convertPoint:location fromView:view]), value);
}

- (void)curveView:(XWCurveView *)view LongGestureChangedAtcurrentLocation:(CGPoint)location value:(NSDictionary *)value{
    NSLog(@"%@,%@", NSStringFromCGPoint([self.view convertPoint:location fromView:view]), value);
    
}

- (void)curveViewLongGestureEnd:(XWCurveView *)view{
    
}

@end
