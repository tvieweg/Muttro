//
//  DataSource.h
//  Muttro
//
//  Created by Trevor Vieweg on 6/8/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "CalloutAnnotation.h"
#import "SearchAnnotation.h"

typedef void (^SearchCompletionBlock)(NSError *error);

@interface DataSource : NSObject

@property (nonatomic, strong) MKLocalSearchResponse *searchResults;
@property (nonatomic, assign) MKCoordinateRegion region;
@property (nonatomic, strong, readonly) NSMutableArray *recentSearches;
@property (nonatomic, strong, readonly) NSMutableArray *searchResultsAnnotations;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (assign, nonatomic) BOOL shouldUpdateMapRegionToUserLocation;


@property (nonatomic, assign) SearchAnnotation *lastTappedAnnotation;
@property (nonatomic, assign) BOOL locationWasTapped;
@property (nonatomic, strong, readonly) NSMutableArray *favoriteLocations;

@property (nonatomic, strong) NSURL *selectedAnnotationURL; 

@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocation *userLocation; 

- (void) deleteFavoriteItem:(SearchAnnotation *)item;

+(instancetype) sharedInstance;

- (void) searchWithParameters:(NSString *)parameters withCompletionBlock:(SearchCompletionBlock)completionHandler;

- (void) toggleFavoriteStatus:(SearchAnnotation *)annotation;

- (void) setFavoriteCategory:(SearchAnnotation *)annotation toCategory:(NSInteger)category;

- (NSMutableArray *) checkFavoritesAgainstSearchAndRemoveDuplicates;

- (CLLocationDistance) findDistanceFromUser:(SearchAnnotation *)annotation; 

@end
