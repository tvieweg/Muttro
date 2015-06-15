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

typedef void (^NewItemCompletionBlock)(NSError *error);

@interface DataSource : NSObject

@property (nonatomic, strong) MKLocalSearchResponse *searchResults;
@property (nonatomic, assign) MKCoordinateRegion region;
@property (nonatomic, strong, readonly) NSMutableArray *recentSearches;
@property (nonatomic, assign) CLLocationCoordinate2D lastTappedCoordinate;
@property (nonatomic, assign) BOOL locationWasTapped;
@property (nonatomic, strong, readonly) NSMutableArray *favoriteLocations;

- (void) deleteFavoriteItem:(SearchAnnotation *)item;

+(instancetype) sharedInstance;

- (void) searchWithParameters:(NSString *)parameters withCompletionBlock:(NewItemCompletionBlock)completionHandler;

- (void) toggleFavoriteStatus:(SearchAnnotation *)annotation;

@end
