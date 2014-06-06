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

#import "BackgroundFetch.h"

@interface BackgroundFetch ()

@property (nonatomic, readonly) NSString *backgroundMode;
@property (nonatomic, readonly) NSString *url;
@property (nonatomic, strong) NSData *data;

@end

@implementation BackgroundFetch

static NSMutableArray *instances;

+ (void)load
{
    [super load];
    
    instances = [NSMutableArray array];
    NSArray *serializedInstances = [[NSUserDefaults standardUserDefaults] arrayForKey:@"AirBackgroundFetch_Instances"];
    if (serializedInstances)
    {
        for (NSData *serializedInstance in serializedInstances)
        {
            [instances addObject:[NSKeyedUnarchiver unarchiveObjectWithData:serializedInstance]];
        }
        NSLog(@"[BackgroundFetch] Loaded %lu instances from disk", [instances count]);
    }
    else
    {
        NSLog(@"[BackgroundFetch] No instances loaded from disk");
    }
}

+ (NSArray *)instancesWithBackgroundMode:(NSString *)backgroundMode
{
    return [instances filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"backgroundMode = %@", backgroundMode]];
}

+ (instancetype)instanceWithBackgroundMode:(NSString *)backgroundMode url:(NSString *)url
{
    for (BackgroundFetch *instance in [self instancesWithBackgroundMode:backgroundMode])
    {
        if ([instance.url isEqualToString:url])
        {
            return instance;
        }
    }
    
    return nil;
}

+ (void)writeInstancesToDisk
{
    NSMutableArray *serializedInstances = [NSMutableArray array];
    for (BackgroundFetch *backgroundFetch in instances)
    {
        [serializedInstances addObject:[NSKeyedArchiver archivedDataWithRootObject:backgroundFetch]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:serializedInstances forKey:@"AirBackgroundFetch_Instances"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"[BackgroundFetch] Saved %lu instances to disk", [serializedInstances count]);
}

+ (void)performFetchWithBackgroundMode:(NSString *)backgroundMode completionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    UIBackgroundFetchResult aggregateResult = UIBackgroundFetchResultNoData;
    for (BackgroundFetch *backgroundFetch in [self instancesWithBackgroundMode:backgroundMode])
    {
        UIBackgroundFetchResult result = [backgroundFetch performFetch];
        if (result == UIBackgroundFetchResultNewData)
        {
            aggregateResult = UIBackgroundFetchResultNewData;
        }
        else if (result == UIBackgroundFetchResultFailed && aggregateResult == UIBackgroundFetchResultNoData)
        {
            aggregateResult = UIBackgroundFetchResultFailed;
        }
    }
    completionHandler(aggregateResult);
}

+ (void)cancelAll
{
    [instances removeAllObjects];
    NSLog(@"Cancelled all instances");
    [self writeInstancesToDisk];
}

- (instancetype)initWithContext:(FREContext)context backgroundMode:(NSString *)backgroundMode url:(NSString *)url
{
    self = [super init];
    if (self)
    {
        _context = context;
        _backgroundMode = backgroundMode;
        _url = url;
        NSLog(@"[BackgroundFetch] Created new %@ instance with URL: %@", backgroundMode, url);
        [instances addObject:self];
        [BackgroundFetch writeInstancesToDisk];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self)
    {
        _backgroundMode = [decoder decodeObjectForKey:@"backgroundMode"];
        _url = [decoder decodeObjectForKey:@"url"];
        _data = [decoder decodeObjectForKey:@"data"];
        NSLog(@"[BackgroundFetch] Loaded %@ instance from disk with URL: %@", _backgroundMode, _url);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.backgroundMode forKey:@"backgroundMode"];
    [encoder encodeObject:self.url forKey:@"url"];
    [encoder encodeObject:self.data forKey:@"data"];
}

- (void)cancel
{
    [instances removeObject:self];
    NSLog(@"[BackgroundFetch] Cancelled %@ instance with URL: %@", _backgroundMode, _url);
    [BackgroundFetch writeInstancesToDisk];
}

- (void)setData:(NSData *)data
{
    _data = data;
    NSLog(@"[BackgroundFetch] Set %lu bytes of data on %@ instance with URL: %@", [data length], self.backgroundMode, self.url);
    [BackgroundFetch writeInstancesToDisk];
}

- (UIBackgroundFetchResult)performFetch
{
    NSLog(@"[BackgroundFetch] Performing fetch for URL: %@", self.url);
    
    NSURL *url = [NSURL URLWithString:self.url];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSURLResponse *response;
    NSError *error;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    if (data && ![data isEqualToData:self.data])
    {
        NSLog(@"[BackgroundFetch] Fetched %lu bytes of data", [data length]);
        self.data = data;
        if (self.context)
        {
            FPANE_DispatchEvent(self.context, @"DID_FETCH_DATA");
        }
        return UIBackgroundFetchResultNewData;
    }
    else if (!data)
    {
        NSLog(@"[BackgroundFetch] Failed with error: %@", error);
        return UIBackgroundFetchResultFailed;
    }
    return UIBackgroundFetchResultNoData;
}

@end

DEFINE_ANE_FUNCTION(AirBackgroundFetch_init)
{
    NSString *backgroundMode = FPANE_FREObjectToNSString(argv[0]);
    NSString *url = FPANE_FREObjectToNSString(argv[1]);
    
    BackgroundFetch *backgroundFetch = [BackgroundFetch instanceWithBackgroundMode:backgroundMode url:url];
    if (backgroundFetch)
    {
        backgroundFetch.context = context;
    }
    else
    {
        backgroundFetch = [[BackgroundFetch alloc] initWithContext:context backgroundMode:backgroundMode url:url];
    }
    
    FRESetContextNativeData(context, (__bridge void *)backgroundFetch);
    
    return nil;
}

DEFINE_ANE_FUNCTION(AirBackgroundFetch_cancel)
{
    void *nativeData;
    FREGetContextNativeData(context, &nativeData);
    BackgroundFetch *backgroundFetch = (__bridge BackgroundFetch *)nativeData;
    [backgroundFetch cancel];
    
    return nil;
}

DEFINE_ANE_FUNCTION(AirBackgroundFetch_getBackgroundMode)
{
    void *nativeData;
    FREGetContextNativeData(context, &nativeData);
    BackgroundFetch *backgroundFetch = (__bridge BackgroundFetch *)nativeData;
    
    return FPANE_NSStringToFREObject(backgroundFetch.backgroundMode);
}

DEFINE_ANE_FUNCTION(AirBackgroundFetch_getURL)
{
    void *nativeData;
    FREGetContextNativeData(context, &nativeData);
    BackgroundFetch *backgroundFetch = (__bridge BackgroundFetch *)nativeData;
    NSLog(@"URL: %@", backgroundFetch.url);
    return FPANE_NSStringToFREObject(backgroundFetch.url);
}

DEFINE_ANE_FUNCTION(AirBackgroundFetch_getData)
{
    void *nativeData;
    FREGetContextNativeData(context, &nativeData);
    BackgroundFetch *backgroundFetch = (__bridge BackgroundFetch *)nativeData;
    NSString *jsonData = [[NSString alloc] initWithData:backgroundFetch.data encoding:NSUTF8StringEncoding];
    
    return FPANE_NSStringToFREObject(jsonData);
}

DEFINE_ANE_FUNCTION(AirBackgroundFetch_clearData)
{
    void *nativeData;
    FREGetContextNativeData(context, &nativeData);
    BackgroundFetch *backgroundFetch = (__bridge BackgroundFetch *)nativeData;
    backgroundFetch.data = nil;
    
    return nil;
}

void BackgroundFetchListFunctions(const FRENamedFunction **functionsToSet, uint32_t *numFunctionsToTest)
{
    static FRENamedFunction functions[] = {
        MAP_FUNCTION(AirBackgroundFetch_init, NULL),
        MAP_FUNCTION(AirBackgroundFetch_cancel, NULL),
        MAP_FUNCTION(AirBackgroundFetch_getBackgroundMode, NULL),
        MAP_FUNCTION(AirBackgroundFetch_getURL, NULL),
        MAP_FUNCTION(AirBackgroundFetch_getData, NULL),
        MAP_FUNCTION(AirBackgroundFetch_clearData, NULL)
    };
    *numFunctionsToTest = sizeof(functions) / sizeof(FRENamedFunction);
    *functionsToSet = functions;
}
