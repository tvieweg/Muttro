//
//  DataSource.h
//  Muttro
//
//  Created by Trevor Vieweg on 6/8/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

typedef void (^NewItemCompletionBlock)(NSError *error);

@interface DataSource : NSObject

@property (nonatomic, strong) MKLocalSearchResponse *searchResults;
@property (nonatomic, assign) MKCoordinateRegion region;
@property (nonatomic, strong, readonly) NSMutableArray *recentSearches;
@property (nonatomic, strong) MKMapItem *lastTappedItem;

+(instancetype) sharedInstance;

- (void) searchWithParameters:(NSString *)parameters withCompletionBlock:(NewItemCompletionBlock)completionHandler;

@end
