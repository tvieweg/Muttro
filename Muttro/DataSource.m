//
//  DataSource.m
//  Muttro
//
//  Created by Trevor Vieweg on 6/8/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//


//TODO: Refactor framework: DataSource should be broken up into searches (which will include recent searches), and POIs saved by the user.

#import "DataSource.h"

@interface DataSource ()

@property (nonatomic, strong) NSMutableArray *recentSearches;

@end

@implementation DataSource

+ (instancetype) sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype) init {
    self = [super init];
    
    if (self) {
        self.recentSearches = [NSMutableArray new];

    }
    return self;
}

- (void) updateRecentSearches:(NSString *)latestSearch {
    
    BOOL shouldBeAdded = YES;
    
    for (NSString *search in self.recentSearches) {
        if ([latestSearch isEqualToString:search]) {
            shouldBeAdded = NO;
        }
    }
    
    if (shouldBeAdded) {
        [self.recentSearches insertObject:latestSearch atIndex:0];
    }
    
    if (self.recentSearches.count > 10) {
        [self.recentSearches removeLastObject];
    }
}

-(void) searchWithParameters:(NSString *)parameters withCompletionBlock:(NewItemCompletionBlock)completionHandler {
    MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
    NSString *parametersWithDogAppended = [parameters stringByAppendingString:@" dog"];
    searchRequest.naturalLanguageQuery = parametersWithDogAppended;
    
    //include recent search in search history
    [self updateRecentSearches:parameters];
    searchRequest.region = self.region;
    
    
    //Show network activity
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
    //Local search.
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:searchRequest];
    
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (error != nil) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Map Error",nil)
                                        message:[error localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] show];
            return;
        }
        
        if ([response.mapItems count] == 0) {
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Results",nil)
                                        message:nil
                                       delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil] show];
            return;
        }
        self.searchResults = response;
        
        if (completionHandler) {
            completionHandler(error);
        }
        
    }];
}

@end
