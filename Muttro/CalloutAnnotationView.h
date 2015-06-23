//
//  CalloutAnnotationView.h
//  Muttro
//
//  Created by Trevor Vieweg on 6/12/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import <MapKit/MapKit.h>

@class SearchAnnotation, CalloutAnnotationView;

@protocol CalloutAnnotationViewDelegate <NSObject>

- (void) didPressFavoriteButton:(CalloutAnnotationView *)annotationView;
- (void) didPressPhoneButton:(CalloutAnnotationView *)annotationView;
- (void) didPressWebButton:(CalloutAnnotationView *)annotationView;
- (void) didPressMapButton:(CalloutAnnotationView *)annotationView;

@optional
- (void) categoryWasChanged:(NSInteger)category forCalloutView:(CalloutAnnotationView *)annotationView;

@end

@interface CalloutAnnotationView : MKAnnotationView

- (instancetype) initWithAnnotation:(SearchAnnotation *)annotation reuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic, strong) SearchAnnotation *searchAnnotation;

@property (nonatomic, weak) id <CalloutAnnotationViewDelegate> delegate;

- (void) setImageForCategoryButton; 


@end
