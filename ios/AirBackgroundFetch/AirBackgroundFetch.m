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
#import "FetchUtils.h"
#import <objc/runtime.h>

DEFINE_ANE_FUNCTION(AirBackgroundFetchSetFetchURL)
{
    NSString *url = FPANE_FREObjectToNSString(argv[0]);
    NSString *jsonParams = FPANE_FREObjectToNSString(argv[1]);
    [FetchUtils.sharedUtils saveURL:url andData:jsonParams];
    
    return nil;
}

DEFINE_ANE_FUNCTION(AirBackgroundFetchGetFetchedData)
{
    return FPANE_NSStringToFREObject([FetchUtils.sharedUtils getUserData]);
}

DEFINE_ANE_FUNCTION(AirBackgroundFetchClearFetchedData)
{
    [FetchUtils.sharedUtils flushUserData];
    return nil;
}


#pragma mark - ANE INIT

void AirBackgroundFetchContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx,
                        uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) 
{
    static FRENamedFunction functions[] = {
        MAP_FUNCTION(AirBackgroundFetchSetFetchURL, NULL),
        MAP_FUNCTION(AirBackgroundFetchGetFetchedData, NULL),
        MAP_FUNCTION(AirBackgroundFetchClearFetchedData, NULL),
    };
    *numFunctionsToTest = sizeof( functions ) / sizeof( FRENamedFunction );
    *functionsToSet = functions;
    
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
}

void AirBackgroundFetchContextFinalizer(FREContext ctx) { }

void AirBackgroundFetchInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
{
	*extDataToSet = NULL;
	*ctxInitializerToSet = &AirBackgroundFetchContextInitializer;
	*ctxFinalizerToSet = &AirBackgroundFetchContextFinalizer;
}

void AirBackgroundFetchFinalizer(void *extData) { }


#pragma mark - app delegate category

@interface CTAppController : NSObject <UIApplicationDelegate>
@end

@implementation CTAppController (AirBackgroundFetchAdditions)

+ (void)load
{
    [super load];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    [FetchUtils.sharedUtils fetchUserData];
    
    completionHandler(UIBackgroundFetchResultNewData);
}

@end