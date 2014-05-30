//
//  FetchUtils.h
//  AirBackgroundFetch
//
//  Created by jay canty on 5/28/14.
//
//

#import <Foundation/Foundation.h>

@interface FetchUtils : NSObject

+ (id) sharedUtils;

- (void) saveURL:(NSString *)url andData:(NSString *)dataString;
- (void) fetchUserData;
- (NSString *) getUserData;
- (void) flushUserData;

@end
