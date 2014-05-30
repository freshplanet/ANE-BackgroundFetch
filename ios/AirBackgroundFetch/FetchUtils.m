//
//  FetchUtils.m
//  AirBackgroundFetch
//
//  Created by jay canty on 5/28/14.
//
//

#import "FetchUtils.h"

#define URL_KEY @"FETCH_URL_KEY"
#define POST_PARAMS_KEY @"FETCH_POST_PARAMS_KEY"

static FetchUtils *utils = nil;

@interface FetchUtils() <NSURLConnectionDelegate>

@property (nonatomic, retain) NSUserDefaults *defaults;
@property (nonatomic, retain) NSMutableData *responseData;

@end


@implementation FetchUtils

+ (id)sharedUtils {
    
    if (utils == nil)
    {
        utils = [[self alloc] init];
    }
    return utils;
}

- (id)init {
    
    if (self = [super init])
    {
        self.defaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}


#pragma mark - FETCH

-(void) fetchUserData
{
    NSLog(@"URL from disk: %@", [self getUrl]);
    NSLog(@"DATA from disk: %@", [self getPostParams]);
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[self getUrl]]];
    
    urlRequest.HTTPMethod = @"POST";
    [urlRequest setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
//    NSString *requestBodyString = [self getQueryStringFromDictionary:[self getPostParams]];
//    
//    NSLog(@"POST PARAMS: %@", requestBodyString);
//    
//    urlRequest.HTTPBody = [requestBodyString dataUsingEncoding:NSUTF8StringEncoding];
//    
//    NSURLResponse * response = nil;
//    NSError * error = nil;
//    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
//                                          returningResponse:&response
//                                                      error:&error];
//    
//    if (error)
//    {
//        NSLog(@"ERROR FETCHING: %@", error.userInfo);
//    }
//    
//    NSLog(@"DID FINISH LOADING - data: %@", [NSString stringWithUTF8String:[data bytes]]);
}



#pragma mark - DISK

- (void) saveURL:(NSString *)url andData:(NSString *)dataString
{
    if (url && dataString)
    {
        NSLog(@"ATTEMPT SAVING TO DISK");
        
        NSError *error = nil;
        id data = [NSJSONSerialization JSONObjectWithData:[dataString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        
        if (error)
        {
            NSLog(@"ERROR CONVERTING TO DICTIONARY: %@", error);
            return;
        }

        NSLog(@"SUCCESSFUL: %@", data);
        
        [_defaults setObject:url forKey:URL_KEY];
        [_defaults setObject:dataString forKey:POST_PARAMS_KEY];
        [_defaults synchronize];
    }
}



#pragma mark - HELPERS

-(NSString *) getUrl
{
    return (NSString *)[_defaults objectForKey:URL_KEY];
}

-(NSDictionary *) getPostParams
{
    return (NSDictionary *)[_defaults objectForKey:POST_PARAMS_KEY];
}


@end
