//
//  FavoritesButton.m
//  Muttro
//
//  Created by Trevor Vieweg on 6/11/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import "FavoritesButton.h"


#define kFavoritedStateImage @"star-full"
#define kUnFavoritedStateImage @"star-empty"


@implementation FavoritesButton

- (instancetype) init {
    self = [super init];
    
    if (self) {
        self.frame = CGRectMake(0, 0, 44, 44);
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.contentEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    
    }
    
    return self;
}

- (void) setFavoriteButtonState:(FavoriteState)favoriteState {
    _favoriteButtonState = favoriteState;
    
    NSString *imageName;
    
    switch (_favoriteButtonState) {
        case FavoriteStateFavorited:
        case FavoriteStateUnFavoriting:
            imageName = kFavoritedStateImage;
            break;
            
        case FavoriteStateNotFavorited:
        case FavoriteStateFavoriting:
            imageName = kUnFavoritedStateImage;
    }
    
    switch (_favoriteButtonState) {
        case FavoriteStateFavoriting:
        case FavoriteStateUnFavoriting:
            self.userInteractionEnabled = NO;
            break;
            
        case FavoriteStateFavorited:
        case FavoriteStateNotFavorited:
            self.userInteractionEnabled = YES;
    }
    
    [self setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
}



@end
