//
//  XWCurveView.h
//  XWCurrencyExchange
//
//  Created by YouLoft_MacMini on 16/1/20.
//  Copyright © 2016年 wazrx. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XWCurveView;

//包装坐标点数组里的字典时，所用到的字典key值
extern NSString *const XWCurveViewPointValuesRowValueKey;
extern NSString *const XWCurveViewPointValuesColumnValueKey;

@protocol XWCurveViewDelegate <NSObject>

@optional
/**手势开始时调用,回调手指所在位置的最近的坐标和该坐标对应的传入的字典值[注意：该坐标是相对于XWCurveView的，如要使用请使用convert方法进行转换(如:[self.view convertPoint:location fromView:view])]*/
- (void)curveView:(XWCurveView *)view longGestureBeganAtcurrentLocation :(CGPoint)location value:(NSDictionary *)value;
/**手势移动时调用,回调手指所在位置的最近的坐标和对应的值*/
- (void)curveView:(XWCurveView *)view LongGestureChangedAtcurrentLocation :(CGPoint)location value:(NSDictionary *)value;
/**手势结束调用*/
- (void)curveViewLongGestureEnd:(XWCurveView *)view;

@end

@interface XWCurveView : UIView

#pragma 数据相关属性
//所有的坐标点数组，需要传递字典数组，字典必须包含key值为 XWCurveViewPointValuesRowValueKey 和 XWCurveViewPointValuesColumnValueKey 分别代表横纵的值,可以包含其他值，在代理中可回调，必传
@property (nonatomic, copy) NSArray *pointValues;
//列标labels的标题数组，如果为空不显示列标
@property (nonatomic, copy) NSArray *columnNames;
//行标labels的标题数组，如果为空不显示行标
@property (nonatomic, copy) NSArray *rowNames;
//列最大值，不传的话会根据pointValues自动寻找最大值
@property (nonatomic, assign) CGFloat columnMaxValue;
//列最小值，不传的话会根据pointValues自动寻找最小值
@property (nonatomic, assign) CGFloat columnMinValue;
//行最大值，不传的话会根据pointValues自动寻找最大值
@property (nonatomic, assign) CGFloat rowMaxValue;
//行最小值，不传的话会根据pointValues自动寻找最小值
@property (nonatomic, assign) CGFloat rowMinValue;

#pragma 动画相关
//绘制的时候是否需要动画，默认YES
@property (nonatomic, assign) BOOL drawWithAnimation;
//绘制动画时间，默认0.5s
@property (nonatomic, assign) CGFloat drawAnimationDuration;

#pragma 绘制曲线相关
//绘制曲线颜色，默认黑色
@property (nonatomic, strong) UIColor *curveLineColor;
//绘制曲线宽度，默认2.00f
@property (nonatomic, assign) CGFloat curveLineWidth;

#pragma 填充layer相关
//是否隐藏填充layer，默认NO
@property (nonatomic, assign) BOOL fillLayerHidden;
//填充layer的颜色，默认黑色，透明度0.2
@property (nonatomic, strong) UIColor *fillLayerBackgroundColor;

#pragma 网格线相关
//是否隐藏网格线，默认NO
@property (nonatomic, assign) BOOL gridViewlayerHidden;
//网格线宽度，默认1
@property (nonatomic, assign) CGFloat gridLineWidth;
//网格线颜色，默认黑色,
@property (nonatomic, strong) UIColor *gridLineColor;
//行网格线数量，默认10
@property (nonatomic, assign) NSUInteger gridRowCount;
//列网格线数量，默认10
@property (nonatomic, assign) NSUInteger gridColumnCount;

#pragma columnLabels,列标相关
//列标label的颜色, 默认黑色
@property (nonatomic, strong) UIColor *columnLabelsTitleColor;
//列标label的字体，默认12
@property (nonatomic, strong) UIFont *columnLabelsTitleFont;
//列标labels高度，默认根据列标字体自动计算
@property (nonatomic, assign) CGFloat columnLabelsHeight;

#pragma rowLabels,行标相关
//行标宽度，默认根据行标的文字自动计算
@property (nonatomic, assign) CGFloat rowLabelsWidth;
//行标label的颜色, 默认黑色
@property (nonatomic, strong) UIColor *rowLabelsTitleColor;
//行标label的字体，默认12
@property (nonatomic, strong) UIFont *rowLabelsTitleFont;

#pragma 手势相关
//是否开启长按手势，开启手势后长按会通过代理将手指所在位置的最近的坐标和对应的值返回，默认开启
@property (nonatomic, assign) BOOL gestureEnabel;
//手势触发最短时间，默认0.5f
@property (nonatomic, assign) CGFloat minimumPressDuration;

//监听手势的代理
@property (nonatomic, assign) id<XWCurveViewDelegate> delegate;

//绘制曲线，初始化和更新数据后都调用该方法重新绘制曲线
- (void)xw_drawCurveView;

@end
