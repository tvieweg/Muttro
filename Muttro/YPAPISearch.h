//
//  YPAPISearch.h
//  YelpAPI
//

#import <Foundation/Foundation.h>
#import "NSURLRequest+OAuth.h"

/**
 Sample class for accessing the Yelp API V2.

 This class demonstrates the capability of the Yelp API version 2.0 by using the Search API to
 query for businesses by a search term and location, and the Business API to query additional
 information about the top result from the search query.

 See the Yelp Documentation http://www.yelp.com/developers/documentation for more info.
 */
@interface YPAPISearch : NSObject

/**
 Query the Yelp API with a given term and location and displays the progress in the log
 
 @param term: The term of the search, e.g: dinner
 @param location: The location in which the term should be searched for, e.g: San Francisco, CA
 */
- (void)queryYelpInfoForTerm:(NSString *)term location:(NSString *)location category:(NSString *)category completionHandler:(void (^)(NSDictionary *jsonResponse, NSError *error))completionHandler;

@end
