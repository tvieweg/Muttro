//
//  CategoryToolbar.m
//  Muttro
//
//  Created by Trevor Vieweg on 6/22/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import "CategoryToolbar.h"

const float kCategoryButtonWidth = 40.0;
const float kCategoryButtonHeight = 40.0;

@interface CategoryToolbar ()

@property (nonatomic, strong) UIButton *parkButton;
@property (nonatomic, strong) UIButton *vetButton;
@property (nonatomic, strong) UIButton *groomerButton;
@property (nonatomic, strong) UIButton *dayCareButton;
@property (nonatomic, strong) UIButton *petStoreButton;
@property (nonatomic, strong) NSMutableArray *buttons;

@end

@implementation CategoryToolbar

- (instancetype) init {
    
    self = [super init];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.alpha = 1.0;
        self.buttons = [NSMutableArray new];
        
        self.parkButton = [[UIButton alloc] init];
        [self.parkButton setImage:[UIImage imageNamed:@"park"] forState:UIControlStateNormal];
        [self.parkButton addTarget:self action:@selector(parkButtonFired:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:self.parkButton];
        
        
        self.vetButton = [[UIButton alloc] init];
        [self.vetButton setImage:[UIImage imageNamed:@"vet"] forState:UIControlStateNormal];
        [self.vetButton addTarget:self action:@selector(vetButtonFired:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:self.vetButton];
        
        
        
        self.groomerButton = [[UIButton alloc] init];
        [self.groomerButton setImage:[UIImage imageNamed:@"grooming"] forState:UIControlStateNormal];
        [self.groomerButton addTarget:self action:@selector(groomerButtonFired:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:self.groomerButton];
        
        
        self.dayCareButton = [[UIButton alloc] init];
        [self.dayCareButton setImage:[UIImage imageNamed:@"daycare"] forState:UIControlStateNormal];
        [self.dayCareButton addTarget:self action:@selector(dayCareButtonFired:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:self.dayCareButton];
        
        self.petStoreButton = [[UIButton alloc] init];
        [self.petStoreButton setImage:[UIImage imageNamed:@"petstore"] forState:UIControlStateNormal];
        [self.petStoreButton addTarget:self action:@selector(petStoreButtonFired:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:self.petStoreButton];
        
        for (UIButton *button in self.buttons) {
            [self addSubview:button];
        }
        
    }
    
    return self;
}

- (void) parkButtonFired:(UIButton *)sender {
    [self.delegate categoryParkButtonPressed:self];
}

- (void) vetButtonFired:(UIButton *)sender {
    [self.delegate categoryVetButtonPressed:self];
}

- (void) groomerButtonFired:(UIButton *)sender {
    [self.delegate categoryGroomingButtonPressed:self];
}

- (void) dayCareButtonFired:(UIButton *)sender {
    [self.delegate categoryDayCareButtonPressed:self];
}

- (void) petStoreButtonFired:(UIButton *)sender {
    [self.delegate categoryPetStoreButtonPressed:self];
}

- (void) layoutSubviews {
    CGFloat buttonSpacing = self.superview.bounds.size.width / 5;
    CGFloat buttonOriginX = 0;
    
    for (UIButton *button in self.buttons) {
        button.frame = CGRectMake(buttonOriginX, 0, buttonSpacing, kCategoryButtonHeight);
        
        buttonOriginX += buttonSpacing;
    }
}

@end
