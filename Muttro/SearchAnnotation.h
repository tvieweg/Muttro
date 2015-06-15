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

@interface SearchAnnotation : NSObject <MKAnnotation, NSCoding>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, strong) NSURL *url;

@property (nonatomic, assign) FavoriteState favoriteState;

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

-(id)initWithMapItem:(MKMapItem *)mapItem; 

-(id)initWithTitle:(NSString *)newTitle Location:(CLLocationCoordinate2D)location;
- (MKAnnotationView *)annotationView; 

@end
