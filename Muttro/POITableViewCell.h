//
//  POITableViewCell.h
//  Muttro
//
//  Created by Trevor Vieweg on 6/13/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FavoritesButton, POITableViewCell, SearchAnnotation;

@protocol POITableViewCellDelegate <NSObject>

- (void) cellDidPressLikeButton:(POITableViewCell *)cell;

@end

@interface POITableViewCell : UITableViewCell

@property (nonatomic, strong) SearchAnnotation *searchAnnotation;
@property (nonatomic, strong) FavoritesButton *favoriteButton;
@property (nonatomic, strong) UILabel *poiName;
@property (nonatomic, strong) UILabel *poiDescription;

@property (nonatomic, weak) id <POITableViewCellDelegate> delegate;

@end
