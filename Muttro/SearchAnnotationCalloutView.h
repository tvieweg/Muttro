//
//  SearchAnnotationCalloutView.h
//  Muttro
//
//  Created by Trevor Vieweg on 6/10/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchAnnotationCalloutView : UIView

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *about;
@property (nonatomic, strong) NSString *userNotes;

-(id)initWithFrame:(CGRect)frame;

@end
