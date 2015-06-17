//
//  SearchAnnotation.m
//  Muttro
//
//  Created by Trevor Vieweg on 6/10/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import "SearchAnnotation.h"

@implementation SearchAnnotation

- (id)initWithMapItem:(MKMapItem *)mapItem {
    self = [super init];
    
    if (self) {
        _title = [mapItem name];
        _coordinate = [[mapItem placemark] coordinate];
        _phoneNumber = [mapItem phoneNumber];
        _url = [mapItem url];
        _favoriteState = FavoriteStateNotFavorited; 

    }
    return self; 
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
    if(self.favoriteState == FavoriteStateFavorited) {
        annotationView.image = [UIImage imageNamed:@"pawprint-yellow"];
    } else {
        annotationView.image = [UIImage imageNamed:@"pawprint"];
    }
    
    return annotationView; 
}


#pragma mark - NSCoding

-(void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.title forKey:NSStringFromSelector(@selector(title))];
    [aCoder encodeObject:self.phoneNumber forKey:NSStringFromSelector(@selector(phoneNumber))];
    [aCoder encodeObject:self.url forKey:NSStringFromSelector(@selector(url))];
    [aCoder encodeInt:self.favoriteState forKey:NSStringFromSelector(@selector(favoriteState))];
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
        CLLocationDegrees latitude = [aDecoder decodeDoubleForKey:@"latitude"];
        CLLocationDegrees longitude = [aDecoder decodeDoubleForKey:@"longitude"];
        _coordinate = CLLocationCoordinate2DMake(latitude, longitude);

    }
    
    return self; 
}

@end
