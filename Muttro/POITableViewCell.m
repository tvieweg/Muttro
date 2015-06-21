//
//  POITableViewCell.m
//  Muttro
//
//  Created by Trevor Vieweg on 6/13/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import "POITableViewCell.h"
#import "FavoritesButton.h"

@interface POITableViewCell ()

@end

@implementation POITableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //Initialization code
        self.favoriteButton = [[FavoritesButton alloc] init];
        self.favoriteButton.frame = CGRectMake(0, 5 , 44, 44);
        self.favoriteButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [self.favoriteButton addTarget:self action:@selector(favoritePressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.favoriteButton];
        
        self.poiName = [[UILabel alloc] init];
        self.poiName.frame = CGRectMake(44, 2, self.frame.size.width - 44, 44);
        self.poiName.numberOfLines = 0;
        [self addSubview:self.poiName];
        
        self.distanceToPOI = [[UILabel alloc] initWithFrame:CGRectMake(self.poiName.frame.origin.x, CGRectGetMaxY(self.poiName.frame) + 5, 100, 20)];
        self.distanceToPOI.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.distanceToPOI];
        
        self.phoneButton = [[UIButton alloc] init];
        [self.phoneButton setImage:[UIImage imageNamed:@"phone"] forState:UIControlStateNormal];
        [self.phoneButton addTarget:self action:@selector(phonePressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.phoneButton];
        
        self.webButton = [[UIButton alloc] init];
        [self.webButton setImage:[UIImage imageNamed:@"web"] forState:UIControlStateNormal];
        [self.webButton addTarget:self action:@selector(webPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.webButton];
        
        self.mapButton = [[UIButton alloc] init];
        [self.mapButton setImage:[UIImage imageNamed:@"directions"] forState:UIControlStateNormal];
        [self.mapButton addTarget:self action:@selector(mapPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.mapButton];

        
    }
    
    return self;
}

-(void) layoutSubviews {

    [super layoutSubviews];
    CGFloat buttonWidth = 30;
    CGFloat buttonSpacing = 35;
    CGFloat buttonOriginX = self.frame.size.width - buttonSpacing - 5;
    CGFloat buttonOriginY = self.frame.size.height / 2 - buttonWidth / 2;
    
    NSArray *buttons = @[self.mapButton, self.webButton, self.phoneButton];
    for (UIButton *button in buttons) {
        button.frame = CGRectMake(buttonOriginX, buttonOriginY, buttonWidth, buttonWidth);
        buttonOriginX -= buttonSpacing;
    }
    
}

-(void) favoritePressed:(UIButton *)sender {
    [self.delegate cellDidPressLikeButton:self]; 
}

- (void) phonePressed:(UIButton *)sender {
    [self.delegate cellDidPressPhoneButton:self];
}

- (void) webPressed:(UIButton *)sender {
    [self.delegate cellDidPressWebButton:self];
}

- (void) mapPressed:(UIButton *)sender {
    [self.delegate cellDidPressMapButton:self];
}

@end
