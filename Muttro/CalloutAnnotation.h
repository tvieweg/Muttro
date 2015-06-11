//
//  CalloutAnnotation.h
//  Muttro
//
//  Created by Trevor Vieweg on 6/10/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "SearchAnnotation.h"

@interface CalloutAnnotation : NSObject <MKAnnotation>

- (id)initForAnnotation:(SearchAnnotation *)annotation;
- (MKAnnotationView *)annotationView;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;
@property (nonatomic, copy) NSString *phoneNumber;
@property (nonatomic, strong) NSURL *url;


@end
