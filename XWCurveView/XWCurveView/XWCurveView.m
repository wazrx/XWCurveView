//
//  XWCurveView.m
//  XWCurrencyExchange
//
//  Created by YouLoft_MacMini on 16/1/20.
//  Copyright © 2016年 wazrx. All rights reserved.
//

#import "XWCurveView.h"
#import "NSString+SizeToFit.h"
#import "UIView+FrameChange.h"

#define colorWithAlpha(r, g, b, a) [UIColor colorWithRed:(r) / 255.0 green:(g) / 255.0 blue:(b) / 255.0 alpha:(a)]

NSString *const XWCurveViewPointValuesRowValueKey = @"XWCurveViewPointValuesRowValueKey";
NSString *const XWCurveViewPointValuesColumnValueKey = @"XWCurveViewPointValuesColumnValueKey";

typedef struct {
    unsigned int began  :1;
    unsigned int changed:1;
    unsigned int end    :1;
} flag;

@interface XWCurveView ()
@property (nonatomic, strong) NSMutableArray *pointArray;
@property (nonatomic, strong) NSMutableArray *columnLabels;
@property (nonatomic, strong) NSMutableArray *rowLabels;
@property (nonatomic, weak) CAShapeLayer *curveLineLayer;
@property (nonatomic, weak) CAReplicatorLayer *rowReplicatorLayer;
@property (nonatomic, weak) CAReplicatorLayer *columnReplicatorLayer;
@property (nonatomic, weak) CALayer *rowBackLine;
@property (nonatomic, weak) CALayer *columnBackLine;
@property (nonatomic, weak) CAShapeLayer *backLayer;
@property (nonatomic, weak) UIView *rowLabelsContainer;
@property (nonatomic, weak) UIView *columnLabelsContainer;
@property (nonatomic, weak) UIView *mainContainer;
@property (nonatomic, assign) BOOL needUpdate;
@property (nonatomic, strong) UIBezierPath *path;
@property (nonatomic, strong) UIBezierPath *backPath;
@property (nonatomic, assign) CGFloat rowLabelsContainerMaxWidth;
@property (nonatomic, assign) flag delegateFlag;
@property (nonatomic, assign) BOOL rowMaxSettedFlag;
@property (nonatomic, assign) BOOL rowMinSettedFlag;
@property (nonatomic, assign) BOOL columnMaxSettedFlag;
@property (nonatomic, assign) BOOL columnMinSettedFlag;

@end

@implementation XWCurveView

#pragma mark - initialize methods

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self xwp_initailizeUI];
        [self xwp_initailizeProperty];
    }
    return self;
}

- (void)awakeFromNib{
    [self xwp_initailizeUI];
    [self xwp_initailizeProperty];
}

- (void)xwp_initailizeProperty{
    _drawWithAnimation = YES;
    _columnLabelsTitleColor = _rowLabelsTitleColor = [UIColor blackColor];
    _columnLabelsTitleFont = _rowLabelsTitleFont = [UIFont systemFontOfSize:12];
    _curveLineWidth = 2;
    _curveLineColor = [UIColor blackColor];
    _fillLayerBackgroundColor = colorWithAlpha(0, 0, 0, 0.2);
    _gridLineWidth = 1;
    _gridLineColor = colorWithAlpha(0, 0, 0, 0.2);
    _gridRowCount = _gridColumnCount = 10;
    _gestureEnabel = YES;
    _minimumPressDuration = 0.5f;
    _drawAnimationDuration = 0.5f;
    [self xwp_calulateColumnLabelsHeight];
}

- (void)xwp_initailizeUI{
    //主网格曲线视图容器
    UIView *mainContainer = [UIView new];
    _mainContainer = mainContainer;
    [self addSubview:mainContainer];
    //封闭阴影
    CAShapeLayer * backLayer = [CAShapeLayer new];
    _backLayer = backLayer;
    [mainContainer.layer addSublayer:backLayer];
    //网格横线
    CAReplicatorLayer *rowReplicatorLayer = [CAReplicatorLayer new];
    _rowReplicatorLayer = rowReplicatorLayer;
    rowReplicatorLayer.position = CGPointMake(0, 0);
    CALayer *rowBackLine = [CALayer new];
    _rowBackLine = rowBackLine;
    [rowReplicatorLayer addSublayer:rowBackLine];
    [mainContainer.layer addSublayer:rowReplicatorLayer];
    //网格列线
    CAReplicatorLayer *columnReplicatorLayer = [CAReplicatorLayer new];
    _columnReplicatorLayer = columnReplicatorLayer;
    columnReplicatorLayer.position = CGPointMake(0, 0);
    CALayer *columnBackLine = [CALayer new];
    _columnBackLine = columnBackLine;
    [columnReplicatorLayer addSublayer:columnBackLine];
    [mainContainer.layer addSublayer:columnReplicatorLayer];
    //主曲线
    CAShapeLayer *curveLineLayer = [CAShapeLayer new];
    _curveLineLayer = curveLineLayer;
    curveLineLayer.fillColor = nil;
    curveLineLayer.lineJoin = kCALineJoinRound;
    [mainContainer.layer addSublayer:curveLineLayer];
    //行信息labels容器
    UIView *rowLabelsContainer = [UIView new];
    _rowLabelsContainer = rowLabelsContainer;
    [self addSubview:rowLabelsContainer];
    //列信息labels容器
    UIView *columnLabelsContainer = [UIView new];
    _columnLabelsContainer = columnLabelsContainer;
    [self addSubview:columnLabelsContainer];
}



#pragma mark - setter methods

- (void)setDelegate:(id<XWCurveViewDelegate>)delegate{
    _delegate = delegate;
    _delegateFlag.began = [delegate respondsToSelector:@selector(curveView:longGestureBeganAtcurrentLocation:value:)];
    _delegateFlag.changed = [delegate respondsToSelector:@selector(curveView:LongGestureChangedAtcurrentLocation:value:)];
    _delegateFlag.end = [delegate respondsToSelector:@selector(curveViewLongGestureEnd:)];
}

- (void)setColumnMaxValue:(CGFloat)columnMaxValue{
    _columnMaxValue = columnMaxValue;
    _columnMaxSettedFlag = YES;
}

- (void)setColumnMinValue:(CGFloat)columnMinValue{
    _columnMinValue = columnMinValue;
    _columnMinSettedFlag = YES;
}

- (void)setRowMaxValue:(CGFloat)rowMaxValue{
    _rowMaxValue = rowMaxValue;
    _rowMaxSettedFlag = YES;
}

- (void)setRowMinValue:(CGFloat)rowMinValue{
    _rowMinValue = rowMinValue;
    _rowMinSettedFlag = YES;
}

- (void)setColumnLabelsTitleFont:(UIFont *)columnLabelsTitleFont{
    _columnLabelsTitleFont = columnLabelsTitleFont;
    [self xwp_calulateColumnLabelsHeight];
}

#pragma mark - private methods

- (void)xwp_calulateColumnLabelsHeight{
    _columnLabelsHeight = [@"" xw_sizeWithfont:_columnLabelsTitleFont maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)].height;
}

- (void)xwp_setColumnLabelsContainer{
    if (!_columnNames.count) {
        return;
    }
    _columnLabelsContainer.backgroundColor = [UIColor clearColor];
    [_columnLabelsContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGSize totleSize = [[_columnNames componentsJoinedByString:@""] xw_sizeWithfont:_columnLabelsTitleFont maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    CGFloat columnSpacing = (self.width - totleSize.width - _rowLabelsContainerMaxWidth) / (_columnNames.count - 1);
    if (columnSpacing <= 0) {
        NSLog(@"行labels文字过多或字体过大，布局可能有问题");
    }
    __block CGFloat lastX = -columnSpacing;
    [_columnNames enumerateObjectsUsingBlock:^(NSString *columnName, NSUInteger idx, BOOL *stop) {
        UILabel *label = [UILabel new];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = _columnLabelsTitleColor;
        label.text = columnName;
        label.font = _columnLabelsTitleFont;
        CGSize size = [columnName xw_sizeWithfont:_columnLabelsTitleFont maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
        label.frame = CGRectMake(lastX + columnSpacing, (_columnLabelsHeight - size.height) / 2.0f, size.width, size.height);
        [_columnLabelsContainer addSubview:label];
        lastX = CGRectGetMaxX(label.frame);
    }];
    _columnLabelsContainer.frame = CGRectMake(_rowLabelsContainerMaxWidth, self.height - _columnLabelsHeight, self.width - _rowLabelsContainerMaxWidth, _columnLabelsHeight);
}

- (void)xwp_setRowLabelsContainer{
    if (!_columnNames.count) {
        _columnLabelsHeight = 0;
    }
    if (!_rowNames.count) {
        return;
    }
    _rowLabelsContainer.backgroundColor = [UIColor clearColor];
    [_rowLabelsContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    CGFloat rowSpacing = (self.height - _columnLabelsHeight - [[_rowNames componentsJoinedByString:@""] xw_sizeWithfont:_rowLabelsTitleFont maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)].height * _rowNames.count) / (_rowNames.count - 1);
    if (rowSpacing <= 0) {
        NSLog(@"行标labels文字过多或字体过大，布局可能有问题");
    }
    __block CGFloat lastY = -rowSpacing;
    __block CGFloat maxWidth = 0;
    [_rowNames enumerateObjectsUsingBlock:^(NSString *rowName, NSUInteger idx, BOOL *stop) {
        UILabel *label = [UILabel new];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = _rowLabelsTitleColor;
        label.font = _rowLabelsTitleFont;
        label.text = rowName;
        CGSize size = [rowName xw_sizeWithfont:_rowLabelsTitleFont maxSize:CGSizeMake(MAXFLOAT, MAXFLOAT)];
        label.frame = CGRectMake(5, lastY + rowSpacing, size.width, size.height);
        [_rowLabelsContainer addSubview:label];
        lastY = CGRectGetMaxY(label.frame);
        if (size.width > maxWidth) {
            maxWidth = size.width;
        }
    }];
    if (_rowLabelsWidth) {
        _rowLabelsContainerMaxWidth = _rowLabelsWidth;
    }else{
        _rowLabelsContainerMaxWidth = maxWidth + 10;
    }
    _rowLabelsContainer.frame = CGRectMake(0, 0, _rowLabelsContainerMaxWidth, self.height);
}

- (void)xwp_setMainContainer{
    _mainContainer.backgroundColor = [UIColor clearColor];
    _mainContainer.frame = CGRectMake(_rowLabelsContainer.width, 0, self.width - _rowLabelsContainer.width, self.height - _columnLabelsContainer.height);
    [CATransaction begin];
    [CATransaction setAnimationDuration:0];
    CGFloat rowSpacing = (_mainContainer.height - _gridRowCount * _gridLineWidth) / (_gridRowCount - 1);
    CGFloat columnSpacing = (_mainContainer.width - _gridColumnCount * _gridLineWidth) / (_gridColumnCount - 1);
    _rowReplicatorLayer.instanceCount = _gridRowCount;
    _columnReplicatorLayer.instanceCount = _gridColumnCount;
    _rowBackLine.frame = CGRectMake(0, 0, _mainContainer.width, _gridLineWidth);
    _rowReplicatorLayer.instanceTransform = CATransform3DMakeTranslation(0, rowSpacing + _gridLineWidth, 0);
    _columnReplicatorLayer.frame = _rowReplicatorLayer.frame = _mainContainer.bounds;
    _columnBackLine.frame = CGRectMake(0, 0, _gridLineWidth, _mainContainer.height);
    _columnReplicatorLayer.instanceTransform = CATransform3DMakeTranslation(columnSpacing + _gridLineWidth, 0, 0);
    _curveLineLayer.strokeColor = _curveLineColor.CGColor;
    _curveLineLayer.lineWidth = _curveLineWidth;
    _backLayer.fillColor = _fillLayerBackgroundColor.CGColor;
    _backLayer.hidden = _fillLayerHidden;
    _rowReplicatorLayer.hidden = _columnReplicatorLayer.hidden = _gridViewlayerHidden;
    _columnBackLine.backgroundColor = _rowBackLine.backgroundColor = _gridLineColor.CGColor;
    [CATransaction commit];
}

- (void)xwp_setCurveLine{
    if (!_pointValues.count) {
        NSLog(@"pointValues为空，没有可绘制的点");
        return;
    }
    dispatch_async(dispatch_queue_create("处理计算点和path的队列", NULL), ^{
        [self xwp_sortPointValues];
        [self xwp_checkEdgeValues];
        [self xwp_changePointArrayFromValueArray];
        [self xwp_makePath];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self xwp_drawCurveWithPath];
        });
    });
}

/**
 *  按传入数据的值的横坐标值从小到大排序一下
 */
- (void)xwp_sortPointValues{
    NSMutableArray *temp = [NSMutableArray arrayWithArray:_pointValues];
    [temp sortUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        if ([obj1[XWCurveViewPointValuesRowValueKey] floatValue] > [obj2[XWCurveViewPointValuesRowValueKey] floatValue]) {
            return NSOrderedDescending;
        }else{
            return NSOrderedAscending;
        }
    }];
    _pointValues = temp.copy;
}

/**
 *  计算横纵坐标的最值，如果没有设置就使用计算的最值
 */
- (void)xwp_checkEdgeValues{
    CGFloat rowMax = [_pointValues.lastObject[XWCurveViewPointValuesRowValueKey] floatValue];
    CGFloat rowMin = [_pointValues.firstObject[XWCurveViewPointValuesRowValueKey] floatValue];
    CGFloat columnMax = -MAXFLOAT;
    CGFloat columnMin = MAXFLOAT;
    for (NSDictionary *pointValue in _pointValues) {
        if ([pointValue[XWCurveViewPointValuesColumnValueKey] floatValue] > columnMax) {
            columnMax = [pointValue[XWCurveViewPointValuesColumnValueKey] floatValue];
        }
        if ([pointValue[XWCurveViewPointValuesColumnValueKey] floatValue] < columnMin) {
            columnMin = [pointValue[XWCurveViewPointValuesColumnValueKey] floatValue];
        }
    }
    if (!_rowMaxSettedFlag) {
        _rowMaxValue = rowMax;
    }
    if (!_rowMinSettedFlag) {
        _rowMinValue = rowMin;
    }
    if (!_columnMaxSettedFlag) {
        _columnMaxValue = columnMax;
    }
    if (!_columnMinSettedFlag) {
        _columnMinValue = columnMin;
    }
}

/**
 *  将传入的点的值数组转换为坐标数组
 */
- (void)xwp_changePointArrayFromValueArray{
    _pointArray = @[].mutableCopy;
    for (NSDictionary *dict in _pointValues) {
        CGPoint point = [self xwp_changePointFromValue:dict];
        [_pointArray addObject:[NSValue valueWithCGPoint:point]];
    }
}

/**
 *  将传入的点根据值转换为坐标
 */
- (CGPoint)xwp_changePointFromValue:(NSDictionary *)dict{
    CGFloat rowValue = [dict[XWCurveViewPointValuesRowValueKey] floatValue];
    CGFloat columnValue = [dict[XWCurveViewPointValuesColumnValueKey] floatValue];
    CGPoint point = CGPointMake(_mainContainer.width / (_rowMaxValue - _rowMinValue) * (rowValue - _rowMinValue), _mainContainer.height / (_columnMaxValue - _columnMinValue) * (_columnMaxValue - columnValue));
    return point;
}

/**
 *  根据得到的点计算曲线的path和填充曲线的path
 */

- (void)xwp_makePath{
    UIBezierPath * path = [UIBezierPath bezierPath];
    UIBezierPath *backPath = [UIBezierPath bezierPath];
    CGPoint firstPoint = [_pointArray[0] CGPointValue];
    CGPoint lastPoint = [_pointArray[_pointArray.count - 1] CGPointValue];
    [path moveToPoint:firstPoint];
    [backPath moveToPoint:CGPointMake(firstPoint.x, _mainContainer.height)];
    for (NSValue *pointValue in _pointArray) {
        CGPoint point = [pointValue CGPointValue];
        if (pointValue == _pointArray[0]) {
            [backPath addLineToPoint:point];
            continue;
        }
        [backPath addLineToPoint:point];
        [path addLineToPoint:point];
    }
    [backPath addLineToPoint:CGPointMake(lastPoint.x, _mainContainer.height)];
    _path = path;
    _backPath = backPath;
}

/**
 *  根据path位置曲线
 */

- (void)xwp_drawCurveWithPath{
    _backLayer.path = _backPath.CGPath;
    _curveLineLayer.path = _path.CGPath;
    _curveLineLayer.strokeEnd = 1;
    if (_drawWithAnimation) {
        CABasicAnimation *pointAnim = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pointAnim.fromValue = @0;
        pointAnim.toValue = @1;
        pointAnim.duration = _drawAnimationDuration;
        [_curveLineLayer addAnimation:pointAnim forKey:@"drawLine"];
    }
}

- (void)xwp_addGesture{
    if (!_gestureEnabel) {
        return;
    }
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(xwp_longPressed:)];
    longPressGesture.minimumPressDuration = _minimumPressDuration;
    [self addGestureRecognizer:longPressGesture];
}

- (void)xwp_longPressed:(UILongPressGestureRecognizer *)gesture{
    if (!_pointArray.count) {
        return;
    }
    CGPoint currentPoint = [gesture locationOfTouch:0 inView:self];
    NSUInteger index = 0;
    CGFloat distace = MAXFLOAT;
    CGFloat x = 0;
    for (NSNumber *pointValue in _pointArray) {
        CGPoint point = [pointValue CGPointValue];
        if (fabs(point.x - currentPoint.x) < distace) {
            index = [_pointArray indexOfObject:pointValue];
            distace = fabs(point.x - currentPoint.x);
            x = point.x;
        }
    }
    currentPoint = [_mainContainer convertPoint:[_pointArray[index] CGPointValue] toView:self];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (_delegateFlag.began) {
            [_delegate curveView:self longGestureBeganAtcurrentLocation:currentPoint value:_pointValues[index]];
        }
        
    }
    if (gesture.state == UIGestureRecognizerStateChanged) {
        if (_delegateFlag.changed) {
            [_delegate curveView:self LongGestureChangedAtcurrentLocation:currentPoint value:_pointValues[index]];
        }
    }
    
    if (gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateFailed) {
        if (_delegateFlag.end) {
            [_delegate curveViewLongGestureEnd:self];
        }
    }
}


#pragma mark - pubilic methods

- (void)xw_drawCurveView{
    [self layoutIfNeeded];
    [self xwp_setRowLabelsContainer];
    [self xwp_setColumnLabelsContainer];
    [self xwp_setMainContainer];
    [self xwp_setCurveLine];
    [self xwp_addGesture];
}

@end
