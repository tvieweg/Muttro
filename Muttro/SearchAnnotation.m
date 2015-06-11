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
    annotationView.image = [UIImage imageNamed:@"pawprint"];
    
    return annotationView; 
}

@end
