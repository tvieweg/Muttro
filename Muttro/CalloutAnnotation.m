//
//  CalloutAnnotation.m
//  Muttro
//
//  Created by Trevor Vieweg on 6/10/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import "CalloutAnnotation.h"
#import "CalloutAnnotationView.h"
#import "DataSource.h"

@interface CalloutAnnotation ()


@end

@implementation CalloutAnnotation

- (id)initForAnnotation:(SearchAnnotation *)annotation {
    self = [super init];
    
    if (self) {
        _searchAnnotation = annotation; 
        _title = annotation.title;
        _coordinate = annotation.coordinate;
    }
    
    return self;
}

- (CalloutAnnotationView *)annotationView {
    
    self.view = [[CalloutAnnotationView alloc] initWithAnnotation:self.searchAnnotation reuseIdentifier:@"CalloutAnnotation"];
    
    return self.view;

}

@end
