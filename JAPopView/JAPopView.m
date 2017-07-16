//
//  JAPopView.m
//  Daily_ui_objc_set
//
//  Created by Jason on 04/01/2017.
//  Copyright © 2017 Jason. All rights reserved.
//


#import "JAPopView.h"
#import <objc/message.h>

// 布局frame相关

/// 弹窗宽度
CGFloat popViewWidth = 280;

/// 内容视图高度
CGFloat popViewContentHeight = 100;

/// 弹窗上间距
CGFloat popViewTop = 230;

/// 弹窗最小上间距
CGFloat popViewMinTop = 64;

/// 按钮间隔
const CGFloat distanceInButton = 10;

/// 按钮左右间距
const CGFloat distanceLR = 18;

/// 按钮上下间距
const CGFloat distanceTB = 8;

/// 最底部的按钮离控件的距离
const CGFloat distanceBottom = 15;

/// 最顶部的按钮离控件的距离 - 与``distanceBottom``互斥
const CGFloat distanceTop = 25;

/// 按钮统一的高度
const CGFloat buttonHeight = 45;

/// 保存在类中,保证只有一个弹窗
static const char *exclusvieViewKey = "exclusvieViewKey";

/**
 弹窗按钮
 1.包含一个block,用于处理点击事件
 2.定义了默认的确定,取消,执行按钮的样式
 */
@interface JAPopViewButton : UIButton
@property (nonatomic,copy) void (^handler)(JAPopViewButton *);

+ (instancetype)ensureButtonWithTitle:(NSString *)title;
+ (instancetype)cancelButtonWithTtitle:(NSString *)title;
+ (instancetype)execButtonWithTitle:(NSString *)title;

@end

@implementation JAPopViewButton

// 比橙色深一些 + 白色文字
+ (instancetype)ensureButtonWithTitle:(NSString *)title {
    JAPopViewButton *btn = [[JAPopViewButton alloc] init];
    // 若对默认的样式不满意
    // DRPartnerPopView actionWithTitle:style:handler:会返回按钮,在外面修改
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.backgroundColor = [JAPopViewButton colorWithHexRGB:0xffaf15];
    [self modifiedWithButton:btn];
    return btn;
}

// 浅灰色底色 + 白色文字
+ (instancetype)cancelButtonWithTtitle:(NSString *)title {
    JAPopViewButton *btn = [[JAPopViewButton alloc] init];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.backgroundColor = [JAPopViewButton colorWithHexRGB:0xcccccc];
    [self modifiedWithButton:btn];
    return btn;
}

// 橙色底色 + 白色文字
+ (instancetype)execButtonWithTitle:(NSString *)title {
    JAPopViewButton *btn = [[JAPopViewButton alloc] init];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.backgroundColor = [JAPopViewButton colorWithHexRGB:0xffb75c];
    [self modifiedWithButton:btn];
    return btn;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha -= 0.2;
    } completion:^(BOOL finished) {
        self.alpha += 0.2;
    }];
}

/**
 公共属性的设置
 
 @param sender 按钮对象
 */
+ (void)modifiedWithButton:(JAPopViewButton *)sender {
    sender.layer.cornerRadius = 5;
    sender.layer.masksToBounds = true;
}

+ (UIColor *)colorWithHexRGB:(NSInteger)rgbValue {
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue &0xFF00) >> 8))/255.0 blue:((float)(rgbValue &0xFF))/255.0 alpha:1.0];
}
@end

@interface JAPopView ()

/**
 遮罩层
 */
@property (nonatomic,strong) UIView *coverView;

/**
 内容视图
 */
@property (nonatomic,strong) UIView *cView;

/**
 弹窗类型
 */
@property (nonatomic) JAPopViewType type;

/**
 不同类型包含的button的数量
 */
@property (nonatomic) CGFloat containBtnsCount;

/**
 视图底部的按钮集合
 */
@property (nonatomic,strong) NSMutableArray <JAPopViewButton *>* containBtns;

/**
 内容视图的高度 - 整个视图的高度等于内容视图的高度(随内容浮动) + 底部视图的高度(随样式浮动)
 */
@property (nonatomic) CGFloat cHeight;

@end

@implementation JAPopView

+ (instancetype)popViewWithType:(JAPopViewType)type {
    JAPopView *popView = [[JAPopView alloc] init];
    [popView commonInitWithPopView:popView type:type];
    [popView calculateFrameWithType:type];
    return popView;
}

- (void)setDelegate:(id<JAPopViewDelegate>)delegate {
    _delegate = delegate;
    [self allCheckerDataSource];
    
    self.cView = [delegate popViewProviderContent:self];
    self.cHeight = self.cView.frame.size.height;
    
    [self calculateFrameWithType:_type];
    [self addSubview:self.cView];
}

- (void)setTopDistance:(CGFloat)topDistance {
    _topDistance = topDistance;
    CGRect frame = self.frame;
    frame.origin.y = _topDistance;
    self.frame = frame;
}

+ (instancetype)popViewWithType:(JAPopViewType)type
                       delegate:(id<JAPopViewDelegate>)delegate{
    
    JAPopView *popView = [[JAPopView alloc] init];
    [popView commonInitWithPopView:popView type:type];
    
    popView.delegate = delegate;
    
    return popView;
}

- (void)commonInitWithPopView:(JAPopView *)popView type:(JAPopViewType)type{
    
    JAPopView *exclusvieView = objc_getAssociatedObject([self class], exclusvieViewKey);
    if (exclusvieView) {
        [exclusvieView animateWithShowStatus:false duration:0];
    }
    
    popView.backgroundColor = [UIColor whiteColor];
    popView.noLocked = true;
    popView.layer.cornerRadius = 5;
    popView.layer.masksToBounds = true;
    popView.type = type;
    
    // 根据类型限制按钮数量
    NSDictionary *btnsCountDic = @{
                                    @(JAPopViewTypeSingle):@(1),
                                    @(JAPopViewTypeAverage):@(2),
                                    @(JAPopViewTypeThreeMouth):@(3),
                                    @(JAPopViewTypeAlignHorizontal):@(999),
                                    @(JAPopViewTypeNone):@0
                                 };
    
    NSNumber *countsNumber = btnsCountDic[@(type)];
    popView.containBtnsCount = [countsNumber integerValue];
}

- (UIButton *)actionWithTitle:(NSString *)title
                        style:(JAPopViewActionStyle)style
                      handler:(void (^)(UIButton *))handler {
    
    JAPopViewButton *btn = nil;
    
    switch (style) {
        case JAPopViewActionStyleEnsure:
            btn = [JAPopViewButton ensureButtonWithTitle:title];
            break;
        case JAPopViewActionStyleExec:
            btn = [JAPopViewButton execButtonWithTitle:title];
            break;
        case JAPopViewActionStyleCancel:
            btn = [JAPopViewButton cancelButtonWithTtitle:title];
            break;
        default:btn = [JAPopViewButton execButtonWithTitle:title];
            break;
    }
    
    btn.handler = handler;
    [btn addTarget:self action:@selector(clickEventButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.containBtns addObject:btn];
    
    return btn;
}

- (void)addAction:(UIButton *)sender {
    // 当前已包含的按钮数量应不超过样式可允许的按钮数量
    NSAssert(_containBtns.count <= _containBtnsCount, @"当前已包含的按钮数量应不超过样式可允许的按钮数量");
    
    [self addSubview:sender];
}

- (void)refreshWithContentViewFrame:(CGRect)frame {
    self.cHeight = frame.size.height;
    [self calculateFrameWithType:self.type];
}

- (void)calculateFrameWithType:(JAPopViewType)type {
    
    // 弹窗
    CGFloat popW = popViewWidth;
    CGFloat popH = 0;
    CGFloat popTopY = 0;

    // 底部视图只有一行时的高度为85个点
    if (type == JAPopViewTypeSingle || type == JAPopViewTypeAverage) {
        popH = (self.cHeight == 0 ? 100 : self.cHeight) + 85;
        popTopY = popViewTop < popViewMinTop ? popViewMinTop : popViewTop;
    }else if (type == JAPopViewTypeThreeMouth) {
        // 两行
        popH = (self.cHeight == 0 ? 100 : self.cHeight) + 140;
        popViewTop = 150;
        popTopY = popViewTop < popViewMinTop ? popViewMinTop : popViewTop;
    }else if (type == JAPopViewTypeAlignHorizontal){
        // 水平一行,高度不限 在这无法知道加了几个按钮,不能在这里计算 设底部高度为0
        popH = self.cHeight == 0 ? 100 : self.cHeight;
        popViewTop = 150;
        popTopY = popViewTop < popViewMinTop ? popViewMinTop : popViewTop;
    }else {
        popH = self.cHeight == 0 ? 100 : self.cHeight;
        popViewTop = 150;
        popTopY = popViewTop < popViewMinTop ? popViewMinTop : popViewTop;
    }

    if (self.topDistance != 0) {
        popTopY = self.topDistance;
    }
    
    CGFloat popX = ([UIScreen mainScreen].bounds.size.width - popW) * 0.5;
    CGFloat popY = popTopY;
    CGRect popFrame = CGRectMake(popX, popY, popW, popH);
    self.frame = popFrame;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 移动遮罩层
    [[self superview] addSubview:self.coverView];
    [[self superview] bringSubviewToFront:self];
    
    switch (self.type) {
        case JAPopViewTypeSingle:
            [self layoutSingleView];
            break;
            
        case JAPopViewTypeAverage:
            [self layoutAverageView];
            break;
            
        case JAPopViewTypeThreeMouth:
            [self layoutThreeMouthView];
            break;
            
        case JAPopViewTypeAlignHorizontal:
            [self layoutAlignHorizontal];
            break;
        case JAPopViewTypeNone:{
#if DEBUG
            NSLog(@"你啥也不用做");
#endif
        }
            break;
        default: [self layoutSingleView];
            break;
    }
}

- (void)layoutSingleView {
    
    NSAssert(self.containBtns.count == 1, @"当前样式应包含1个按钮");
    
    // 确定按钮
    JAPopViewButton *btn = self.containBtns.firstObject;
    CGFloat ensureW = self.frame.size.width - distanceLR * 2;
    CGFloat ensureH = buttonHeight;
    CGFloat ensureX = (self.frame.size.width - ensureW) * 0.5;
    CGFloat ensureY = self.frame.size.height - ensureH - distanceBottom; // 距底部15
    btn.frame = CGRectMake(ensureX, ensureY, ensureW, ensureH);
}

- (void)layoutAverageView {
    NSAssert(self.containBtns.count == 2, @"当前样式应包含2个按钮");
    
    JAPopViewButton *lBtn = self.containBtns.firstObject;
    CGFloat lBtnW = (self.frame.size.width - distanceLR * 2 - distanceInButton) * 0.5;
    CGFloat lBtnH = buttonHeight;
    CGFloat lBtnX = distanceLR;
    CGFloat lBtnY = self.frame.size.height - lBtnH - distanceBottom; // 距底部15
    lBtn.frame = CGRectMake(lBtnX, lBtnY, lBtnW, lBtnH);
    
    JAPopViewButton *rBtn = self.containBtns.lastObject;
    CGFloat rBtnW = lBtnW;
    CGFloat rBtnH = lBtnH;
    CGFloat rBtnX = lBtnX + lBtnW + distanceInButton;
    CGFloat rBtnY = lBtnY;
    rBtn.frame = CGRectMake(rBtnX, rBtnY, rBtnW, rBtnH);
}

- (void)layoutThreeMouthView {
    
    NSAssert(self.containBtns.count == 3, @"当前样式应包含3个按钮");
    
    JAPopViewButton *btn = self.containBtns[0];
    CGFloat ensureW = self.frame.size.width - distanceLR * 2;
    CGFloat ensureH = buttonHeight;
    CGFloat ensureX = (self.frame.size.width - ensureW) * 0.5;
    CGFloat ensureY = self.frame.size.height - ensureH - distanceBottom - distanceTB - buttonHeight;
    btn.frame = CGRectMake(ensureX, ensureY, ensureW, ensureH);
    
    JAPopViewButton *exec1Btn = self.containBtns[1];
    CGFloat exec1W = (self.frame.size.width - distanceLR * 2 - distanceInButton) * 0.5;
    CGFloat exec1H = buttonHeight;
    CGFloat exec1X = distanceLR;
    CGFloat exec1Y = self.frame.size.height - distanceBottom - buttonHeight;
    exec1Btn.frame = CGRectMake(exec1X, exec1Y, exec1W, exec1H);
    
    JAPopViewButton *exec2Btn = self.containBtns[2];
    CGFloat exec2W = exec1W;
    CGFloat exec2H = exec1H;
    CGFloat exec2X = self.frame.size.width - distanceLR - exec1W;
    CGFloat exec2Y = exec1Y;
    exec2Btn.frame = CGRectMake(exec2X, exec2Y, exec2W, exec2H);
}

- (void)layoutAlignHorizontal {
    
    NSAssert(self.containBtns.count > 0, @"至少需要添加一个按钮以实现该样式的布局");
    
    CGRect frame = self.frame;
    for (int i = 0; i < self.containBtns.count; i++) {
        JAPopViewButton *btn = self.containBtns[i];
        CGFloat btnW = self.frame.size.width - distanceLR * 2;
        CGFloat btnH = buttonHeight;
        CGFloat btnX = (self.frame.size.width - btnW) * 0.5;
        CGFloat btnY = self.cView.frame.size.height + distanceTop + i * buttonHeight + (i > 0 ? i  * distanceTB : 0);
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        
        // 在添加按钮时,根据按钮的位置(第一,最后,中间),来调整高度
        frame.size.height += (i == 0 ? (i == (self.containBtns.count -1) ? (distanceTop + buttonHeight + distanceBottom) : (buttonHeight + distanceTop)) : (i == (self.containBtns.count -1) ? (distanceBottom + distanceTB + buttonHeight) : (distanceTB + buttonHeight)));
    }
    
    // 重新设置frame;
    self.frame = frame;
}

#pragma mark - Events
- (void)clickEventButton:(JAPopViewButton *)sender {
    if(sender.handler) {
        sender.handler(sender);
    }
}

- (void)dismiss:(UITapGestureRecognizer *)tap {
    objc_setAssociatedObject([self class], exclusvieViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self animateWithShowStatus:false];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if (newSuperview) {
        [self animateWithShowStatus:true];
        objc_setAssociatedObject([self class],exclusvieViewKey, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)dismissWithBlock:(void (^)())block {
    _dismissBlock = block;
    [self dismiss:nil];
}

- (void)animateWithShowStatus:(BOOL)isShow
                     duration:(CGFloat)duration{
    
    if (isShow) {
        // 显示
        self.transform = CGAffineTransformMakeTranslation(0,[UIScreen mainScreen].bounds.size.height);
        [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveLinear animations:^{
            
            self.transform = CGAffineTransformMakeTranslation(0,0);
            
        } completion:^(BOOL finished) {
            
        }];
    }else {
        // 隐藏
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            
            self.transform = CGAffineTransformMakeTranslation(0, 800);
            self.coverView.alpha = 0;
            
        } completion:^(BOOL finished) {
            
            if (self.dismissBlock) {
                self.dismissBlock();
            }
            
            [self.coverView removeFromSuperview];
            [self removeFromSuperview];
            
        }];
    }
}

- (void)animateWithShowStatus:(BOOL)isShow {
    [self animateWithShowStatus:isShow duration:isShow ? 1.2:0.8];
}

- (void)addWindow {
    [[[UIApplication sharedApplication].delegate window] addSubview:self];
}

#pragma mark - Utils
- (void)allCheckerDataSource{
    NSError *error = nil;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    NSAssert([self checkerTarget:self.delegate
                          action:@selector(popViewProviderContent:)
                           error:&error],error.domain);
    // extra...
#pragma clang diagnostic pop
    
}

- (BOOL)checkerTarget:(id)obj
               action:(SEL)sel
                error:(NSError **)err{
    *err = [NSError errorWithDomain:[NSString stringWithFormat:@"You must implement the %p function",sel]
                               code:-99
                           userInfo:@{}];
    return [self.delegate respondsToSelector:sel];
}

#pragma mark - 懒加载
- (UIView *)coverView {
    if (_coverView == nil) {
        _coverView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _coverView.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.5];
        if (self.noLocked) {
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
            [_coverView addGestureRecognizer:tap];
        }
        
    }
    return _coverView;
}

- (NSMutableArray<JAPopViewButton *> *)containBtns {
    if (_containBtns == nil) {
        _containBtns = [NSMutableArray array];
    }
    return _containBtns;
}

@end
