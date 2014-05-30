//
//  FetchUtils.m
//  AirBackgroundFetch
//
//  Created by jay canty on 5/28/14.
//
//

#import "FetchUtils.h"

#define URL_KEY @"FETCH_URL_KEY"
#define PARAMS_KEY @"FETCH_PARAMS_KEY"
#define USER_DATA_KEY @"FETCH_USER_DATA_KEY"

static FetchUtils *utils = nil;

@interface FetchUtils()

@property (nonatomic, strong) NSUserDefaults *defaults;
@property (nonatomic, strong) NSMutableData *responseData;

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
        _defaults = [NSUserDefaults standardUserDefaults];
    }
    return self;
}


#pragma mark - CUSTOM

-(void) fetchUserData
{
    NSString *url = [self addQueryStringToUrlString:[self getUrl] withDictionary:[self getPostParams]];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    // Don't forget to add timeout!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    urlRequest.HTTPMethod = @"GET";
    
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    
    if (error)
    {
        NSLog(@"ERROR FETCHING: %@", error.userInfo);
        return;
    }
    
    NSLog(@"USER DATA SAVED TO DISK");
    
    [_defaults setObject:[NSString stringWithUTF8String:[data bytes]] forKey:USER_DATA_KEY];
    [_defaults synchronize];
}


- (void) saveURL:(NSString *)url andData:(NSString *)dataString
{
    if (url && dataString)
    {
        NSLog(@"ATTEMPT SAVING TO DISK");
        
        NSError *error = nil;
        NSDictionary *data = [NSJSONSerialization JSONObjectWithData:[dataString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
        
        if (error)
        {
            NSLog(@"ERROR CONVERTING TO DICTIONARY: %@", error);
            return;
        }

        NSLog(@"SUCCESSFUL: %@", data);
        
        [_defaults setObject:url forKey:URL_KEY];
        [_defaults setObject:data forKey:PARAMS_KEY];
        [_defaults synchronize];
    }
}


- (void) flushUserData
{
    [_defaults setObject:nil forKey:USER_DATA_KEY];
    [_defaults synchronize];
}


#pragma mark - HELPERS

-(NSString *) getUrl
{
    return (NSString *)[_defaults objectForKey:URL_KEY];
}

-(NSDictionary *) getPostParams
{
    return (NSDictionary *)[_defaults objectForKey:PARAMS_KEY];
}

-(NSString *) getUserData
{
    return (NSString *)[_defaults objectForKey:USER_DATA_KEY];
}

-(NSString*)urlEscapeString:(NSString *)unencodedString
{
    CFStringRef originalStringRef = (__bridge_retained CFStringRef)unencodedString;
    NSString *s = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,originalStringRef, NULL, NULL,kCFStringEncodingUTF8);
    CFRelease(originalStringRef);
    return s;
}


-(NSString*)addQueryStringToUrlString:(NSString *)urlString withDictionary:(NSDictionary *)dictionary
{
    NSMutableString *urlWithQuerystring = [[NSMutableString alloc] initWithString:urlString];
    
    for (id key in dictionary) {
        NSString *keyString = [key description];
        NSString *valueString = [[dictionary objectForKey:key] description];
        
        if ([urlWithQuerystring rangeOfString:@"?"].location == NSNotFound) {
            [urlWithQuerystring appendFormat:@"?%@=%@", [self urlEscapeString:keyString], [self urlEscapeString:valueString]];
        } else {
            [urlWithQuerystring appendFormat:@"&%@=%@", [self urlEscapeString:keyString], [self urlEscapeString:valueString]];
        }
    }
    return urlWithQuerystring;
}


-(NSString*)getQueryStringFromDictionary:(NSDictionary *)dictionary
{
    NSMutableString *queryString = [[NSMutableString alloc] init];
    
    for (id key in dictionary) {
        NSString *keyString = [key description];
        NSString *valueString = [[dictionary objectForKey:key] description];
        
        if ([queryString length] == 0) {
            [queryString appendFormat:@"%@=%@", [self urlEscapeString:keyString], [self urlEscapeString:valueString]];
        } else {
            [queryString appendFormat:@"&%@=%@", [self urlEscapeString:keyString], [self urlEscapeString:valueString]];
        }
    }
    return queryString;
}


@end
