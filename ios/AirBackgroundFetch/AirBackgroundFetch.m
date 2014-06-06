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
#import "BackgroundFetch.h"
#import "FPANEUtils.h"

DEFINE_ANE_FUNCTION(AirBackgroundFetch_setMinimumBackgroundFetchInterval)
{
    UIApplication *application = [UIApplication sharedApplication];
    if (argc > 0 && [application respondsToSelector:@selector(setMinimumBackgroundFetchInterval:)])
    {
        NSInteger minimumBackgroundFetchInterval = FPANE_FREObjectToInt(argv[0]);
        switch (minimumBackgroundFetchInterval)
        {
            case -1:
                FPANE_Log(context, @"Set minimum background fetch interval to never");
                [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalNever];
                break;
            
            case 0:
                FPANE_Log(context, @"Set minimum background fetch interval to minimum");
                [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
                break;
                
            default:
                FPANE_Log(context, [NSString stringWithFormat:@"Set minimum background fetch interval to %li seconds", (long)minimumBackgroundFetchInterval]);
                [application setMinimumBackgroundFetchInterval:minimumBackgroundFetchInterval];
                break;
        }
    }
    return nil;
}

DEFINE_ANE_FUNCTION(AirBackgroundFetch_cancelAll)
{
    [BackgroundFetch cancelAll];
    return nil;
}

void AirBackgroundFetchContextInitializer(void* extData, const uint8_t* ctxType, FREContext ctx, uint32_t* numFunctionsToTest, const FRENamedFunction** functionsToSet)
{
    if (strcmp((char *)ctxType, "fetch") == 0 || strcmp((char *)ctxType, "remote-notification") == 0)
    {
        BackgroundFetchListFunctions(functionsToSet, numFunctionsToTest);
    }
    else
    {
        static FRENamedFunction functions[] = {
            MAP_FUNCTION(AirBackgroundFetch_setMinimumBackgroundFetchInterval, NULL),
            MAP_FUNCTION(AirBackgroundFetch_cancelAll, NULL)
        };
        *numFunctionsToTest = sizeof(functions) / sizeof(FRENamedFunction);
        *functionsToSet = functions;
    }
}

void AirBackgroundFetchContextFinalizer(FREContext ctx) {}

void AirBackgroundFetchInitializer(void** extDataToSet, FREContextInitializer* ctxInitializerToSet, FREContextFinalizer* ctxFinalizerToSet)
{
	*extDataToSet = NULL;
	*ctxInitializerToSet = &AirBackgroundFetchContextInitializer;
	*ctxFinalizerToSet = &AirBackgroundFetchContextFinalizer;
}

void AirBackgroundFetchFinalizer(void *extData) {}
