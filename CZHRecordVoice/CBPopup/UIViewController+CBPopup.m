//
//  UIViewController+CBPopup.m
//  show
//
//  Created by changcun on 21/12/2017.
//  Copyright © 2017 changba. All rights reserved.
//

#import "UIViewController+CBPopup.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

static const CGFloat kPopupAnimationDuration = 0.25;

@interface UIViewController ()

@property(strong, nonatomic) UIView *cb_maskView;
@property(strong, nonatomic) UIControl *cb_overlayView;
@property(strong, nonatomic) UIViewController *cb_popupViewController;

@property(assign, nonatomic) CGRect cb_startRect;
@property(assign, nonatomic) CBPopupViewAligment cb_aligment;
@property(assign, nonatomic) CBPopupViewAnimation cb_animation;

@property(copy, nonatomic) void (^cb_dismissedCallback)(void);
@property(copy, nonatomic) NSArray<UIViewController *> *cb_sourceViewControllers;

@end

@implementation UIViewController (CBPopup)

#pragma mark - Extension getters&setters

- (void (^)(void))cb_dismissedCallback {
    return objc_getAssociatedObject(self, @selector(cb_dismissedCallback));
}

- (void)setCb_dismissedCallback:(void (^)(void))dismissed {
    [self willChangeValueForKey:@"cb_dismissedCallback"];
    objc_setAssociatedObject(self, @selector(cb_dismissedCallback), dismissed, OBJC_ASSOCIATION_COPY);
    [self didChangeValueForKey:@"cb_dismissedCallback"];
}

- (UIView *)cb_maskView {
    return objc_getAssociatedObject(self, @selector(cb_maskView));
}

- (void)setCb_maskView:(UIView *)maskView {
    if (maskView != self.cb_maskView) {
        [self willChangeValueForKey:@"cb_maskView"];
        objc_setAssociatedObject(self,
            @selector(cb_maskView),
            maskView,
            OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self didChangeValueForKey:@"cb_maskView"];
    }
}

- (UIButton *)cb_overlayView {
    return objc_getAssociatedObject(self, @selector(cb_overlayView));
}

- (void)setCb_overlayView:(UIButton *)overlayView {
    if (overlayView != self.cb_overlayView) {
        [self willChangeValueForKey:@"cb_overlayView"];
        objc_setAssociatedObject(self,
            @selector(cb_overlayView),
            overlayView,
            OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self didChangeValueForKey:@"cb_overlayView"];
    }
}

- (CGRect)cb_startRect {
    NSValue *rectValue = objc_getAssociatedObject(self, @selector(cb_startRect));
    return [rectValue CGRectValue];
}

- (void)setCb_startRect:(CGRect)startRect {
    if (!CGRectEqualToRect(startRect, self.cb_startRect)) {
        [self willChangeValueForKey:@"cb_startRect"];
        objc_setAssociatedObject(self,
            @selector(cb_startRect),
            [NSValue valueWithCGRect:startRect],
            OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self didChangeValueForKey:@"cb_startRect"];
    }
}

- (CBPopupViewAligment)cb_aligment {
    NSNumber *value = objc_getAssociatedObject(self, @selector(cb_aligment));
    return (CBPopupViewAligment) [value integerValue];
}

- (void)setCb_aligment:(CBPopupViewAligment)aligment {
    if (aligment != self.cb_aligment) {
        [self willChangeValueForKey:@"cb_aligment"];
        objc_setAssociatedObject(self,
            @selector(cb_aligment),
            @(aligment),
            OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self didChangeValueForKey:@"cb_aligment"];
    }
}

- (CBPopupViewAnimation)cb_animation {
    NSNumber *value = objc_getAssociatedObject(self, @selector(cb_animation));
    return (CBPopupViewAnimation) [value integerValue];
}

- (void)setCb_animation:(CBPopupViewAnimation)animation {
    if (animation != self.cb_animation) {
        [self willChangeValueForKey:@"cb_animation"];
        objc_setAssociatedObject(self,
            @selector(cb_animation),
            @(animation),
            OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [self didChangeValueForKey:@"cb_animation"];
    }
}

- (UIViewController *)cb_popupViewController {
    return objc_getAssociatedObject(self, @selector(cb_popupViewController));
}

- (void)setCb_popupViewController:(UIViewController *)cb_popupViewController {
    objc_setAssociatedObject(self, @selector(cb_popupViewController), cb_popupViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray *)cb_sourceViewControllers {
    return objc_getAssociatedObject(self, @selector(cb_sourceViewControllers));
}

- (void)setCb_sourceViewControllers:(NSArray *)cb_sourceViewController {
    objc_setAssociatedObject(self, @selector(cb_sourceViewControllers), cb_sourceViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Public methods

- (void)cb_presentPopupViewController:(UIViewController *)popupViewController {
    [self cb_presentPopupViewController:popupViewController animationType:CBPopupViewAnimationFade];
}

- (void)cb_presentPopupViewController:(UIViewController *)popupViewController
                            dismissed:(void (^)(void))dismissed {
    [self cb_presentPopupViewController:popupViewController animationType:CBPopupViewAnimationFade aligment:CBPopupViewAligmentCenter dismissed:dismissed];
}

- (void)cb_presentPopupViewController:(UIViewController *)popupViewController
                        animationType:(CBPopupViewAnimation)animationType {
    [self cb_presentPopupViewController:popupViewController animationType:animationType dismissed:nil];
}

- (void)cb_presentPopupViewController:(UIViewController *)popupViewController
                        animationType:(CBPopupViewAnimation)animationType
                            dismissed:(void (^)(void))dismissed {
    [self cb_presentPopupViewController:popupViewController animationType:animationType aligment:CBPopupViewAligmentCenter dismissed:dismissed];
}

- (void)cb_presentPopupViewController:(UIViewController *)popupViewController
                        animationType:(CBPopupViewAnimation)animationType
                             aligment:(CBPopupViewAligment)aligment
                            dismissed:(void (^)(void))dismissed {
    UIViewController *rootVC = [self cb_rootViewController];

    if ([rootVC.cb_sourceViewControllers containsObject:self]) {
        [rootVC cb_dismissPopupViewControllerWithSourceController:self animated:NO];
    }

    NSMutableArray *sourceViewControllers = [[NSMutableArray alloc] initWithArray:rootVC.cb_sourceViewControllers];

    [sourceViewControllers addObject:self];

    rootVC.cb_sourceViewControllers = sourceViewControllers;

    self.cb_animation = animationType;
    self.cb_aligment = aligment;
    self.cb_popupViewController = popupViewController;

    [self cb_updateViewHierachy];

    if (!popupViewController.view.superview) {
        [self.cb_overlayView addSubview:popupViewController.view];
    }

    popupViewController.view.alpha = 0;

    switch (animationType) {
        case CBPopupViewAnimationSlideFromBottom:
        case CBPopupViewAnimationSlideFromTop:
        case CBPopupViewAnimationSlideFromLeft:
        case CBPopupViewAnimationSlideFromRight:
            [self cb_slideViewIn];
            break;
        default:
            [self cb_fadeViewIn:popupViewController.view];
            break;
    }

    [self setCb_dismissedCallback:dismissed];
}

- (void)cb_dismissPopupViewControllerAnimated:(BOOL)animated {
    UIViewController *rootVC = [self cb_rootViewController];
    UIViewController *sourceVC = rootVC.cb_sourceViewControllers.lastObject;

    if ([rootVC.cb_sourceViewControllers containsObject:self]) {
        sourceVC = self;
    }

    if (sourceVC) {
        [self cb_dismissPopupViewControllerWithSourceController:sourceVC animated:animated];
    }
}

- (void)cb_dismissPopupViewControllerToRootAnimated:(BOOL)animated {
    UIViewController *rootVC = [self cb_rootViewController];
    UIViewController *sourceVC = rootVC.cb_sourceViewControllers.firstObject;

    if (sourceVC) {
        [self cb_dismissPopupViewControllerWithSourceController:sourceVC animated:animated];
    }
}

- (void)cb_dismissPopupViewControllerWithSourceController:(UIViewController *)sourceController animated:(BOOL)animated {
    UIViewController *rootVC = [self cb_rootViewController];

    NSMutableArray *sourceViewControllers = [[NSMutableArray alloc] initWithArray:rootVC.cb_sourceViewControllers];

    NSInteger soureIndexToRemove = [sourceViewControllers indexOfObject:sourceController];

    if (soureIndexToRemove != sourceViewControllers.count - 1) {

        for (NSInteger i = soureIndexToRemove; i < sourceViewControllers.count; ++i) {

            UIViewController *vcToRemove = sourceViewControllers[i];
            UIView *popupView = vcToRemove.cb_popupViewController.view;

            [popupView removeFromSuperview];
            [vcToRemove.cb_overlayView removeFromSuperview];
        }

        [sourceViewControllers removeObjectsInRange:NSMakeRange(soureIndexToRemove, sourceViewControllers.count - soureIndexToRemove)];
    }

    if (animated) {
        if (sourceController.cb_animation == CBPopupViewAnimationFade) {
            [sourceController cb_fadeViewOut];
        } else {
            [sourceController cb_slideViewOut];
        }
    } else {
        UIView *popupView = sourceController.cb_popupViewController.view;

        [popupView removeFromSuperview];
        [sourceController.cb_overlayView removeFromSuperview];
    }

    sourceController.cb_popupViewController = nil;

    [sourceViewControllers removeObject:sourceController];
    rootVC.cb_sourceViewControllers = sourceViewControllers;
}

#pragma mark - Animations

- (void)cb_slideViewIn {
    UIView *popupView = self.cb_popupViewController.view;
    CGSize sourceSize = self.cb_overlayView.bounds.size;
    CGSize popupSize = popupView.bounds.size;
    CGRect popupStartRect;

    switch (self.cb_animation) {
        case CBPopupViewAnimationSlideFromBottom:
            popupStartRect = CGRectMake((sourceSize.width - popupSize.width) * 0.5,
                sourceSize.height,
                popupSize.width,
                popupSize.height);

            break;
        case CBPopupViewAnimationSlideFromLeft:
            switch (self.cb_aligment) {
                case CBPopupViewAligmentCenter:
                    popupStartRect = CGRectMake(-sourceSize.width,
                        (sourceSize.height - popupSize.height) * 0.5,
                        popupSize.width,
                        popupSize.height);
                    break;
                case CBPopupViewAligmentTop:
                    popupStartRect = CGRectMake(-sourceSize.width,
                        0,
                        popupSize.width,
                        popupSize.height);
                    break;
                case CBPopupViewAligmentBottom:
                    popupStartRect = CGRectMake(-sourceSize.width,
                        sourceSize.height - popupSize.height,
                        popupSize.width,
                        popupSize.height);
                    break;
            }
            break;

        case CBPopupViewAnimationSlideFromTop:
            popupStartRect = CGRectMake((sourceSize.width - popupSize.width) * 0.5,
                -popupSize.height,
                popupSize.width,
                popupSize.height);
            break;
        case CBPopupViewAnimationSlideFromRight:
            switch (self.cb_aligment) {
                case CBPopupViewAligmentCenter:
                    popupStartRect = CGRectMake(sourceSize.width,
                        (sourceSize.height - popupSize.height) * 0.5,
                        popupSize.width,
                        popupSize.height);
                    break;
                case CBPopupViewAligmentTop:
                    popupStartRect = CGRectMake(sourceSize.width,
                        0,
                        popupSize.width,
                        popupSize.height);
                    break;
                case CBPopupViewAligmentBottom:
                    popupStartRect = CGRectMake(sourceSize.width,
                        sourceSize.height - popupSize.height,
                        popupSize.width,
                        popupSize.height);
                    break;
            }
            break;
        default:
            popupStartRect = CGRectMake(sourceSize.width,
                (sourceSize.height - popupSize.height) * 0.5,
                popupSize.width,
                popupSize.height);
            break;
    }

    self.cb_startRect = popupStartRect;

    CGRect popupEndRect;

    switch (self.cb_aligment) {
        case CBPopupViewAligmentCenter:
            popupEndRect = CGRectMake((sourceSize.width - popupSize.width) * 0.5,
                (sourceSize.height - popupSize.height) * 0.5,
                popupSize.width,
                popupSize.height);
            break;
        case CBPopupViewAligmentTop:
            popupEndRect = CGRectMake((sourceSize.width - popupSize.width) * 0.5,
                0,
                popupSize.width,
                popupSize.height);
            break;
        case CBPopupViewAligmentBottom:
            popupEndRect = CGRectMake((sourceSize.width - popupSize.width) * 0.5,
                sourceSize.height - popupSize.height,
                popupSize.width,
                popupSize.height);
            break;
    }

    popupView.frame = popupStartRect;
    popupView.alpha = 1.0;
    self.cb_maskView.alpha = 0;

    [UIView animateWithDuration:kPopupAnimationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{

        [self.cb_popupViewController viewWillAppear:NO];
        self.cb_maskView.alpha = 1.0;
        popupView.frame = popupEndRect;
    }                completion:^(BOOL finished) {

        [self.cb_popupViewController viewDidAppear:NO];
    }];
}

- (void)cb_slideViewOut {
    UIView *popupView = self.cb_popupViewController.view;

    [UIView animateWithDuration:kPopupAnimationDuration
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn animations:^{

            [self.cb_popupViewController viewWillDisappear:NO];
            popupView.frame = self.cb_startRect;
            self.cb_maskView.alpha = 0;

        }            completion:^(BOOL finished) {

            [popupView removeFromSuperview];
            [self.cb_overlayView removeFromSuperview];
            self.cb_popupViewController = nil;
            [self.cb_popupViewController viewDidDisappear:NO];

            self.cb_maskView = nil;
            self.cb_overlayView = nil;

            id dismissed = [self cb_dismissedCallback];
            if (dismissed != nil) {
                ((void (^)(void)) dismissed)();
                [self setCb_dismissedCallback:nil];
            }
        }];
}

#pragma mark - Fade

- (void)cb_fadeViewIn:(UIView *)popupView {
    CGSize sourceSize = self.cb_overlayView.bounds.size;
    CGSize popupSize = popupView.bounds.size;
    CGRect popupEndRect;

    switch (self.cb_aligment) {
        case CBPopupViewAligmentCenter:
            popupEndRect = CGRectMake((sourceSize.width - popupSize.width) * 0.5,
                (sourceSize.height - popupSize.height) * 0.5,
                popupSize.width,
                popupSize.height);
            break;
        case CBPopupViewAligmentTop:
            popupEndRect = CGRectMake((sourceSize.width - popupSize.width) * 0.5,
                0,
                popupSize.width,
                popupSize.height);
            break;
        case CBPopupViewAligmentBottom:
            popupEndRect = CGRectMake((sourceSize.width - popupSize.width) * 0.5,
                sourceSize.height - popupSize.height,
                popupSize.width,
                popupSize.height);
            break;
    }

    popupView.frame = popupEndRect;
    popupView.alpha = 0;
    self.cb_maskView.alpha = 0;


    [UIView animateWithDuration:kPopupAnimationDuration animations:^{

        [self.cb_popupViewController viewWillAppear:NO];
        self.cb_maskView.alpha = 1.0;
        popupView.alpha = 1.0;
    }                completion:^(BOOL finished) {

        [self.cb_popupViewController viewDidAppear:NO];
    }];
}

- (void)cb_fadeViewOut {
    UIView *popupView = self.cb_popupViewController.view;

    [UIView animateWithDuration:kPopupAnimationDuration animations:^{

        [self.cb_popupViewController viewWillDisappear:NO];
        self.cb_maskView.alpha = 0;
        popupView.alpha = 0;
    }                completion:^(BOOL finished) {

        [popupView removeFromSuperview];
        [self.cb_overlayView removeFromSuperview];

        self.cb_popupViewController = nil;
        [self.cb_popupViewController viewDidDisappear:NO];
        self.cb_maskView = nil;
        self.cb_overlayView = nil;

        id dismissed = [self cb_dismissedCallback];
        if (dismissed != nil) {
            ((void (^)(void)) dismissed)();
            [self setCb_dismissedCallback:nil];
        }
    }];
}

#pragma mark - Tools

- (void)cb_updateViewHierachy {
    if (!self.cb_overlayView.superview) {

        if (!self.cb_overlayView) {
            self.cb_overlayView = [[UIControl alloc] initWithFrame:UIScreen.mainScreen.bounds];
            self.cb_overlayView.backgroundColor = [UIColor clearColor];
            [self.cb_overlayView addTarget:self action:@selector(cb_tapAction:) forControlEvents:UIControlEventTouchUpInside];
        }

        if (!self.cb_maskView) {
            self.cb_maskView = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
            self.cb_maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
            self.cb_maskView.userInteractionEnabled = NO;
            [self.cb_overlayView addSubview:self.cb_maskView];
        }

        UIViewController *rootVC = [self cb_rootViewController];
        UIViewController *lastVC = rootVC.cb_sourceViewControllers.firstObject;
        UIViewController *topVC = [self cb_topViewControllerFromController:lastVC];

        [topVC.view addSubview:self.cb_overlayView];
        [self.cb_overlayView.superview bringSubviewToFront:self.cb_overlayView];
    } else {
        [self.cb_overlayView.superview bringSubviewToFront:self.cb_overlayView];
    }
}

- (UIViewController *)cb_rootViewController {
    UIWindow *cbWindow = [[[UIApplication sharedApplication] delegate] window];

    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows) {
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
        BOOL windowLevelNormal = window.windowLevel == UIWindowLevelNormal;

        if (windowOnMainScreen && windowIsVisible && windowLevelNormal) {
            cbWindow = window;
            break;
        }
    }

    return cbWindow.rootViewController;
}

- (UIViewController *)cb_topViewControllerFromController:(UIViewController *)controller {
    UIViewController *recentVC = self;

    if (controller) {
        recentVC = controller;
    }

    while (recentVC.parentViewController != nil) {
        recentVC = recentVC.parentViewController;
    }

    return recentVC;
}

#pragma mark - Actions

- (void)cb_tapAction:(id)sender {
    [self cb_dismissPopupViewControllerAnimated:YES];
}

@end
