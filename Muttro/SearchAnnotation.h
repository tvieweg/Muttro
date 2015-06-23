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

typedef NS_ENUM(NSInteger, FavoriteCategory) {
    FavoriteCategoryNoCategory      = 0,
    FavoriteCategoryPark            = 1,
    FavoriteCategoryVet             = 2,
    FavoriteCategoryGroomers        = 3,
    FavoriteCategoryDayCare         = 4,
    FavoriteCategoryPetStore        = 5
};

@interface SearchAnnotation : NSObject <MKAnnotation, NSCoding>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, assign) CLLocationDistance distanceToUser;

@property (nonatomic, assign) FavoriteState favoriteState;
@property (nonatomic, assign) FavoriteCategory favoriteCategory;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

-(id)initWithMapItem:(MKMapItem *)mapItem; 

-(id)initWithTitle:(NSString *)newTitle Location:(CLLocationCoordinate2D)location;
- (MKAnnotationView *)annotationView;

- (UIImage *) setImageForFavoriteCategory:(NSInteger)favoriteCategory; 

@end
