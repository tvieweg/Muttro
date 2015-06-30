//
//  QuickSearchToolbar.m
//  Muttro
//
//  Created by Trevor Vieweg on 6/17/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import "QuickSearchToolbar.h"

const float kQuickButtonWidth = 40.0;
const float kQuickButtonHeight = 40.0;

@interface QuickSearchToolbar ()

@property (nonatomic, strong) UIButton *parkButton;
@property (nonatomic, strong) UIButton *vetButton;
@property (nonatomic, strong) UIButton *groomerButton;
@property (nonatomic, strong) UIButton *dayCareButton;
@property (nonatomic, strong) UIButton *petStoreButton;
@property (nonatomic, strong) NSMutableArray *buttons;

@end

@implementation QuickSearchToolbar

- (instancetype) init {
    
    self = [super init];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.alpha = 0.9; 
        self.buttons = [NSMutableArray new];
        
        self.parkButton = [[UIButton alloc] init];
        [self.parkButton setImage:[UIImage imageNamed:@"park"] forState:UIControlStateNormal];
        [self.parkButton setTitle:@"Parks" forState:UIControlStateNormal];
        [self.parkButton addTarget:self action:@selector(parkButtonFired:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:self.parkButton];
        
        
        self.vetButton = [[UIButton alloc] init];
        [self.vetButton setImage:[UIImage imageNamed:@"vet"] forState:UIControlStateNormal];
        [self.vetButton setTitle:@"Vets" forState:UIControlStateNormal];
        [self.vetButton addTarget:self action:@selector(vetButtonFired:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:self.vetButton];


        
        self.groomerButton = [[UIButton alloc] init];
        [self.groomerButton setImage:[UIImage imageNamed:@"grooming"] forState:UIControlStateNormal];
        [self.groomerButton setTitle:@"Groomers" forState:UIControlStateNormal];
        [self.groomerButton addTarget:self action:@selector(groomerButtonFired:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:self.groomerButton];

        
        self.dayCareButton = [[UIButton alloc] init];
        [self.dayCareButton setImage:[UIImage imageNamed:@"daycare"] forState:UIControlStateNormal];
        [self.dayCareButton setTitle:@"Day Care" forState:UIControlStateNormal];
        [self.dayCareButton addTarget:self action:@selector(dayCareButtonFired:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:self.dayCareButton];

        
        self.petStoreButton = [[UIButton alloc] init];
        [self.petStoreButton setImage:[UIImage imageNamed:@"petstore"] forState:UIControlStateNormal];
        [self.petStoreButton setTitle:@"Stores" forState:UIControlStateNormal];
        [self.petStoreButton addTarget:self action:@selector(petStoreButtonFired:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:self.petStoreButton];

        UIColor *buttonTextColor = [UIColor colorWithRed:6/255.0 green:142/255.0 blue:192/255.0 alpha:1.0];
        for (UIButton *button in self.buttons) {
            button.titleLabel.font = [UIFont systemFontOfSize:10];
            [button setTitleColor:buttonTextColor forState:UIControlStateNormal];
            [self addSubview:button];
        }
        
    }
    
    return self;
}

- (void) parkButtonFired:(UIButton *)sender {
    [self.delegate didPressParkButton:self];
}

- (void) vetButtonFired:(UIButton *)sender {
    [self.delegate didPressVetButton:self];
}

- (void) groomerButtonFired:(UIButton *)sender {
    [self.delegate didPressGroomerButton:self];
}

- (void) dayCareButtonFired:(UIButton *)sender {
    [self.delegate didPressDayCareButton:self];
}

- (void) petStoreButtonFired:(UIButton *)sender {
    [self.delegate didPressPetStoreButton:self];
}

- (void) layoutSubviews {
    CGFloat buttonSpacing = self.superview.bounds.size.width / 5;
    // the space between the image and text
    CGFloat spacing = 6.0;
    CGFloat buttonOriginX = 0;
    CGFloat buttonOriginY = 5;
    
    for (UIButton *button in self.buttons) {
        button.frame = CGRectMake(buttonOriginX, buttonOriginY, buttonSpacing, kQuickButtonHeight);
        
        // lower the text and push it left so it appears centered
        //  below the image
        CGSize imageSize = button.imageView.image.size;
        CGSize titleSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];

        button.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (imageSize.height + titleSize.height + spacing), 0.0);
        
        // raise the image and push it right so it appears centered
        //  above the text
        button.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, - titleSize.width);
        
        buttonOriginX += buttonSpacing; 
    }
}

@end
