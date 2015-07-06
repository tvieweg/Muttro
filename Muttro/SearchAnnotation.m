//
//  SearchAnnotation.m
//  Muttro
//
//  Created by Trevor Vieweg on 6/10/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import "SearchAnnotation.h"
#import "DataSource.h"

@implementation SearchAnnotation

- (id)initWithMapItem:(MKMapItem *)mapItem {
    self = [super init];
    
    if (self) {
        _title = [mapItem name];
        _coordinate = [[mapItem placemark] coordinate];
        _phoneNumber = [mapItem phoneNumber];
        _url = [mapItem url];
        _favoriteState = FavoriteStateNotFavorited;
        _category = CategoryNoCategory;

    }
    return self; 
}

- (id)initWithYelpItem:(NSDictionary *)yelpItem {
    self = [super init];
    
    if (self) {
        _title = yelpItem[@"name"];
        _phoneNumber = yelpItem[@"phone"];
        _url = [NSURL URLWithString:yelpItem[@"url"]];
        _favoriteState = FavoriteStateNotFavorited;
        [self setInitialAnnotationCategoryForPOI:yelpItem];
        NSDictionary *tmpLocation = yelpItem[@"location"][@"coordinate"];
        double tmpLatitude = [tmpLocation[@"latitude"] floatValue];
        double tmpLongitude = [tmpLocation[@"longitude"] floatValue];
        _coordinate = CLLocationCoordinate2DMake(tmpLatitude, tmpLongitude);
        

    }
    return self;
}

- (void) setInitialAnnotationCategoryForPOI:(NSDictionary *)yelpItem {
    for (NSArray *category in yelpItem[@"categories"]) {
        NSString *categoryFilter = category[1];
        if ([categoryFilter isEqualToString:@"dog_parks"]) {
            
            _category = CategoryPark;
            
        } else if ([categoryFilter isEqualToString:@"vet"]){
            
            _category = CategoryVet;
            
        } else if ([categoryFilter isEqualToString:@"groomer"]) {
            
            _category = CategoryGroomers;
            
        } else if ([categoryFilter isEqualToString:@"pet_sitting"] || [categoryFilter isEqualToString:@"dogwalkers"]) {
            
            _category = CategoryDayCare;
            
        } else if ([categoryFilter isEqualToString:@"petstore"]) {
            
            _category = CategoryPetStore;
            
        }
    }
}

- (id)initWithTitle:(NSString *)newTitle Location:(CLLocationCoordinate2D)location {
    
    self = [super init];
    
    if (self) {
        _title = newTitle;
        _coordinate = location;
    }
    
    return self;
}

- (MKAnnotationView *)annotationView {
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"SearchAnnotation"];

    annotationView.enabled = YES;
    annotationView.canShowCallout = NO;

    UIImage *tmpImage = [self setImageForCategory:self.category];
    annotationView.image = tmpImage;

    return annotationView;
}

- (UIImage *) setImageForCategory:(NSInteger)category {
    switch (category) {
        case CategoryNoCategory:
            return [UIImage imageNamed:@"pawprint-coral"];
            break;
        case CategoryPark:
            return [UIImage imageNamed:@"park"];
            break;
        case CategoryGroomers:
            return [UIImage imageNamed:@"grooming"];
            break;
        case CategoryPetStore:
            return [UIImage imageNamed:@"petstore"];
            break;
        case CategoryDayCare:
            return [UIImage imageNamed:@"daycare"];
            break;
        case CategoryVet:
            return [UIImage imageNamed:@"vet"];
            break;
        default:
            return [UIImage imageNamed:@"pawprint"];
            break;
    }
}

#pragma mark - NSCoding

-(void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.title forKey:NSStringFromSelector(@selector(title))];
    [aCoder encodeObject:self.phoneNumber forKey:NSStringFromSelector(@selector(phoneNumber))];
    [aCoder encodeObject:self.url forKey:NSStringFromSelector(@selector(url))];
    [aCoder encodeInt:self.favoriteState forKey:NSStringFromSelector(@selector(favoriteState))];
    [aCoder encodeInt:self.category forKey:NSStringFromSelector(@selector(category))];
    [aCoder encodeDouble:self.coordinate.latitude forKey:@"latitude"];
    [aCoder encodeDouble:self.coordinate.longitude forKey:@"longitude"];

}

-(instancetype) initWithCoder:(NSCoder *)aDecoder {
    
    self = [super init];
    
    if (self) {
        _title = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(title))];
        _phoneNumber = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(phoneNumber))];
        _url = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(url))];
        _favoriteState = [aDecoder decodeIntForKey:NSStringFromSelector(@selector(favoriteState))];
        _category = [aDecoder decodeIntForKey:NSStringFromSelector(@selector(category))];
        CLLocationDegrees latitude = [aDecoder decodeDoubleForKey:@"latitude"];
        CLLocationDegrees longitude = [aDecoder decodeDoubleForKey:@"longitude"];
        _coordinate = CLLocationCoordinate2DMake(latitude, longitude);

    }
    
    return self; 
}

@end
