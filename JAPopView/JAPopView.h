//
//  JAPopView.h
//  Daily_ui_objc_set
//
//  Created by Jason on 04/01/2017.
//  Copyright © 2017 Jason. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 弹窗视图默认宽度 280
UIKIT_EXTERN CGFloat popViewWidth;

// 弹窗视图的内容视图默认高度 100
UIKIT_EXTERN CGFloat popViewContentHeight;

// 弹窗视图默认距离父视图顶部 230(按钮1行) 150(按钮2行)
UIKIT_EXTERN CGFloat popViewTop;

// 弹窗最小上间距 默认64
UIKIT_EXTERN CGFloat popViewMinTop;

typedef NS_ENUM(NSUInteger,JAPopViewType){
    JAPopViewTypeSingle,    // 只有一个单选框
    JAPopViewTypeAverage,   // 确定与取消左右各一个
    JAPopViewTypeThreeMouth,// 品字型,上面一个下面两个,上下等宽
    JAPopViewTypeAlignHorizontal,  // 每行一个,水平对齐,数量不限
    JAPopViewTypeNone,      // 没有按钮,只做展示用
};

typedef NS_ENUM(NSUInteger,JAPopViewActionStyle){
    JAPopViewActionStyleEnsure,  // 确认类型的按钮
    JAPopViewActionStyleCancel,   // 取消类型的按钮
    JAPopViewActionStyleExec,    // 执行某一操作的按钮
};

@class JAPopView;

@protocol JAPopViewDelegate <NSObject>

@required
/**
 负责提供上半部分的视图对象
 
 @param popView DRPartnerPopView视图对象
 @return 上半部份的视图对象
 */
- (UIView *)popViewProviderContent:(JAPopView *)popView;

@end

@interface JAPopView : UIView

/**
 点击周围区域,弹窗消失(默认true)
 */
@property (nonatomic) BOOL noLocked;


/**
 消失时的回调
 */
@property (nonatomic,copy) void (^dismissBlock)() ;

/**
 内容视图
 */
@property (nonatomic,strong,readonly) UIView *cView;

/**
 距离父视图顶部的距离
 */
@property (nonatomic) CGFloat topDistance;

/**
 代理对象
 */
@property (nonatomic,weak) id<JAPopViewDelegate> delegate;

+ (instancetype)popViewWithType:(JAPopViewType)type;

+ (instancetype)popViewWithType:(JAPopViewType)type
                       delegate:(id<JAPopViewDelegate>)delegate;


/**
 创建要添加到视图中的按钮对象
 若要自定义按钮的样式,请在执行该方法后对button对象进行修改
 
 @param title 内容
 @param style 样式
 @param handler 点击按钮执行的事件
 @return 按钮对象
 */
- (UIButton *)actionWithTitle:(NSString *)title
                        style:(JAPopViewActionStyle)style
                      handler:(void (^)(UIButton *btn))handler;

/**
 添加按钮到视图中
 初始化创建的视图类型会对能添加的按钮数量进行限制
 @param sender 按钮对象
 */
- (void)addAction:(UIButton *)sender;

/**
 根据内容视图重新刷新frame
 
 @param frame 内容视图的frame
 */
- (void)refreshWithContentViewFrame:(CGRect)frame;

/**
 添加到应用代理对象的window上
 */
- (void)addWindow;

/**
 弹窗消失

 @param block 弹窗消失后的回调
 */
- (void)dismissWithBlock:(void (^)())block;

@end

NS_ASSUME_NONNULL_END
