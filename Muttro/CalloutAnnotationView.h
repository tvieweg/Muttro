//
//  CalloutAnnotationView.h
//  Muttro
//
//  Created by Trevor Vieweg on 6/12/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import <MapKit/MapKit.h>

@class SearchAnnotation; 

@interface CalloutAnnotationView : MKAnnotationView

- (instancetype) initWithAnnotation:(SearchAnnotation *)annotation reuseIdentifier:(NSString *)reuseIdentifier; 

@end
