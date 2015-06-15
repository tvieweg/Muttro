//
//  FavoritesButton.h
//  Muttro
//
//  Created by Trevor Vieweg on 6/11/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FavoriteState) {
    FavoriteStateNotFavorited      = 0,
    FavoriteStateFavoriting        = 1,
    FavoriteStateFavorited         = 2,
    FavoriteStateUnFavoriting      = 3
};

@interface FavoritesButton : UIButton

@property (nonatomic, assign) FavoriteState favoriteButtonState;


@end
