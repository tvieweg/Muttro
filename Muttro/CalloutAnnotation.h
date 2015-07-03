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
#import "CalloutAnnotationView.h"

@interface CalloutAnnotation : NSObject <MKAnnotation>

- (id)initForAnnotation:(SearchAnnotation *)annotation;
- (CalloutAnnotationView *)annotationView;

@property (nonatomic, strong) CalloutAnnotationView *view;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (copy, nonatomic) NSString *title;
@property (nonatomic, strong) SearchAnnotation *searchAnnotation;

- (void) setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
