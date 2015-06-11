//
//  SearchAnnotationCalloutView.m
//  Muttro
//
//  Created by Trevor Vieweg on 6/10/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import "SearchAnnotationCalloutView.h"

@implementation SearchAnnotationCalloutView

-(id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(5.0, 5.0, self.frame.size.width - 10.0, self.frame.size.height - 10.0);
        [button setTitle:@"OK" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(checkin) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];

    }
    return self;
}


@end
