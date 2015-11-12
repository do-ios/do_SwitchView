//
//  do_SwitchView_View.m
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_SwitchView_UIView.h"

#import "doInvokeResult.h"
#import "doUIModuleHelper.h"
#import "doScriptEngineHelper.h"
#import "doIScriptEngine.h"

#define onColor @"00FF00"
#define offColor @"888888"
#define sliderColor @"FFFFFF"
#define defaultShape @"circle"
#define defaultColorsString @"00FF00,888888,FFFFFF"

@interface myLayer : CALayer
@property(nonatomic, strong)UIColor *myShadowColor;
@property(nonatomic, strong)UIColor *myContentColor;
@property(nonatomic, assign)BOOL isOn;
@property(nonatomic, assign)CGFloat board;
+ (void)setShapeValue:(NSString *)newValue;
@end


@implementation do_SwitchView_UIView
{
    myLayer *_colorLayer;
    myLayer *_moveLayer;
    myLayer *_changLayer;
    //边框宽度
    CGFloat _board;
    CGFloat W,H;
    //YES表示正常显示W>H
    BOOL isNormal;
    //是否是开启状态
    BOOL isOn;
    //边框颜色
    //    UIColor *_221Color;
    //开始，按下点坐标
    CGPoint beginPoint;
    //是否长时间按下。长时间按下pan和tap手势无效。需要还原组件
    BOOL isLongTouch;
    //移动过，就不返回
    BOOL isMoved;
}

#pragma mark - doIUIModuleView协议方法（必须）
//引用Model对象
- (void) LoadView: (doUIModule *) _doUIModule
{
    _model = (typeof(_model)) _doUIModule;
    self.defaultColors = YES;
    isOn = NO;
    isLongTouch = YES;
    self.backgroundColor = [UIColor clearColor];
    
    _colorLayer = [[myLayer alloc] init];
    if (self.defaultColors == YES)
    {
        _colorLayer.myContentColor = [doUIModuleHelper GetColorFromString:offColor :[UIColor clearColor]];
        
        _colorLayer.myShadowColor = [doUIModuleHelper GetColorFromString:offColor :[UIColor clearColor]];    }
    [self.layer addSublayer:_colorLayer];
    
    _changLayer = [[myLayer alloc] init];
    if (self.defaultColors == YES)
    {
        _changLayer.myContentColor = [doUIModuleHelper GetColorFromString:offColor :[UIColor clearColor]];
        _changLayer.myShadowColor = [doUIModuleHelper GetColorFromString:offColor :[UIColor clearColor]];
    }
    [self.layer addSublayer:_changLayer];
    
    _moveLayer = [[myLayer alloc] init];
    if (self.defaultColors == YES)
    {
        _moveLayer.myShadowColor = [doUIModuleHelper GetColorFromString:sliderColor :[UIColor clearColor]];
        _moveLayer.myContentColor = [doUIModuleHelper GetColorFromString:sliderColor :[UIColor clearColor]];
    }
    [self.layer addSublayer:_moveLayer];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(selfViewPan:)];
    [self addGestureRecognizer:pan];
}
#pragma mark touch
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    isLongTouch = YES;
    [super touchesBegan:touches withEvent:event];
    if(isOn)
    {
        [UIView animateWithDuration:0.5 animations:^{
            _moveLayer.frame = CGRectMake(W-(H-_board)*5/4, _board/2, (H-_board)*5/4, H-_board);
            [_moveLayer setNeedsDisplay];
        } completion:^(BOOL finished) {
            NSLog(@"点击变大");
        }];
    }
    else
    {
        [UIView animateWithDuration:0.6 animations:^{
            _moveLayer.frame = CGRectMake(_board/2, _board/2, (H-_board)*5/4, H-_board);
            _changLayer.transform = CATransform3DMakeScale(0.0, 0.0, 1);
            [_moveLayer setNeedsDisplay];
        } completion:^(BOOL finished) {
            NSLog(@"点击变大");
        }];
    }
}
//解决长按，手势失效后遗留问题。touchesCancelled无效。touchesEnded有效
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    if(isLongTouch)
        [self reloadMoveLayer];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    if(isLongTouch)
        [self reloadMoveLayer];
}
- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    //    _changLayer.myContentColor = backgroundColor;
    //    _changLayer.myShadowColor = backgroundColor;
}
#pragma mark - private methed
- (void)reloadMoveLayer
{
    if(_moveLayer.frame.size.width != _moveLayer.frame.size.height && !isMoved)
    {
        [self valueChanged];
        isOn = !isOn;
    }
    
    if(isOn)
    {
        [UIView animateWithDuration:2.5 animations:^{
            _moveLayer.frame = CGRectMake(W-(H-_board)-_board/2, _board/2, H-_board, H-_board);
            _changLayer.transform = CATransform3DMakeScale(0, 0, 1);
            [self setAllLayerDisplay];
        } completion:^(BOOL finished) {
            if (self.defaultColors)
            {
                _colorLayer.myContentColor = [doUIModuleHelper GetColorFromString:onColor :[UIColor clearColor]];
                
                _colorLayer.myShadowColor =  [doUIModuleHelper GetColorFromString:onColor :[UIColor clearColor]];
            }
            [self setAllLayerDisplay];
            NSLog(@"还原 终点");
        }];
    }
    else
    {
        [UIView animateWithDuration:2.5 animations:^{
            _moveLayer.frame = CGRectMake(_board/2, _board/2, H-_board, H-_board);
            _changLayer.transform = CATransform3DMakeScale(1, 1, 1);
            [self setAllLayerDisplay];
        } completion:^(BOOL finished) {
            if (self.defaultColors)
            {
                _colorLayer.myContentColor =  [doUIModuleHelper GetColorFromString:offColor :[UIColor clearColor]];
                _colorLayer.myShadowColor = [doUIModuleHelper GetColorFromString:offColor :[UIColor clearColor]];
                
            }
            [self setAllLayerDisplay];
        }];
    }
    isMoved = NO;
    //设置属性改变
    if (isOn) {
        [_model SetPropertyValue:@"checked" :@"true"];
    }
    else
    {
        [_model SetPropertyValue:@"checked" :@"false"];
    }
}

- (void)valueChanged
{
    doInvokeResult* _invokeResult = [[doInvokeResult alloc]init:_model.UniqueKey];
    [_invokeResult SetResultBoolean:!isOn];
    [_model.EventCenter FireEvent:@"changed":_invokeResult];
}

- (void)selfViewPan:(UIPanGestureRecognizer *)pan
{
    isLongTouch = NO;
    switch (pan.state)
    {
        case UIGestureRecognizerStateBegan:
            beginPoint = [pan translationInView:self];
            break;
        case UIGestureRecognizerStateChanged:
            [self chang:[pan translationInView:self]];
            break;
        case UIGestureRecognizerStateEnded:
            [self reloadMoveLayer];
            break;
        case UIGestureRecognizerStateCancelled:
            [self reloadMoveLayer];
            break;
        default:
            [self reloadMoveLayer];
            break;
    }
}

- (void)chang:(CGPoint)newPoint
{
    if(isOn)
    {
        if(newPoint.x-beginPoint.x >= (W-H))
        {
            [UIView animateWithDuration:2.75 animations:^{
                _moveLayer.frame = CGRectMake(W-(H-_board)-_board/2, _board/2, H-_board, H-_board);
                _changLayer.transform = CATransform3DMakeScale(0, 0, 1);
            } completion:^(BOOL finished) {
                if (self.defaultColors)
                {
                    _colorLayer.myContentColor = [doUIModuleHelper GetColorFromString:onColor :[UIColor clearColor]];
                    _colorLayer.myShadowColor = [doUIModuleHelper GetColorFromString:onColor :[UIColor clearColor]];
                }
                [self setAllLayerDisplay];
            }];
        }
        else if(beginPoint.x-newPoint.x >= (W-H))
        {
            [UIView animateWithDuration:1.25 animations:^{
                _moveLayer.frame = CGRectMake(_board/2, _board/2, (H-_board)*5/4, H-_board);
            } completion:^(BOOL finished) {
                if (self.defaultColors)
                {
                    _colorLayer.myContentColor = [doUIModuleHelper GetColorFromString:offColor :[UIColor clearColor]];
                    
                    _colorLayer.myShadowColor = [doUIModuleHelper GetColorFromString:offColor :[UIColor clearColor]];
                }
                [self setAllLayerDisplay];
                beginPoint = newPoint;
                isOn = !isOn;
                [self valueChanged];
            }];
            isMoved = YES;
        }
        else
        {
            NSLog(@"不处理!");
        }
    }
    else
    {
        if(beginPoint.x-newPoint.x >= (W-H))
        {
            [UIView animateWithDuration:2.75 animations:^{
                _moveLayer.frame = CGRectMake(_board/2, _board/2, H-_board, H-_board);
                _changLayer.transform = CATransform3DMakeScale(1, 1, 1);
            } completion:^(BOOL finished) {
                if (self.defaultColors)
                {
                    _colorLayer.myContentColor =[doUIModuleHelper GetColorFromString:offColor :[UIColor clearColor]];
                    
                    _colorLayer.myShadowColor = [doUIModuleHelper GetColorFromString:offColor :[UIColor clearColor]];
                }
                [self setAllLayerDisplay];
            }];
        }
        else if(newPoint.x-beginPoint.x >= (W-H))
        {
            [UIView animateWithDuration:1.25 animations:^{
                _moveLayer.frame = CGRectMake(W-(H-_board)*5/4, _board/2, (H-_board)*5/4, H-_board);
            } completion:^(BOOL finished) {
                if (self.defaultColors)
                {
                    _colorLayer.myContentColor =[doUIModuleHelper GetColorFromString:onColor :[UIColor clearColor]];
                    
                    _colorLayer.myShadowColor = [doUIModuleHelper GetColorFromString:onColor :[UIColor clearColor]];
                    
                }
                [self setAllLayerDisplay];
                beginPoint = newPoint;
                isOn = !isOn;
                [self valueChanged];
            }];
            isMoved = YES;
        }
        else
        {
            NSLog(@"不处理!");
        }
    }
}
- (void)setAllLayerDisplay
{
    [_changLayer setNeedsDisplay];
    [_moveLayer setNeedsDisplay];
    [_colorLayer setNeedsDisplay];
}

//销毁所有的全局对象
- (void) OnDispose
{
    _model = nil;
    //自定义的全局属性
    [_colorLayer removeFromSuperlayer];
    _colorLayer = nil;
    
    [_moveLayer removeFromSuperlayer];
    _moveLayer = nil;
    
    [_changLayer removeFromSuperlayer];
    _changLayer = nil;
}
//实现布局
- (void) OnRedraw
{
    //重新调整视图的x,y,w,h
    [doUIModuleHelper OnRedraw:_model];
    //实现布局相关的修改
    if(self.frame.size.width > self.frame.size.height)
    {
        isNormal = YES;
        W = self.frame.size.width;
        H = self.frame.size.height;
    }
    else
    {
        isNormal = YES;
        W = self.frame.size.height;
        H = self.frame.size.width;
    }
    _board = W/30;
    _colorLayer.board = _board;
    _changLayer.board = _board;
    _moveLayer.board = _board/2;
    _colorLayer.frame = CGRectMake(0, 0, W, H);
    if(!isOn)
    {
        _changLayer.frame = CGRectMake(0, 0, W, H);
        _moveLayer.frame = CGRectMake(_board/2, _board/2, H-_board, H-_board);
    }
    else
    {
        _changLayer.transform = CATransform3DMakeScale(1, 1, 1);
        _changLayer.frame = CGRectMake(0, 0, W, H);
        _changLayer.transform = CATransform3DMakeScale(0, 0, 1);
        _moveLayer.frame = CGRectMake(W-(H-_board)-_board/2, _board/2, H-_board, H-_board);
    }
    [self setAllLayerDisplay];
}

#pragma mark - TYPEID_IView协议方法（必须）
#pragma mark - Changed_属性
/*
 如果在Model及父类中注册过 "属性"，可用这种方法获取
 NSString *属性名 = [(doUIModule *)_model GetPropertyValue:@"属性名"];
 
 获取属性最初的默认值
 NSString *属性名 = [(doUIModule *)_model GetProperty:@"属性名"].DefaultValue;
 */
- (void)change_checked:(NSString *)newValue
{
    //自己的代码实现
    if([newValue isEqualToString:@"true"] || [newValue isEqualToString:@"1"])
        isOn = YES;
    else
        isOn = NO;
    [self reloadMoveLayer];
}

- (void)change_shape:(NSString *)newValue
{
    [myLayer setShapeValue:newValue];
}

- (void)change_colors:(NSString *)newValue
{
    NSArray *colorsArray;
    if (newValue != nil && [newValue length] > 0 && ![newValue isEqualToString:defaultColorsString])
    {
        self.defaultColors = NO;
        colorsArray = [newValue componentsSeparatedByString:@","];
        if (colorsArray.count == 3)
        {
            _colorLayer.myContentColor = [doUIModuleHelper GetColorFromString:[colorsArray objectAtIndex:0] :[UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:1]];
            _colorLayer.myShadowColor = [doUIModuleHelper GetColorFromString:[colorsArray objectAtIndex:0] :[UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:1]];
            _changLayer.myContentColor = [doUIModuleHelper GetColorFromString:[colorsArray objectAtIndex:1] :[UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:1]];
            _changLayer.myShadowColor = [doUIModuleHelper GetColorFromString:[colorsArray objectAtIndex:1] :[UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:1]];
            _moveLayer.myContentColor = [doUIModuleHelper GetColorFromString:[colorsArray objectAtIndex:2] :[UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:1]];
            _moveLayer.myShadowColor = [doUIModuleHelper GetColorFromString:[colorsArray objectAtIndex:2] :[UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:1]];
        }
        else if(colorsArray.count == 2)
        {
            _colorLayer.myContentColor = [doUIModuleHelper GetColorFromString:[colorsArray objectAtIndex:0] :[UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:1]];
            _colorLayer.myShadowColor = [doUIModuleHelper GetColorFromString:[colorsArray objectAtIndex:0] :[UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:1]];
            _changLayer.myContentColor = [doUIModuleHelper GetColorFromString:[colorsArray objectAtIndex:1] :[UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:1]];
            _changLayer.myShadowColor = [doUIModuleHelper GetColorFromString:[colorsArray objectAtIndex:1] :[UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:1]];
            _moveLayer.myContentColor = [doUIModuleHelper GetColorFromString:[colorsArray objectAtIndex:2] :[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1]];
            _moveLayer.myShadowColor = [doUIModuleHelper GetColorFromString:[colorsArray objectAtIndex:2] :[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1]];
            
        }
        else
        {
            _colorLayer.myContentColor = [doUIModuleHelper GetColorFromString:[colorsArray objectAtIndex:0] :[UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:1]];
            _colorLayer.myShadowColor = [doUIModuleHelper GetColorFromString:[colorsArray objectAtIndex:0] :[UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:1]];
            _changLayer.myContentColor = [doUIModuleHelper GetColorFromString:[colorsArray objectAtIndex:1] :[UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1]];
            _changLayer.myShadowColor = [doUIModuleHelper GetColorFromString:[colorsArray objectAtIndex:1] :[UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1]];
            _moveLayer.myContentColor = [doUIModuleHelper GetColorFromString:[colorsArray objectAtIndex:2] :[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1]];
            _moveLayer.myShadowColor = [doUIModuleHelper GetColorFromString:[colorsArray objectAtIndex:2] :[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1]];
        }
        
    }
    else
    {
        self.defaultColors = YES;
        _colorLayer.myContentColor = [doUIModuleHelper GetColorFromString:[colorsArray objectAtIndex:0] :[UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:1]];
        _colorLayer.myShadowColor = [doUIModuleHelper GetColorFromString:[colorsArray objectAtIndex:0] :[UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:1]];
        _changLayer.myContentColor = [doUIModuleHelper GetColorFromString:[colorsArray objectAtIndex:1] :[UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1]];
        _changLayer.myShadowColor = [doUIModuleHelper GetColorFromString:[colorsArray objectAtIndex:1] :[UIColor colorWithRed:136/255.0 green:136/255.0 blue:136/255.0 alpha:1]];
        _moveLayer.myContentColor = [doUIModuleHelper GetColorFromString:[colorsArray objectAtIndex:2] :[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1]];
        _moveLayer.myShadowColor = [doUIModuleHelper GetColorFromString:[colorsArray objectAtIndex:2] :[UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1]];    }
    [self reloadMoveLayer];
}



#pragma mark - doIUIModuleView协议方法（必须）<大部分情况不需修改>
- (BOOL) OnPropertiesChanging: (NSMutableDictionary *) _changedValues
{
    //属性改变时,返回NO，将不会执行Changed方法
    return YES;
}
- (void) OnPropertiesChanged: (NSMutableDictionary*) _changedValues
{
    //_model的属性进行修改，同时调用self的对应的属性方法，修改视图
    [doUIModuleHelper HandleViewProperChanged: self :_model : _changedValues ];
}
- (BOOL) InvokeSyncMethod: (NSString *) _methodName : (NSDictionary *)_dicParas :(id<doIScriptEngine>)_scriptEngine : (doInvokeResult *) _invokeResult
{
    //同步消息
    return [doScriptEngineHelper InvokeSyncSelector:self : _methodName :_dicParas :_scriptEngine :_invokeResult];
}
- (BOOL) InvokeAsyncMethod: (NSString *) _methodName : (NSDictionary *) _dicParas :(id<doIScriptEngine>) _scriptEngine : (NSString *) _callbackFuncName
{
    //异步消息
    return [doScriptEngineHelper InvokeASyncSelector:self : _methodName :_dicParas :_scriptEngine: _callbackFuncName];
}
- (doUIModule *) GetModel
{
    //获取model对象
    return _model;
}

@end




//自定义layer，用于显示。
@implementation myLayer
NSString *_shape;
+ (void)setShapeValue:(NSString *)newValue
{
    if (newValue != nil && newValue.length > 0)
    {
        _shape = newValue;
    }
    else
    {
        _shape = defaultShape;
    }
}

- (void)drawInContext:(CGContextRef)context
{
    //设置曲线
    UIBezierPath *bezierPath;
    if ([_shape isEqualToString:@"rect"])
    {
        bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) cornerRadius:0];
        
    }
    else
    {
        bezierPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height) cornerRadius:self.bounds.size.height/2.0];
    }
    CGContextAddPath(context, bezierPath.CGPath);
    CGContextClip(context);
    //内容上色
    CGContextSetFillColorWithColor(context, self.myShadowColor.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height));
    
    UIBezierPath *bezierPath1;
    if ([_shape isEqualToString:@"rect"])
    {
        bezierPath1 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.board, self.board, self.bounds.size.width-2*self.board, self.bounds.size.height-2*self.board) cornerRadius:0];
    }
    
    else
    {
        bezierPath1 = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.board, self.board, self.bounds.size.width-2*self.board, self.bounds.size.height-2*self.board) cornerRadius:self.bounds.size.height/2.0];
    }
    CGContextAddPath(context, bezierPath1.CGPath);
    CGContextClip(context);
    //内容上色
    CGContextSetFillColorWithColor(context, self.myContentColor.CGColor);
    CGContextFillRect(context, CGRectMake(self.board, self.board, self.bounds.size.width-2*self.board, self.bounds.size.height-2*self.board));
    
    //UIGraphicsPushContext(context);
    UIGraphicsPopContext();
}
@end
