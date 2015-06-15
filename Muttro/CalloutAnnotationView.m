//
//  CalloutAnnotationView.m
//  Muttro
//
//  Created by Trevor Vieweg on 6/12/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import "FavoritesButton.h"
#import "CalloutAnnotationView.h"
#import "DataSource.h"

const float kCAAnnotationFrameWidth = 280.0;
const float kCAAnnotationFrameHeight = 140.0;
const float kCAAnnotationFrameOffsetX = 0.0;
const float kCAAnnotationFrameOffsetY = 100.0;
const float kCALabelHeight = 40.0;

@interface CalloutAnnotationView ()

@property (nonatomic, strong) FavoritesButton *favoriteButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) SearchAnnotation *searchAnnotation;

@end

@implementation CalloutAnnotationView

- (instancetype) initWithAnnotation:(SearchAnnotation *)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super init];
    
    if (self) {
        
        self.searchAnnotation = annotation;
        
        CGSize size = CGSizeMake(kCAAnnotationFrameWidth, kCAAnnotationFrameHeight);
        CGPoint offset = CGPointMake(kCAAnnotationFrameOffsetX, kCAAnnotationFrameOffsetY);
        
        self.frame = CGRectMake(0.0, 0.0, size.width, size.height);
        self.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
        self.canShowCallout = NO;
        self.centerOffset = offset;
        self.layer.cornerRadius = 10.0;
        
        //Add title
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.bounds.size.width - 50, kCALabelHeight)];
        self.titleLabel.text = self.searchAnnotation.title;
        [self addSubview:self.titleLabel];
        
        //Add favorites button
        self.favoriteButton = [[FavoritesButton alloc] init];
        [self.favoriteButton setFavoriteButtonState:self.searchAnnotation.favoriteState]; 
        self.favoriteButton.frame = CGRectMake(self.frame.size.width - 50, 0, 44, 44);
        [self.favoriteButton addTarget:self action:@selector(favoritePressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.favoriteButton];
        
        //Create line divider in view
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, CGRectGetMaxY(self.titleLabel.frame))];
        [path addLineToPoint:CGPointMake(size.width, CGRectGetMaxY(self.titleLabel.frame))];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [path CGPath];
        shapeLayer.strokeColor = [[UIColor grayColor] CGColor];
        shapeLayer.lineWidth = 0.5;
        shapeLayer.fillColor = [[UIColor clearColor] CGColor];
        
        [self.layer addSublayer:shapeLayer];
        
    }
    
    return self;
    
}

- (void) favoritePressed:(FavoritesButton *)sender {
    [[DataSource sharedInstance] toggleFavoriteStatus:self.searchAnnotation];
    [self.favoriteButton setFavoriteButtonState:self.searchAnnotation.favoriteState];
    
}


@end
