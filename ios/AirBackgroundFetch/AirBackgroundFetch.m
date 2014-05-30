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

typedef void (^AirBackgroundFetchCompletionHandler)(UIBackgroundFetchResult result);

static FREContext AirBackgroundFetchContext;

#pragma mark - Fucntions

DEFINE_ANE_FUNCTION(loadUrl)
{
    NSLog(@"loadURL CALL");
    
    uint32_t string_length;
    const uint8_t *utf8_message;
    NSString* url = NULL;
    if (FREGetObjectAsUTF8(argv[0], &string_length, &utf8_message) == FRE_OK)
        url = [NSString stringWithUTF8String:(char*) utf8_message];
    
    NSString* dataString = nil;
    if (FREGetObjectAsUTF8(argv[1], &string_length, &utf8_message) == FRE_OK)
        dataString = [NSString stringWithUTF8String:(char*) utf8_message];
    
    [FetchUtils.sharedUtils saveURL:url andData:dataString];
    
    return NULL;
}


DEFINE_ANE_FUNCTION(getUserData)
{
    NSString *userData = [FetchUtils.sharedUtils getUserData];
    
    FREObject result;
    if (FRENewObjectFromUTF8( (uint32_t)userData.length, (const uint8_t *)[userData UTF8String], &result) == FRE_OK)
    {
        return result;
    }

    return NULL;
}


DEFINE_ANE_FUNCTION(flushUserData)
{
    [FetchUtils.sharedUtils flushUserData];
    return NULL;
}


#pragma mark - ANE INIT

void AirBackgroundFetchContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx,
                        uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet) 
{
    NSLog(@"Setup background fetch");
    
    static FRENamedFunction functions[] = {
        MAP_FUNCTION(loadUrl, NULL),
        MAP_FUNCTION(getUserData, NULL),
        MAP_FUNCTION(flushUserData, NULL),
    };
    *numFunctionsToTest = sizeof( functions ) / sizeof( FRENamedFunction );
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


#pragma mark - app delegate category

@interface CTAppController : NSObject <UIApplicationDelegate>
@end

@implementation CTAppController (AirBackgroundFetchAdditions)

+ (void)load
{
    [super load];
    NSLog(@"Setup CTAppController");
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    NSLog(@"Perform fetch in category");
    
    FPANE_Log(AirBackgroundFetchContext, @"Perform fetch");
    
    [FetchUtils.sharedUtils fetchUserData];
    
    completionHandler(UIBackgroundFetchResultNoData);
}

@end