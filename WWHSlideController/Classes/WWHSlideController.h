//
//  WWHSlideController.h
//  Pods
//
//  Created by Wu on 16/5/4.
//
//

#import <UIKit/UIKit.h>

@protocol WWHSlideControllerDelegate ;

typedef void(^CallBackBlock)(void);

/**
 *  选择打开哪边菜单栏
 */
typedef NS_ENUM(NSInteger , WWHSlideSide) {
    /**
     *  两边都不打开
     */
    WWHSlideSideNone,
    /**
     *  打开左边菜单栏
     */
    WWHSlideSideLeft = 1,
    /**
     *  打开右边菜单栏
     */
    WWHSlideSideRight = 1 << 1,
};

/**
 *  菜单栏的状态[三个静态状态，七个动态状态]
 */
typedef NS_ENUM(NSInteger,WWHSlideDynamicState) {
    /**
     *  home
     */
    WWHSlideDynamicStateHome,
    /**
     *  展示左边菜单栏
     */
    WWHSlideDynamicStateHomeToLeft,
    /**
     *  由左边状态到home
     */
    WWHSlideDynamicStateLeftToHome,
    /**
     *  展示右边菜单栏
     */
    WWHSlideDynamicStateHomeToRight,
    /**
     *  由右边状态到home
     */
    WWHSlideDynamicStateRightToHome,
    /**
     *  动态展示LeftMenu
     */
    WWHSlideDynamicStateLeft,
    /**
     *  动态展示RightMenu
     */
    WWHSlideDynamicStateRight,
    
    WWHSlideDynamicStateUnkind,
};

/**
 *  菜单栏的状态[三个静态状态，七个动态状态]
 */
typedef NS_ENUM(NSInteger,WWHSlideStaticState) {
    /**
     *  home
     */
    WWHSlideStaticStateHome,
    /**
     *  展示LeftMenu
     */
    WWHSlideStaticStateLeft,
    /**
     *  展示RightMenu
     */
    WWHSlideStaticStateRight,
};

@interface WWHSlideController : UINavigationController

@property(nonatomic , strong)UIImage *backgroundImage;
@property(nonatomic , strong)UIColor *backgroundColor;

@property(nonatomic , weak) id<WWHSlideControllerDelegate> slideDelegate;
/**
 *  读取当前哪边菜单容许打开
 */
@property(nonatomic , assign, readonly) WWHSlideSide openSide;
/**
 *  是否支持滑动手势，默认是NO
 */
@property(nonatomic , assign)BOOL enablePanGuesture;
/**
 *  是否支持阴影效果，默认是NO
 */
@property(nonatomic , assign)BOOL enableShadow;
@property(nonatomic , assign)BOOL menuScaleEnabled;
@property(nonatomic , assign)BOOL homeScaleEnabled;

/**
 *  homeView停靠偏移量，默认是60
 */
@property(nonatomic, assign)CGFloat anchorOffset;
/**
 *  menu偏移量，默认是0
 */
@property(nonatomic , assign)CGFloat menuOffset;

/**
 *  滑动过程中ABS(curMoveX／maxMoveX)
 */
@property(nonatomic , assign , readonly)CGFloat zoomFactor;

/**
 *  初始化侧滑框架
 *
 *  @param rootViewController  homeVC
 *  @param leftViewController  leftVC
 *  @param rightViewController rightVC
 */
- (id)initWithRootViewController:(UIViewController *)rootViewController leftViewController:(UIViewController *)leftViewController rightViewController:(UIViewController *)rightViewController;
/**
 *  跟换home
 *
 *  @param homeVC   用于跟换的home
 *  @param flag     是否关闭菜单栏
 *  @param complete 完成回调
 */
- (void)changeHome:(UIViewController *)homeVC needCloseSide:(BOOL)flag complete:(CallBackBlock)complete;

/**
 *  展示 ｜ 隐藏左边菜单栏
 *
 *  @param animated 是否有动画效果
 */
- (void)tapShowOrHideLeftAnimated;

/**
 *  展示 ｜ 隐藏右边菜单栏
 *
 *  @param animated 是否有动画效果
 */
- (void)tapShowOrHideRightAnimated;

@end

/**
 *  动态生成属性
 */
@interface UIViewController (Slide)
/**
 *  实例
 */
@property (nonatomic, strong) WWHSlideController *slideController;
/**
 *  支持哪边菜单栏打开，需要home重写，默认是双边
 *
 *  @return WWHSlideSide枚举类型
 */
- (WWHSlideSide)supportedSlideSide;
@end


@protocol WWHSlideControllerDelegate <NSObject>
@optional
- (void)slideController:(WWHSlideController *)slideController scrollingToOffset:(CGFloat)offset;
/**
 *  需要同步到动画中去的操作（比如说在滑动过程中需要修改home的view的透明度）
 *
 *  @param slideController WWHSlideController实例
 *  @param block           _staticState为home时，操作的状态
 *  @param block           _staticState为left时，操作的状态
 *  @param block           _staticState为right时，操作的状态
 */
- (void)slideController:(WWHSlideController *)slideController SynchronizationInScrollingAnimationHomeState:(CallBackBlock)block LeftState:(CallBackBlock)block RightState:(CallBackBlock)block;

- (void)slideControllerScrollingShowMenu:(WWHSlideController *)slideController;

- (void)slideControllerScrollingBackHome:(WWHSlideController *)slideController;

/**
 *  左边menu完全展示后的操作
 *
 *  @param slideController WWHSlideController实例
 */
- (void)slideControllerDidShowLeftMenu:(WWHSlideController *)slideController;

- (void)slideControllerDidShowRightMenu:(WWHSlideController *)slideController;

- (void)slideControllerDidHome:(WWHSlideController *)slideController;
@end
