//
//  WWHSlideController.m
//  Pods
//
//  Created by Wu on 16/5/4.
//
//

#import "WWHSlideController.h"
#import <objc/runtime.h>

#define SelfViewWidth [UIScreen mainScreen].bounds.size.width
#define SelfViewFrame [UIScreen mainScreen].bounds
/**
 *  滑动过程中home和menu的缩放比例
 */
struct WWHSlideScale {
    /**
     *  home缩放比
     */
    CGFloat WWHSlideScaleHomeShowMenu;
    CGFloat WWHSlideScaleHomeHiddenMenu;
    /**
     *  menu缩放比
     */
    CGFloat WWHSlideScaleMenuShow;
    CGFloat WWHSlideScaleMenuHideen;
};

typedef struct WWHSlideScale WWHSlideScale;

typedef NS_ENUM(NSInteger,WWHSlideShadowDerection) {
    WWHSlideShadowDerectionLeft = -1,
    WWHSlideShadowDerectionRight = 1,
};

@interface WWHSlideController ()
{
    WWHSlideDynamicState _dynamicState;
    WWHSlideStaticState _staticState;
    UIPanGestureRecognizer *_pan;
    UITapGestureRecognizer *_tap;
    CGFloat _maxSlideRightX;
    CGFloat _minSlideleftX;
    CGFloat _curMoveX;
    UIImageView *_backgroundImageView;
    
//    CallBackBlock _SyncHomeBlock;
//    CallBackBlock _SyncLeftBlock;
//    CallBackBlock _SyncRightBlock;
}

@property(nonatomic , assign)CGFloat maxMoveX;
@property(nonatomic , assign)CGFloat maxScale;
/**
 *  用于控制左边菜单栏的VC
 */
@property(nonatomic , strong) UIViewController *leftViewController;
/**
 *  用于控制右边菜单栏的VC
 */
@property(nonatomic , strong) UIViewController *rightViewController;
@end

@implementation WWHSlideController
- (void)viewDidLoad {
    [super viewDidLoad];
    _pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handelPan:)];
    [self.view addGestureRecognizer:_pan];
    _tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handelTap:)];
    [self.view addGestureRecognizer:_tap];
    
    _backgroundImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    _backgroundImageView.backgroundColor = [UIColor blackColor];
    
//    _SyncHomeBlock();
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.view.superview insertSubview:self.leftViewController.view belowSubview:self.view];
    [self.view.superview insertSubview:self.rightViewController.view belowSubview:self.view];
    [self.view.superview insertSubview:_backgroundImageView belowSubview:self.view];
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
              leftViewController:(UIViewController *)leftViewController
             rightViewController:(UIViewController *)rightViewController {
    self = [super initWithRootViewController:rootViewController];
    
    if (self) {
        self.leftViewController = leftViewController;
        self.rightViewController = rightViewController;
        //默认设置
        self.anchorOffset = 60;
        self.menuOffset = 0;
        self.enablePanGuesture = NO;
        self.enableShadow = NO;
        _staticState = WWHSlideStaticStateHome;
        _dynamicState = WWHSlideDynamicStateHome;
        _homeScaleEnabled = NO;
        _menuScaleEnabled = NO;

        [self supportedSlideSide];
    }
    return self;
}
/**
 *  判断home是否实现了supportedSlideSide方法，如果实现了就返回其设定的值，否则返回None
 */
- (WWHSlideSide)supportSide {
    if ([self.topViewController respondsToSelector:@selector(supportedSlideSide)]) {
        UIViewController *topVC = (UIViewController*)self.topViewController;
        return [topVC supportedSlideSide];
    }
    return WWHSlideSideNone;
}
#pragma mark- pan
- (void)handelPan:(UIPanGestureRecognizer *)sender {
    CGFloat curMoveX = [self limitWithMoveX:[_pan translationInView:self.view].x];
    [self showShadowWithSlideDynamicState:[self getSlideDynamicStateWithMoveX:curMoveX]];
    [self chooseMenuViewWithSlideDynamicState:[self getSlideDynamicStateWithMoveX:curMoveX]];
    [self dynamicShowWithMoveX:curMoveX dynamicState:[self getSlideDynamicStateWithMoveX:curMoveX]];
    
    if (_pan.state == UIGestureRecognizerStateEnded) {
        [self staticShowWithStaticState:[self gteSlideStaticStateWithFrameX:self.view.frame.origin.x]];
    }
}
#pragma mark panning
//限制手势滑动距离的范围
- (CGFloat)limitWithMoveX:(CGFloat)curMoveX {
    CGFloat cur;
    if (curMoveX > 0) {
        cur = MIN(curMoveX, self.maxMoveX);
    }
    else {
        cur = MAX(curMoveX, -self.maxMoveX);
    }
    _curMoveX = cur;
    return cur;
}
/**
 *  根据手势开启之前的静态状态来决定动态状态
 *
 *  @param curMoveX 手势移动的距离（经过范围限制处理的）
 *
 *  @return 当前的动态状态
 */
- (WWHSlideDynamicState)getSlideDynamicStateWithMoveX:(CGFloat)curMoveX {
    WWHSlideDynamicState state = 100;
    switch (_staticState) {
        case WWHSlideStaticStateHome:
        {
            if (curMoveX > 0 && ([self supportSide] & WWHSlideSideLeft)) {
                state = WWHSlideDynamicStateHomeToLeft;
            }
            else if (curMoveX < 0 && ([self supportSide] & WWHSlideSideRight)){
                state = WWHSlideDynamicStateHomeToRight;
            } else {
                state = WWHSlideDynamicStateHome;
            }
        }
            break;
        case WWHSlideStaticStateLeft:
        {
            if (curMoveX < 0) {
                if (self.view.frame.origin.x == 0) {
                    state = WWHSlideDynamicStateHome;
                } else if (self.view.frame.origin.x > 0) {
                    state = WWHSlideDynamicStateLeftToHome;
                } else if (self.view.frame.origin.x < 0 && ([self supportSide] & WWHSlideSideRight)) {
                    state = WWHSlideDynamicStateHomeToRight;
                } else {
                    state = WWHSlideDynamicStateHome;
                }
            } else {
                state = WWHSlideDynamicStateUnkind;
            }
        }
            break;
        case WWHSlideStaticStateRight:
        {
            if (curMoveX > 0) {
                if (self.view.frame.origin.x == 0) {
                    state = WWHSlideDynamicStateHome;
                } else if (self.view.frame.origin.x < 0) {
                    state = WWHSlideDynamicStateRightToHome;
                } else if (self.view.frame.origin.x > 0 && ([self supportSide] & WWHSlideSideLeft)) {
                    state = WWHSlideDynamicStateHomeToLeft;
                } else {
                    state = WWHSlideDynamicStateHome;
                }
            } else {
                state = WWHSlideDynamicStateUnkind;
            }
        }
            break;
            
        default:
        {
            
        }
            break;
    }
    _dynamicState = state;
    return state;
}
/**
 *  根据当前手势滑动距离（X方向）计算出home和menu的缩放比例
 *
 *  @param curMoveX 手势当前滑动距离（X方向）
 *
 *  @return 各个scale
 */
- (WWHSlideScale)getSlideScalesWithMoveX:(CGFloat)curMoveX {
    WWHSlideScale scale;
    CGFloat homeScaleForShowMenu;
    CGFloat homeScaleForHiddenMenu;
    CGFloat menuScaleForShowMenu;
    CGFloat menuScaleForHiddenMenu;
    
    if (_homeScaleEnabled) {
        homeScaleForShowMenu = 1 - ABS(curMoveX) / self.maxMoveX * ( 1 - self.maxScale);
        homeScaleForShowMenu = MAX(self.maxScale, homeScaleForShowMenu);
        homeScaleForHiddenMenu = self.maxScale + ABS(curMoveX) / self.maxMoveX * (1 - self.maxScale);
    }
    else{
        homeScaleForShowMenu = 1;
        homeScaleForHiddenMenu = 1;
    }
    
    if (_menuScaleEnabled) {
        menuScaleForShowMenu = self.maxScale + ABS(curMoveX) / self.maxMoveX * (1 - self.maxScale);
        menuScaleForHiddenMenu = 1 - ABS(curMoveX) / self.maxMoveX * (1 - self.maxScale);
        menuScaleForHiddenMenu = MAX(self.maxScale, menuScaleForHiddenMenu);
    }
    else{
        menuScaleForHiddenMenu = 1;
        menuScaleForShowMenu = 1;
    }
    scale.WWHSlideScaleMenuShow = menuScaleForShowMenu;
    scale.WWHSlideScaleMenuHideen = menuScaleForHiddenMenu;
    scale.WWHSlideScaleHomeShowMenu = homeScaleForShowMenu;
    scale.WWHSlideScaleHomeHiddenMenu = homeScaleForHiddenMenu;
    
    return scale;
}
/**
 *  根据Slide的动态状态来选择显示菜单
 *
 *  @param dynamicState 动态状态
 */
- (void)chooseMenuViewWithSlideDynamicState:(WWHSlideDynamicState)dynamicState {
    switch (dynamicState) {
        case WWHSlideDynamicStateHomeToLeft:
        case WWHSlideDynamicStateHome:
        case WWHSlideDynamicStateLeft:
        case WWHSlideDynamicStateLeftToHome:
        {
            [self leftWillBeShowed];
        }
            break;
        case WWHSlideDynamicStateRightToHome:
        case WWHSlideDynamicStateHomeToRight:
        case WWHSlideDynamicStateRight:
        {
            [self rightWillBeShowed];
        }
            break;
        default:
            break;
    }
}
/**
 *  动态的展示侧滑框架（在pan手势下的动画）
 *
 *  @param curMoveX pan的X方向距离
 *  @param state    动态状态
 */
- (void)dynamicShowWithMoveX:(CGFloat)curMoveX dynamicState:(WWHSlideDynamicState)state {
    CGFloat alphaForShowItem = ABS(curMoveX)/self.maxMoveX;
    CGFloat alphaForHiddenItem = 1 - ABS(curMoveX)/self.maxMoveX;
    WWHSlideScale scale = [self getSlideScalesWithMoveX:curMoveX];
    CGFloat homeScaleForShowMenu = scale.WWHSlideScaleHomeShowMenu;
    CGFloat homeScaleForHiddenMenu = scale.WWHSlideScaleHomeHiddenMenu;
    CGFloat menuScaleForShowMenu = scale.WWHSlideScaleMenuShow;
    CGFloat menuScaleForHiddenMenu = scale.WWHSlideScaleMenuHideen;
    
    switch (_dynamicState) {
        case WWHSlideDynamicStateHomeToLeft:
        case WWHSlideDynamicStateHomeToRight:
        {
            [self panningShowMenusAlpha:alphaForHiddenItem curMoveX:curMoveX homeScale:homeScaleForShowMenu menuScale:menuScaleForShowMenu];
        }
            break;
        case WWHSlideDynamicStateHome:
        {
            [self panningShowMenusAlpha:alphaForHiddenItem curMoveX:0 homeScale:1 menuScale:0];
        }
            break;
        case WWHSlideDynamicStateLeft:
        {
            [self panningShowMenusAlpha:alphaForHiddenItem curMoveX:self.maxMoveX homeScale:self.maxScale menuScale:1];
        }
            break;
        case WWHSlideDynamicStateRight:
        {
            [self panningShowMenusAlpha:alphaForHiddenItem curMoveX:-self.maxMoveX homeScale:self.maxScale menuScale:1];
        }
            break;
        case WWHSlideDynamicStateLeftToHome:
        case WWHSlideDynamicStateRightToHome:
        {
            [self panningRevealHomeAlpha:alphaForShowItem curMoveX:curMoveX homeScale:homeScaleForHiddenMenu menuScale:menuScaleForHiddenMenu];
        }
            break;
        case WWHSlideDynamicStateUnkind:
        {
            
        }
            break;
        default:
            break;
    }
}

- (void)panningShowMenusAlpha:(CGFloat)alphaForHiddenItem curMoveX:(CGFloat)curMoveX homeScale:(CGFloat)homeScaleForShowMenu menuScale:(CGFloat)menuScaleForShowMenu {
    if (self.slideDelegate && [self.slideDelegate respondsToSelector:@selector(slideControllerScrollingShowMenu:)]) {
        [self.slideDelegate slideControllerScrollingShowMenu:self];
    }
    CGAffineTransform t = CGAffineTransformMakeTranslation(curMoveX, 0);
    self.view.transform = CGAffineTransformScale(t, homeScaleForShowMenu, homeScaleForShowMenu);
    
    CGFloat moveX = curMoveX * _menuOffset / self.maxMoveX;
    CGAffineTransform t1 = CGAffineTransformMakeTranslation(moveX, 0);
    
    if (_dynamicState == WWHSlideDynamicStateHomeToRight) {
        self.rightViewController.view.transform = CGAffineTransformScale(t1,menuScaleForShowMenu, menuScaleForShowMenu);
    } else if (_dynamicState == WWHSlideDynamicStateHomeToLeft) {
        self.leftViewController.view.transform = CGAffineTransformScale(t1,menuScaleForShowMenu, menuScaleForShowMenu);
    }
}

- (void)panningRevealHomeAlpha:(CGFloat)alphaForShowItem curMoveX:(CGFloat)curMoveX homeScale:(CGFloat)homeScaleForHiddenMenu menuScale:(CGFloat)menuScaleForHiddenMenu{
    if (self.slideDelegate && [self.slideDelegate respondsToSelector:@selector(slideControllerScrollingBackHome:)]) {
        [self.slideDelegate slideControllerScrollingBackHome:self];
    }
    NSInteger num;
    if (curMoveX < 0) {
        num = 1;
    }
    else if(curMoveX > 0) {
        num = -1;
    }
    
    CGAffineTransform t = CGAffineTransformMakeTranslation(curMoveX + num * self.maxMoveX, 0);
    self.view.transform = CGAffineTransformScale(t, homeScaleForHiddenMenu, homeScaleForHiddenMenu);
    
    CGFloat moveX =num * _menuOffset * (1 - (ABS(curMoveX/self.maxMoveX)));
    CGAffineTransform t1 = CGAffineTransformMakeTranslation(moveX, 0);
    
    if (_dynamicState == WWHSlideDynamicStateLeftToHome) {
        self.leftViewController.view.transform = CGAffineTransformScale(t1,menuScaleForHiddenMenu, menuScaleForHiddenMenu);
    } else if(_dynamicState == WWHSlideDynamicStateRightToHome) {
        self.rightViewController.view.transform = CGAffineTransformScale(t1,menuScaleForHiddenMenu, menuScaleForHiddenMenu);
    }
}

- (void)leftWillBeShowed {
    [self.view.superview insertSubview:self.rightViewController.view belowSubview:self.leftViewController.view];
    [self.view.superview insertSubview:_backgroundImageView belowSubview:self.leftViewController.view];
}

- (void)rightWillBeShowed {
    [self.view.superview insertSubview:self.leftViewController.view belowSubview:self.rightViewController.view];
    [self.view.superview insertSubview:_backgroundImageView belowSubview:self.rightViewController.view];
}

#pragma mark panEnd
- (WWHSlideStaticState)gteSlideStaticStateWithFrameX:(CGFloat)frameX {
    WWHSlideStaticState staticState;
    if (self.view.frame.origin.x >= 0) {
        if (self.view.frame.origin.x < self.maxMoveX/2) {
            staticState = WWHSlideStaticStateHome;
        } else {
            staticState = WWHSlideStaticStateLeft;
        }
    }
    else if (self.view.frame.origin.x <= 0) {
        if (self.view.frame.origin.x > -self.maxMoveX/2) {
            staticState = WWHSlideStaticStateHome;
        } else {
            staticState = WWHSlideStaticStateRight;
        }
    }
    _staticState = staticState;
    return staticState;
}

- (void)staticShowWithStaticState:(WWHSlideStaticState)staticState {
    switch (staticState) {
        case WWHSlideStaticStateHome:
        {
            [self panEndRevealHomeAnimated];
        }
            break;
        case WWHSlideStaticStateLeft:
        {
            [self panEndShowLeftMenuAnimated];
        }
            break;
        case WWHSlideStaticStateRight:
        {
            [self panEndShowRightAnimated];
        }
            break;

        default:
            break;
    }
}

- (void)panEndShowLeftMenuAnimated {
    if (self.leftViewController) {
        CGRect rect = self.leftViewController.view.frame;
        self.leftViewController.view.transform = CGAffineTransformIdentity;
        self.leftViewController.view.frame = rect;
    }
    [self showLeftMenuAnimated];
}

- (void)showLeftMenuAnimated {
    [UIView animateWithDuration:0.3 animations:^{
        CGAffineTransform t0 = CGAffineTransformMakeTranslation(self.maxMoveX, 0);
        self.view.transform = CGAffineTransformScale(t0, self.maxScale, self.maxScale);
        //yinzi是在panEnd时，menu已经缩放的因子，记录下此时的menu的frame，然后继续transform
        CGFloat widthNow = self.leftViewController.view.frame.size.width;
        CGFloat yinzi = (widthNow / (SelfViewWidth - self.anchorOffset)/self.maxScale);
        if (self.maxScale == 1) {
            CGAffineTransform t = CGAffineTransformMakeTranslation(-self.leftViewController.view.frame.origin.x, 0);
            self.leftViewController.view.transform = CGAffineTransformScale(t,1,1);
        } else {
            CGAffineTransform t = CGAffineTransformMakeTranslation(_menuOffset *(1 - (yinzi-1) / (1.25 - 1)), 0);
            self.leftViewController.view.transform = CGAffineTransformScale(t,1.25/yinzi,1.25/yinzi);
        }
    } completion:^(BOOL finished){
        self.leftViewController.view.transform = CGAffineTransformIdentity;
        self.leftViewController.view.frame = CGRectMake(-_menuOffset, 0, SelfViewWidth - _anchorOffset, SelfViewFrame.size.height);
        self.leftViewController.view.transform = CGAffineTransformMakeTranslation(_menuOffset, 0);
        
        if (self.slideDelegate && [self.slideDelegate respondsToSelector:@selector(slideControllerDidShowLeftMenu:)]) {
            [self.slideDelegate slideControllerDidShowLeftMenu:self];
        }
    }];
}

- (void)panEndShowRightAnimated {
    if (_staticState == WWHSlideStaticStateRight) {
        if (self.rightViewController) {
            CGRect rect = self.rightViewController.view.frame;
            self.rightViewController.view.transform = CGAffineTransformIdentity;
            self.rightViewController.view.frame = rect;
        }
    }
    [self showRightMenuAnimated];
}

- (void)showRightMenuAnimated {
    [UIView animateWithDuration:0.3 animations:^{
        CGAffineTransform t0 = CGAffineTransformMakeTranslation(-self.maxMoveX, 0);
        self.view.transform = CGAffineTransformScale(t0, self.maxScale, self.maxScale);
        CGFloat widthNow = self.rightViewController.view.frame.size.width;
        CGFloat yinzi = (widthNow / (SelfViewWidth - self.anchorOffset)/self.maxScale);
        if (self.maxScale == 1) {
            CGAffineTransform t = CGAffineTransformMakeTranslation(-(self.rightViewController.view.frame.origin.x - self.anchorOffset), 0);
            self.rightViewController.view.transform = CGAffineTransformScale(t,1,1);
        } else {
            CGAffineTransform t = CGAffineTransformMakeTranslation(-_menuOffset *(1 - (yinzi-1) / (1.25 - 1)), 0);
            self.rightViewController.view.transform = CGAffineTransformScale(t,1.25/yinzi,1.25/yinzi);
        }
    } completion:^(BOOL finished){
        self.rightViewController.view.transform = CGAffineTransformIdentity;
        self.rightViewController.view.frame = CGRectMake(_menuOffset + self.anchorOffset, 0, SelfViewWidth - _anchorOffset, SelfViewFrame.size.height);
        self.rightViewController.view.transform = CGAffineTransformMakeTranslation(-_menuOffset, 0);
        
        if (self.slideDelegate && [self.slideDelegate respondsToSelector:@selector(slideControllerDidShowRightMenu:)]) {
            [self.slideDelegate slideControllerDidShowRightMenu:self];
        }
    }];
}

- (void)panEndRevealHomeAnimated {
    if (self.leftViewController) {
        CGRect rect = self.leftViewController.view.frame;
        self.leftViewController.view.transform = CGAffineTransformIdentity;
        self.leftViewController.view.frame = rect;
    }
    if (self.rightViewController) {
        CGRect rect = self.rightViewController.view.frame;
        self.rightViewController.view.transform = CGAffineTransformIdentity;
        self.rightViewController.view.frame = rect;
    }
    [self tapRevealHomeAnimated];
}
#pragma mark- tap
- (void)handelTap:(UITapGestureRecognizer *)sender {
    if (_staticState == WWHSlideStaticStateHome) {
        return;
    }
    if (self.leftViewController) {
        self.leftViewController.view.transform = CGAffineTransformIdentity;
        self.leftViewController.view.frame = CGRectMake(0, 0, SelfViewWidth - self.anchorOffset, SelfViewFrame.size.height);
    }
    if (self.rightViewController) {
        self.rightViewController.view.transform = CGAffineTransformIdentity;
        self.rightViewController.view.frame = CGRectMake(self.anchorOffset, 0, SelfViewWidth - self.anchorOffset, SelfViewFrame.size.height);
    }
    [self tapRevealHomeAnimated];
}

- (void)tapRevealHomeAnimated {
    [UIView animateWithDuration:0.3 animations:^{
        self.view.transform = CGAffineTransformIdentity;
        if (self.leftViewController) {
            //这里是恢复到home，所以对menu不做缩放因子考虑，因为被home挡住了。
            CGAffineTransform t = CGAffineTransformMakeTranslation(-_menuOffset, 0);
            self.leftViewController.view.transform = CGAffineTransformScale(t,self.maxScale, self.maxScale);
        }
        if (self.rightViewController) {
            CGAffineTransform t1 = CGAffineTransformMakeTranslation(_menuOffset, 0);
            self.rightViewController.view.transform = CGAffineTransformScale(t1,self.maxScale, self.maxScale);
        }
    } completion:^(BOOL finished){
        if (self.leftViewController) {
            self.leftViewController.view.transform = CGAffineTransformIdentity;
            self.leftViewController.view.frame = CGRectMake(-_menuOffset, 0, SelfViewWidth - _anchorOffset, SelfViewFrame.size.height);
        }
        if (self.rightViewController) {
            self.rightViewController.view.transform = CGAffineTransformIdentity;
            self.rightViewController.view.frame = CGRectMake(_menuOffset + self.anchorOffset, 0, SelfViewWidth - _anchorOffset, SelfViewFrame.size.height);
        }
        if (self.slideDelegate && [self.slideDelegate respondsToSelector:@selector(slideControllerDidHome:)]) {
            [self.slideDelegate slideControllerDidHome:self];
        }
    }];
    _staticState = WWHSlideStaticStateHome;
    _dynamicState = WWHSlideDynamicStateHome;
}
/**
 *  点击显示右边menu
 */
- (void)tapShowOrHideRightAnimated {
    if (self.rightViewController && ([self supportSide] & WWHSlideSideRight)) {
        [self showShadowWithSlideDynamicState:WWHSlideDynamicStateRight];
        [self chooseMenuViewWithSlideDynamicState:WWHSlideDynamicStateRight];
        if (_staticState == WWHSlideStaticStateHome) {
            
            self.rightViewController.view.transform = CGAffineTransformMakeScale(self.maxScale, self.maxScale);
            if ([self supportSide] & WWHSlideSideLeft ) {
                
                [UIView animateWithDuration:0.3 animations:^{
                    CGAffineTransform t = CGAffineTransformMakeTranslation(-self.maxMoveX, 0);
                    self.view.transform = CGAffineTransformScale(t, self.maxScale, self.maxScale);
                    self.rightViewController.view.transform = CGAffineTransformMakeTranslation(-_menuOffset, 0);
                } completion:^(BOOL finished) {
                    if (self.slideDelegate && [self.slideDelegate respondsToSelector:@selector(slideControllerDidShowRightMenu:)]) {
                        [self.slideDelegate slideControllerDidShowRightMenu:self];
                    }
                }];
            }
            _dynamicState = WWHSlideDynamicStateRight;
            _staticState = WWHSlideStaticStateRight;
        } else if (_staticState == WWHSlideStaticStateRight) {
            if (self.rightViewController) {
                self.rightViewController.view.transform = CGAffineTransformIdentity;
                self.rightViewController.view.frame = CGRectMake(self.anchorOffset, 0, SelfViewWidth - self.anchorOffset, SelfViewFrame.size.height);
            }
            [self tapRevealHomeAnimated];
        }
    }
}
/**
 *  点击显示左边menu
 */
- (void)tapShowOrHideLeftAnimated {
    
    if (self.leftViewController && ([self supportSide] & WWHSlideSideLeft)) {
        [self showShadowWithSlideDynamicState:_dynamicState];
        [self chooseMenuViewWithSlideDynamicState:_dynamicState];
        if (_staticState == WWHSlideStaticStateHome) {
            
            self.leftViewController.view.transform = CGAffineTransformMakeScale(self.maxScale, self.maxScale);
            if ([self supportSide] & WWHSlideSideLeft ) {

                    [UIView animateWithDuration:0.3 animations:^{
                        CGAffineTransform t = CGAffineTransformMakeTranslation(self.maxMoveX, 0);
                        self.view.transform = CGAffineTransformScale(t, self.maxScale, self.maxScale);
                        self.leftViewController.view.transform = CGAffineTransformMakeTranslation(_menuOffset, 0);
                    } completion:^(BOOL finished) {
                        if (self.slideDelegate && [self.slideDelegate respondsToSelector:@selector(slideControllerDidShowLeftMenu:)]) {
                            [self.slideDelegate slideControllerDidShowLeftMenu:self];
                        }
                    }];
                }
            _dynamicState = WWHSlideDynamicStateLeft;
            _staticState = WWHSlideStaticStateLeft;
        } else if (_staticState == WWHSlideStaticStateLeft) {
            if (self.leftViewController) {
                self.leftViewController.view.transform = CGAffineTransformIdentity;
                self.leftViewController.view.frame = CGRectMake(0, 0, SelfViewWidth - self.anchorOffset, SelfViewFrame.size.height);
            }
            [self tapRevealHomeAnimated];
        }
    }
}
#pragma mark- changeHome
- (void)changeHome:(UIViewController *)homeVC needCloseSide:(BOOL)flag complete:(void (^)(void))complete {
    
    if (flag) {
        [self panEndRevealHomeAnimated];
    }
    
    if (homeVC && [homeVC isKindOfClass:[UIViewController class]]) {
        [self setViewControllers:@[homeVC]];
    }
    
    if (complete) {
        complete();
    }
}
#pragma mark- shadow
- (void)shadowWithDerection:(WWHSlideShadowDerection)derection {
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
    self.view.layer.shadowPath = shadowPath.CGPath;
    self.view.layer.masksToBounds = NO;
    if (_enableShadow) {
        self.view.layer.shadowColor = [UIColor grayColor].CGColor;
        self.view.layer.shadowOffset = CGSizeMake(derection*10.f, 10.f);
        self.view.layer.shadowOpacity = 0.5f;
        self.view.layer.shadowRadius = 8.f;
    } else {
        self.view.layer.shadowOffset = CGSizeMake(0, 0);
        self.view.layer.shadowOpacity = 0;
        self.view.layer.shadowRadius = 0;
    }
}

- (void)showShadowWithSlideDynamicState:(WWHSlideDynamicState)dynamicState {
    switch (dynamicState) {
        case WWHSlideDynamicStateHomeToLeft:
        case WWHSlideDynamicStateHome:
        case WWHSlideDynamicStateLeft:
        case WWHSlideDynamicStateLeftToHome:
        {
            [self shadowWithDerection:WWHSlideShadowDerectionLeft];
        }
            break;
        case WWHSlideDynamicStateRightToHome:
        case WWHSlideDynamicStateHomeToRight:
        case WWHSlideDynamicStateRight:
        {
            [self shadowWithDerection:WWHSlideShadowDerectionRight];
        }
            break;
        default:
            break;
    }
}
#pragma mark- SetterGetter
- (void)setEnablePanGuesture:(BOOL)enablePanGuesture {
    _enablePanGuesture = enablePanGuesture;
    _pan.enabled = _enablePanGuesture;
}

- (void)setLeftViewController:(UIViewController *)leftViewController {
    _leftViewController = leftViewController;
    leftViewController.slideController = self;
}

- (void)setRightViewController:(UIViewController *)rightViewController {
    _rightViewController = rightViewController;
    rightViewController.slideController = self;
}

- (WWHSlideSide)openSide {
    return [self supportSide];
}

- (CGFloat)zoomFactor {
    return ABS(_curMoveX) / self.maxMoveX;
}

- (CGFloat)maxMoveX {
    return _maxSlideRightX - SelfViewWidth * (1 - self.maxScale) / 2;
}

- (CGFloat)maxScale {
    if (_homeScaleEnabled) {
        return 0.8;
    } else {
        return 1;
    }
}
//简单的确定下leftView和rightView的初始位置，也可以不确定，但是可以简化过程
- (void)setMenuOffset:(CGFloat)menuOffset {
    _menuOffset = MIN(menuOffset, SelfViewWidth/3);
    if (self.leftViewController) {
        CGRect rect = CGRectMake(-self.menuOffset, 0, SelfViewWidth - self.anchorOffset, SelfViewFrame.size.height);
        self.leftViewController.view.frame = rect;
    }
    if (self.rightViewController) {
        CGRect rect = CGRectMake(self.anchorOffset + self.menuOffset, 0, SelfViewWidth - self.anchorOffset, SelfViewFrame.size.height);
        self.rightViewController.view.frame = rect;
    }
}

- (void)setAnchorOffset:(CGFloat)anchorOffset {
    _anchorOffset = MIN(anchorOffset, SelfViewWidth/2);
    _maxSlideRightX = SelfViewWidth - self.anchorOffset;
    _minSlideleftX =  -_maxSlideRightX;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    if (backgroundColor) {
        _backgroundColor = backgroundColor;
        _backgroundImageView.backgroundColor = _backgroundColor;
    }
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
    if (backgroundImage) {
        _backgroundImage = backgroundImage;
        _backgroundImageView.image = _backgroundImage;
    }
}
@end

NSString *const SlideControllerKey = @"SlideControllerKey";
@implementation UIViewController (Slide)
- (WWHSlideSide)supportedSlideSide {
    return WWHSlideSideLeft | WWHSlideSideRight;
}

- (void)setSlideController:(WWHSlideController *)slideController {
    objc_setAssociatedObject(self, CFBridgingRetain(SlideControllerKey), slideController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (WWHSlideController *)slideController {
    UINavigationController *nav = self.navigationController;
    if ([nav isKindOfClass:[WWHSlideController class]]) {
        return (WWHSlideController *)nav;
    } else {
        WWHSlideController *slideVC = objc_getAssociatedObject(self, CFBridgingRetain(SlideControllerKey));
        if (slideVC) {
            return slideVC;
        }
    }
    return nil;
}
@end
