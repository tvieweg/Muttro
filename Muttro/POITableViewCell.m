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
        self.favoriteButton.frame = CGRectMake(0, 0, 44, 44);
        [self.favoriteButton addTarget:self action:@selector(favoritePressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.favoriteButton];
        
        self.poiName = [[UILabel alloc] init];
        self.poiName.frame = CGRectMake(44, 0, 200, 44);
        self.poiName.numberOfLines = 1;
        [self addSubview:self.poiName];
        
        self.poiDescription = [[UILabel alloc] init];
        self.poiDescription.frame = CGRectMake(44, CGRectGetMaxY(self.poiName.frame), self.poiName.frame.size.width, self.poiName.frame.size.height);
        self.poiDescription.numberOfLines = 1;
        [self addSubview:self.poiDescription];
        
    }
    
    return self;
}

-(void) favoritePressed:(UIButton *)sender {
    [self.delegate cellDidPressLikeButton:self]; 
}
@end
