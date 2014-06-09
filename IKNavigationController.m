//
//  IKNavigationController.m
//  
//
//  Created by Ilya Kalinin on 5/15/14.
//  Copyright (c) 2014 Ilya Kalinin. All rights reserved.
//

#import "IKNavigationController.h"

#define VC_KEY @"vc_key"
#define ANIMATED_KEY @"animated_key"
#define METHOD_KEY @"method_key"
#define TO_KEY @"to_key"

typedef NS_ENUM(NSInteger, OVNavigationControllerMethod) {
    OVNavigationControllerMethodPushView,
    OVNavigationControllerMethodPopView,
    OVNavigationControllerMethodPopToView,
    OVNavigationControllerMethodPopToRoot
    
};

@interface OVNavigationController ()

@property (nonatomic, strong) NSMutableArray *pendingControllers;

@end

@implementation OVNavigationController

@synthesize pendingControllers = _pendingControllers;

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.pendingControllers = [[NSMutableArray alloc] init];
        
    }
    return self;
    
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([self.pendingControllers count ] > 0) {
        @synchronized(self) {
            [self.pendingControllers removeObjectAtIndex:0];
            
        }
    }
    
    if ([self.pendingControllers count ] > 0) {
        NSDictionary *viewControllerObject = [self.pendingControllers objectAtIndex:0];
        OVNavigationControllerMethod navigationControllerMethod = [[viewControllerObject objectForKey:METHOD_KEY] integerValue];
        BOOL showAnimated = [[viewControllerObject objectForKey:ANIMATED_KEY] boolValue];
        UIViewController* doViewController = [viewControllerObject objectForKey:VC_KEY];
        UIViewController* toViewController = [viewControllerObject objectForKey:TO_KEY];
        
        switch (navigationControllerMethod) {
            case OVNavigationControllerMethodPushView:
                [super pushViewController:doViewController animated:showAnimated];
                break;
                
            case OVNavigationControllerMethodPopView:
                if (self.topViewController == doViewController) {
                    [super popViewControllerAnimated:showAnimated];
                    
                }
                break;
                
            case OVNavigationControllerMethodPopToView:
                if (self.topViewController == doViewController) {
                    [super popToViewController:toViewController animated:YES];
                    
                }
                break;
                
            case OVNavigationControllerMethodPopToRoot:
                if (self.topViewController == doViewController) {
                    [super popToRootViewControllerAnimated:showAnimated];
                    
                }
                break;
                
        }
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSDictionary *viewControllerObject = @{ VC_KEY: viewController,
                                            ANIMATED_KEY: [NSNumber numberWithBool:animated],
                                            METHOD_KEY : [NSNumber numberWithInteger:OVNavigationControllerMethodPushView] };
    @synchronized(self) {
        [self.pendingControllers addObject:viewControllerObject];
    
    
    }
    
    if ([self.pendingControllers count] == 1) {
        [super pushViewController:viewController animated:animated];
        
    }
    
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    NSDictionary *viewControllerObject = @{ VC_KEY: self.topViewController,
                                            ANIMATED_KEY: [NSNumber numberWithBool:animated],
                                            METHOD_KEY : [NSNumber numberWithInteger:OVNavigationControllerMethodPopView] };
    @synchronized(self) {
        [self.pendingControllers addObject:viewControllerObject];
        
        
    }
    
    if ([self.pendingControllers count] == 1) {
        [super popViewControllerAnimated:animated];
        
    }
    return self.topViewController;
    
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSDictionary *viewControllerObject = @{ VC_KEY: self.topViewController,
                                            ANIMATED_KEY: [NSNumber numberWithBool:animated],
                                            METHOD_KEY : [NSNumber numberWithInteger:OVNavigationControllerMethodPopToView],
                                            TO_KEY : viewController };
    @synchronized(self) {
        [self.pendingControllers addObject:viewControllerObject];
        
    }
    
    if ([self.pendingControllers count] == 1) {
        [super popToViewController:viewController animated:animated];
        
    }
    NSUInteger b = [self.viewControllers indexOfObject:viewController] + 1;
    NSUInteger e = [self.viewControllers count];
    return [self.viewControllers subarrayWithRange:NSMakeRange(b, e - b)];
    
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated {
    NSDictionary *viewControllerObject = @{ VC_KEY: self.topViewController,
                                            ANIMATED_KEY: [NSNumber numberWithBool:animated],
                                            METHOD_KEY : [NSNumber numberWithInteger:OVNavigationControllerMethodPopToRoot] };
    @synchronized(self) {
        [self.pendingControllers addObject:viewControllerObject];
        
    }
    
    if ([self.pendingControllers count] == 1) {
        [super popToRootViewControllerAnimated:animated];
        
    }
    NSUInteger b = 1;
    NSUInteger e = [self.viewControllers count];
    return [self.viewControllers subarrayWithRange:NSMakeRange(b, e - b)];
    
}

@end
