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

#import "AirBackgroundFetch.h"
#import "FPANEUtils.h"
#import <objc/runtime.h>

typedef void (^AirBackgroundFetchCompletionHandler)(UIBackgroundFetchResult result);

static FREContext AirBackgroundFetchContext;

void AirBackgroundFetchApplicationPerformFetchWithCompletionHandler(id self, SEL _cmd, UIApplication *application, AirBackgroundFetchCompletionHandler completionHandler)
{
    NSLog(@"Perform fetch");
    FPANE_Log(AirBackgroundFetchContext, @"Perform fetch");
    completionHandler(UIBackgroundFetchResultNoData);
}

void AirBackgroundFetchContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx,
                        uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) 
{
    NSLog(@"Setup background fetch");
    static FRENamedFunction functions[] = {};
    *numFunctionsToTest = sizeof(functions)/sizeof(FRENamedFunction);
    *functionsToSet = functions;
    
    AirBackgroundFetchContext = ctx;
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
}

void AirBackgroundFetchContextFinalizer(FREContext ctx) { }

void AirBackgroundFetchInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
{
    NSLog(@"AirBackgroundFetchInitializer");
    
	*extDataToSet = NULL;
	*ctxInitializerToSet = &AirBackgroundFetchContextInitializer;
	*ctxFinalizerToSet = &AirBackgroundFetchContextFinalizer;
}

void AirBackgroundFetchFinalizer(void *extData) { }

@interface CTAppController : NSObject <UIApplicationDelegate>
@end

@implementation CTAppController (AirBackgroundFetchAdditions)

+ (void)load
{
    [super load];
    
    NSLog(@"Setup CTAppController");
    class_replaceMethod(self, @selector(application:performFetchWithCompletionHandler:), (IMP)&AirBackgroundFetchApplicationPerformFetchWithCompletionHandler, "v@:@@?");
}

@end