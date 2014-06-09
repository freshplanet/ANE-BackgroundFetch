//////////////////////////////////////////////////////////////////////////////////////
//
//  Copyright 2012 Freshplanet (http://freshplanet.com | opensource@freshplanet.com)
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//////////////////////////////////////////////////////////////////////////////////////

#import "CTAppController+AirBackgroundFetchAdditions.h"
#import "BackgroundFetch.h"
#import <objc/runtime.h>

@implementation CTAppController (AirBackgroundFetchAdditions)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleMethodWithOriginalSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)
                               swizzledSelector:@selector(ABF_application:didReceiveRemoteNotification:fetchCompletionHandler:)];
    });
}

+ (void)swizzleMethodWithOriginalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector
{
    // For more information about method swizzling: http://nshipster.com/method-swizzling/
    Class class = [self class];
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod)
    {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else
    {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    [BackgroundFetch performFetchWithBackgroundMode:@"fetch" completionHandler:completionHandler];
}

- (void)ABF_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    if ([self respondsToSelector:@selector(application:didReceiveRemoteNotification:)])
    {
        [self application:application didReceiveRemoteNotification:userInfo];
    }
    else if ([self respondsToSelector:@selector(ABF_application:didReceiveRemoteNotification:fetchCompletionHandler:)])
    {
        [self ABF_application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
    }
    
    if (application.applicationState == UIApplicationStateBackground)
    {
        [BackgroundFetch performFetchWithBackgroundMode:@"remote-notification" completionHandler:completionHandler];
    }
}

@end
