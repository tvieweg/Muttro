//
//  DataSource.m
//  Muttro
//
//  Created by Trevor Vieweg on 6/8/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import "DataSource.h"
#import "YPAPISearch.h"
#import <AddressBookUI/AddressBookUI.h>


const float kCoordinateEpsilon = 0.005;
const float kDistanceThreshold = 200;
const float kMaxTimeBetweenMapUpdates = 15.0;

@interface DataSource () <CLLocationManagerDelegate> {
    NSMutableArray *_favoriteLocations;
    CLLocation *_currentLocation;
}

@property (nonatomic, strong) NSMutableArray *recentSearches;
@property (nonatomic, strong) NSMutableArray *favoriteLocations;
@property (nonatomic, strong) NSMutableArray *searchResultsAnnotations;
@property (nonatomic, assign) BOOL wasSearchError;

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
        self.wasSearchError = NO;
        self.recentSearches = [NSMutableArray new];
        self.favoriteLocations = [NSMutableArray new];
        self.searchResultsAnnotations = [NSMutableArray new];
        
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
        
        [self startLocationManager];

    }
    return self;
}



#pragma mark - Location Manager

- (void)startLocationManager {
    
    // Create the location manager if this object does not
    // already have one.
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        
    }
    
    //Always active needed for notifications. Uncomment to authorize local notifications
    //[self.locationManager requestAlwaysAuthorization];
    
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;
    
    // Set a movement threshold for new events.
    self.locationManager.distanceFilter = kDistanceThreshold; // meters
    
    [self.locationManager startUpdatingLocation];
    [self.locationManager startMonitoringSignificantLocationChanges]; 
}

- (void) locationManager:(CLLocationManager *)manager
      didUpdateLocations:(NSArray *)locations {
    
    [self checkForNearbyPOIs];
    
    //TODO: If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    
    if (fabs(howRecent) < kMaxTimeBetweenMapUpdates) {
        // If the event is recent, do something with it.
        self.userLocation = location;
        if (self.shouldUpdateMapRegionToUserLocation) {
            self.currentLocation = location;
        }
    }
}

#pragma mark - Notifications
/***Disabled local notifications - uncomment to add back in ***/
- (void) checkForNearbyPOIs {
    
    if (self.favoriteLocations.count > 0) {
        for (SearchAnnotation *favoritePOI in self.favoriteLocations) {
            if (favoritePOI.distanceToUser > 1000) {
                //notification hasn't already recently been sent for this POI.
                
                favoritePOI.distanceToUser = [self findDistanceFromUser:favoritePOI];
                
                if (favoritePOI.distanceToUser < 1000) {
                    
                    //user is within 1000 meters of location, send notification.
                    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
                    
                    localNotif.timeZone = [NSTimeZone defaultTimeZone];
                    
                    localNotif.alertBody = [NSString stringWithFormat:@"Near %@", favoritePOI.title];
                    localNotif.alertAction = NSLocalizedString(@"View Details", nil);
                    localNotif.alertTitle = [NSString stringWithFormat:@"Near %@", favoritePOI.title];
                    
                    localNotif.soundName = UILocalNotificationDefaultSoundName;
                    
                    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
                    
                }
            } else {
                favoritePOI.distanceToUser = [self findDistanceFromUser:favoritePOI];
            }
        }
    }
}

#pragma mark - Search

- (void) searchYelpWithParameters:(NSString *)parameters category:(NSString *)category inLocation:(CLLocation *)location withCompletionBlock:(SearchCompletionBlock)completionHandler {
    self.shouldUpdateMapRegionToUserLocation = NO;

    //include recent search in search history
    [self updateRecentSearches:parameters];
    
    NSMutableString *locationString = [NSMutableString stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude];
    YPAPISearch *APISearch = [[YPAPISearch alloc] init];
    
    dispatch_group_t requestGroup = dispatch_group_create();
    
    dispatch_group_enter(requestGroup);
    
    [APISearch queryYelpInfoForTerm:parameters location:locationString  category:category completionHandler:^(NSDictionary *jsonResponse, NSError *error)  {
                
        if (error != nil) {
            
            self.wasSearchError = YES;
           
            completionHandler(error);
            dispatch_group_leave(requestGroup);

            return;
        }
        
        NSArray *businessArray = jsonResponse[@"businesses"];
        
        if ([businessArray count] == 0) {
            
            self.wasSearchError = YES;
            

            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:@"No results found" forKey:NSLocalizedDescriptionKey];
            // populate the error object with the details
            NSError *noResultsError = [NSError errorWithDomain:@"Nothing Found" code:200 userInfo:details];

            completionHandler(noResultsError);
            dispatch_group_leave(requestGroup);

            return;
            
        } else {
            
            //Set map region
            double tmpLatitude = [jsonResponse[@"region"][@"center"][@"latitude"] floatValue];
            double tmpLongitude = [jsonResponse[@"region"][@"center"][@"longitude"] floatValue];
            double tmpLatitudeDelta =[jsonResponse[@"region"][@"span"][@"latitude_delta"] floatValue];
            double tmpLongitudeDelta =[jsonResponse[@"region"][@"span"][@"longitude_delta"] floatValue];
            CLLocationCoordinate2D tmpCenterCoordinate = CLLocationCoordinate2DMake(tmpLatitude, tmpLongitude);
            MKCoordinateSpan tmpCoordinateSpan = MKCoordinateSpanMake(tmpLatitudeDelta, tmpLongitudeDelta);
            
            self.yelpSearchResultsRegion = MKCoordinateRegionMake(tmpCenterCoordinate, tmpCoordinateSpan);
            
            self.yelpSearchResults = businessArray;
            
            dispatch_group_leave(requestGroup);
            
            return; 
            
        }
        
    }];

    dispatch_group_wait(requestGroup, DISPATCH_TIME_FOREVER); // This avoids the program exiting before all our asynchronous callbacks have been made.
    
    if (self.wasSearchError == NO) {
        [self createAnnotationsForYelpItems:self.yelpSearchResults];
        if (completionHandler) {
            completionHandler(nil);
        }

    } else {
        self.wasSearchError = NO;
    }
    
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

- (NSMutableArray *) checkFavoritesAgainstSearchAndRemoveDuplicates {
    NSMutableArray *itemsToRemove = [NSMutableArray new];
    for (SearchAnnotation *annotation in self.searchResultsAnnotations) {
        
        float searchLat = annotation.coordinate.latitude;
        float searchLong = annotation.coordinate.longitude;
        
        for (SearchAnnotation *favorite in self.favoriteLocations) {
            float favoriteLat = favorite.coordinate.latitude;
            float favoriteLong = favorite.coordinate.longitude;
            if (fabs(searchLat - favoriteLat) <= kCoordinateEpsilon && fabs(searchLong - favoriteLong) <= kCoordinateEpsilon) {
                [itemsToRemove addObject:annotation];
            }
        }
    }
    
    [self.searchResultsAnnotations removeObjectsInArray:itemsToRemove];
    
    return self.searchResultsAnnotations;
}

- (void) createAnnotationsForMapItems:(NSArray *)mapItems {
    [self.searchResultsAnnotations removeAllObjects];
    for (MKMapItem *mapItem in mapItems) {
        SearchAnnotation *annotation = [[SearchAnnotation alloc] initWithMapItem:mapItem];
        
        annotation.distanceToUser = [self findDistanceFromUser:annotation];
        
        [self.searchResultsAnnotations addObject:annotation];
        
    }
}

- (void) createAnnotationsForYelpItems:(NSArray *)yelpItems {
    [self.searchResultsAnnotations removeAllObjects];
    for (NSDictionary *yelpItem in yelpItems) {
        SearchAnnotation *annotation = [[SearchAnnotation alloc] initWithYelpItem:yelpItem];
        
        annotation.distanceToUser = [self findDistanceFromUser:annotation];
        
        [self.searchResultsAnnotations addObject:annotation];
        
    }
}

- (CLLocationDistance) findDistanceFromUser:(SearchAnnotation *)annotation {
    CLLocation *annotationLocation = [[CLLocation alloc] initWithLatitude:
                                      annotation.coordinate.latitude
                                                                longitude:
                                      annotation.coordinate.longitude];
    return [_userLocation distanceFromLocation:annotationLocation];
}

#pragma mark - Favorite toggling

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

- (void) setFavoriteCategory:(SearchAnnotation *)annotation toCategory:(NSInteger)category {
    
    NSInteger index = [self.favoriteLocations indexOfObject:annotation];
    annotation.category = category;
    [self replaceObjectInFavoriteLocationsAtIndex:index withObject:annotation];
    
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
