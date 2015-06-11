//
//  CalloutAnnotation.m
//  Muttro
//
//  Created by Trevor Vieweg on 6/10/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import "CalloutAnnotation.h"

const float kCAAnnotationFrameWidth = 280.0;
const float kCAAnnotationFrameHeight = 140.0;
const float kCAAnnotationFrameOffsetX = 0.0;
const float kCAAnnotationFrameOffsetY = 100.0;
const float kCALabelHeight = 40.0;

@implementation CalloutAnnotation

- (id)initForAnnotation:(SearchAnnotation *)annotation {
    self = [super init];
    
    if (self) {
        _title = annotation.title;
        _coordinate = annotation.coordinate;
        _phoneNumber = annotation.phoneNumber;
        _url = annotation.url;
    }
    
    return self;
}

- (MKAnnotationView *)annotationView {
    
    CGSize size = CGSizeMake(kCAAnnotationFrameWidth, kCAAnnotationFrameHeight);
    CGPoint offset = CGPointMake(kCAAnnotationFrameOffsetX, kCAAnnotationFrameOffsetY);
    
    //Set up view
    MKAnnotationView *view = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"CalloutAnnotation"];
    view.frame = CGRectMake(0.0, 0.0, size.width, size.height);
    view.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
    view.canShowCallout = NO;
    view.centerOffset = offset;
    view.layer.cornerRadius = 10.0;
    
    
    //Add title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, view.bounds.size.width, kCALabelHeight)];
    titleLabel.text = _title;
    [view addSubview:titleLabel];
    
    //Create line divider in view
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, CGRectGetMaxY(titleLabel.frame))];
    [path addLineToPoint:CGPointMake(size.width, CGRectGetMaxY(titleLabel.frame))];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [path CGPath];
    shapeLayer.strokeColor = [[UIColor grayColor] CGColor];
    shapeLayer.lineWidth = 0.5;
    shapeLayer.fillColor = [[UIColor clearColor] CGColor];
    
    [view.layer addSublayer:shapeLayer];
    
    
    return view;

}

@end
