//
//  SearchAnnotation.h
//  Muttro
//
//  Created by Trevor Vieweg on 6/10/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "FavoritesButton.h"

typedef NS_ENUM(NSInteger, Category) {
    CategoryNoCategory      = 0,
    CategoryPark            = 1,
    CategoryVet             = 2,
    CategoryGroomers        = 3,
    CategoryDayCare         = 4,
    CategoryPetStore        = 5
};

@interface SearchAnnotation : NSObject <MKAnnotation, NSCoding>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign) CLLocationDistance distanceToUser;

@property (nonatomic, assign) FavoriteState favoriteState;
@property (nonatomic, assign) Category category;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

-(id)initWithMapItem:(MKMapItem *)mapItem;

-(id)initWithYelpItem:(NSDictionary *)yelpItem; 

-(id)initWithTitle:(NSString *)newTitle Location:(CLLocationCoordinate2D)location;
- (MKAnnotationView *)annotationView;

- (UIImage *) setImageForCategory:(NSInteger)category;

- (void) setInitialAnnotationCategoryForPOI:(NSDictionary *)yelpItem; 

@end
