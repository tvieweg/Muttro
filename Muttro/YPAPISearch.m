//
//  YPAPISearch.m
//  YelpAPI

#import "YPAPISearch.h"

/**
 Default paths and search terms used in this example
 */
static NSString * const kAPIHost           = @"api.yelp.com";
static NSString * const kSearchPath        = @"/v2/search/";
static NSString * const kSearchLimit       = @"20";
static NSString * const kRadiusFilter      = @"25000"; //approx 15 miles

@interface YPAPISearch ()

@end

@implementation YPAPISearch

#pragma mark - Public

- (void)queryYelpInfoForTerm:(NSString *)term location:(NSString *)location category:(NSString *)category completionHandler:(void (^)(NSDictionary *jsonResponse, NSError *error))completionHandler {

  NSLog(@"Querying the Search API with term \'%@\' and location \'%@'", term, location);
  
  NSURLRequest *searchRequest = [self _searchRequestWithTerm:term category:category location:location];
  NSURLSession *session = [NSURLSession sharedSession];
    
  [[session dataTaskWithRequest:searchRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

    if (!error && httpResponse.statusCode == 200) {

      NSDictionary *searchResponseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];

      if (searchResponseJSON) {
          
        completionHandler(searchResponseJSON, error); //return response
          return;
      }
    } else {
      
        completionHandler(nil, error); // An error happened or the HTTP response is not a 200 OK
        return; 
    
    }
    }] resume];
}


#pragma mark - API Request Builders

/**
 Builds a request to hit the search endpoint with the given parameters.
 
 @param term The term of the search, e.g: dinner
 @param location The location request, e.g: San Francisco, CA

 @return The NSURLRequest needed to perform the search
 */
- (NSURLRequest *)_searchRequestWithTerm:(NSString *)term category:category location:(NSString *)location {
  
    NSDictionary *params = [[NSDictionary alloc] init];
    if ([category isEqualToString:@"All"]) {
        params = @{
                 @"term": term,
                 @"ll": location,
                 @"limit": kSearchLimit,
                 @"radius_filter" : kRadiusFilter
                 };

    } else {
        params = @{
                 @"term": term,
                 @"ll": location,
                 @"limit": kSearchLimit,
                 @"category_filter": category,
                 @"radius_filter" : kRadiusFilter
                 };

    }
    
  return [NSURLRequest requestWithHost:kAPIHost path:kSearchPath params:params];
}

@end
