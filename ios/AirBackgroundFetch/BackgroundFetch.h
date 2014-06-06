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

#import "FlashRuntimeExtensions.h"
#import "FPANEUtils.h"

@interface BackgroundFetch : NSObject <NSCoding>

@property (nonatomic) FREContext context;

+ (NSArray *)instancesWithBackgroundMode:(NSString *)backgroundMode;
+ (instancetype)instanceWithBackgroundMode:(NSString *)backgroundMode url:(NSString *)url;
+ (void)writeInstancesToDisk;
+ (void)performFetchWithBackgroundMode:(NSString *)backgroundMode completionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler;
+ (void)cancelAll;

- (instancetype)initWithContext:(FREContext)context backgroundMode:(NSString *)backgroundMode url:(NSString *)url;
- (void)cancel;
- (UIBackgroundFetchResult)performFetch;

@end

void BackgroundFetchListFunctions(const FRENamedFunction **functionsToSet, uint32_t *numFunctionsToTest);