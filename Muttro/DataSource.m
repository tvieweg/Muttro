//
//  DataSource.m
//  Muttro
//
//  Created by Trevor Vieweg on 6/8/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//


//TODO: Refactor framework: DataSource should be broken up into searches (which will include recent searches), and POIs saved by the user.

#import "DataSource.h"

@interface DataSource () {
    NSMutableArray *_favoriteLocations;
}

@property (nonatomic, strong) NSMutableArray *recentSearches;
@property (nonatomic, strong) NSMutableArray *favoriteLocations;

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
        
        //initialize arrays.
        self.recentSearches = [NSMutableArray new];
        self.favoriteLocations = [NSMutableArray new];
        
        //Make requests to get objects from KeyedArchiver
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(favoriteLocations))];
            NSArray *storedMediaItems = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
            
            //If items, add to array.
            dispatch_async(dispatch_get_main_queue(), ^{
                if (storedMediaItems.count > 0) {
                    NSMutableArray *mutableMediaItems = [storedMediaItems mutableCopy];
                    self.favoriteLocations = mutableMediaItems;
                    
                }
            });
        });
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(recentSearches))];
            NSArray *storedMediaItems = [NSKeyedUnarchiver unarchiveObjectWithFile:fullPath];
            
            //If items, add to array.
            dispatch_async(dispatch_get_main_queue(), ^{
                if (storedMediaItems.count > 0) {
                    NSMutableArray *mutableMediaItems = [storedMediaItems mutableCopy];
                    self.recentSearches = mutableMediaItems;                    
                }
            });
        });

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
    
    //Save to disk.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *recentSearchItemsToSave = self.recentSearches;
        
        NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(recentSearches))];
        NSData *recentSearchData = [NSKeyedArchiver archivedDataWithRootObject:recentSearchItemsToSave];
        
        NSError *dataError;
        BOOL wroteSuccessfully = [recentSearchData writeToFile:fullPath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
        
        if (!wroteSuccessfully) {
            NSLog(@"Couldn't write file: %@", dataError);
        }
    });
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
    
    if (localSearch.isSearching) {
        //TODO: Add log to see if this is actually working. 
        return;
        
    } else {
        
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
}

- (void) toggleFavoriteStatus:(SearchAnnotation *)annotation {
    if (annotation.favoriteState == FavoriteStateNotFavorited) {
        annotation.favoriteState = FavoriteStateFavoriting;
        
        [self addFavoriteLocationsObject:annotation];
        annotation.favoriteState = FavoriteStateFavorited;
        
        
    } else if (annotation.favoriteState == FavoriteStateFavorited) {
        annotation.favoriteState = FavoriteStateUnFavoriting;
        
        [self deleteFavoriteItem:annotation];
        annotation.favoriteState = FavoriteStateNotFavorited;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUInteger numberOfItemsToSave = MIN(self.favoriteLocations.count, 50);
        NSArray *favoritesToSave = [self.favoriteLocations subarrayWithRange:NSMakeRange(0, numberOfItemsToSave)];
        
        NSString *fullPath = [self pathForFilename:NSStringFromSelector(@selector(favoriteLocations))];
        NSData *favoriteData = [NSKeyedArchiver archivedDataWithRootObject:favoritesToSave];
        
        NSError *dataError;
        BOOL wroteSuccessfully = [favoriteData writeToFile:fullPath options:NSDataWritingAtomic | NSDataWritingFileProtectionCompleteUnlessOpen error:&dataError];
        
        if (!wroteSuccessfully) {
            NSLog(@"Couldn't write file: %@", dataError);
        }
    });
        

}

#pragma mark - Filepath definition

- (NSString *) pathForFilename:(NSString *) filename {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths firstObject];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:filename];
    return dataPath;
}

#pragma mark - Key/Value Observing

- (NSUInteger) countOfFavoriteLocations {
    return self.favoriteLocations.count;
}

- (id) objectInFavoriteLocationsAtIndex:(NSUInteger)index {
    return [self.favoriteLocations objectAtIndex:index];
}

- (NSArray *) favoriteLocationsAtIndexes:(NSIndexSet *)indexes {
    return [self.favoriteLocations objectsAtIndexes:indexes];
}

- (void) insertObject:(SearchAnnotation *)object inFavoriteLocationsAtIndex:(NSUInteger)index {
    [_favoriteLocations insertObject:object atIndex:index];
}

- (void) removeObjectFromFavoriteLocationsAtIndex:(NSUInteger)index {
    [_favoriteLocations removeObjectAtIndex:index];
}

- (void) replaceObjectInFavoriteLocationsAtIndex:(NSUInteger)index withObject:(id)object {
    [_favoriteLocations replaceObjectAtIndex:index withObject:object]; 
}

- (void) deleteFavoriteItem:(SearchAnnotation *)annotation {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"favoriteLocations"];
    [mutableArrayWithKVO removeObject:annotation];
}

- (void) addFavoriteLocationsObject:(SearchAnnotation *)annotation {
    NSMutableArray *mutableArrayWithKVO = [self mutableArrayValueForKey:@"favoriteLocations"];
    [mutableArrayWithKVO addObject:annotation];


}

@end