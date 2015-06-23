//
//  CategoryToolbar.h
//  Muttro
//
//  Created by Trevor Vieweg on 6/22/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CategoryToolbar; 

@protocol CategoryToolbarDelegate <NSObject>

@optional

- (void) categoryParkButtonPressed:(CategoryToolbar *)toolbar;
- (void) categoryVetButtonPressed:(CategoryToolbar *)toolbar;
- (void) categoryGroomingButtonPressed:(CategoryToolbar *)toolbar;
- (void) categoryDayCareButtonPressed:(CategoryToolbar *)toolbar;
- (void) categoryPetStoreButtonPressed:(CategoryToolbar *)toolbar;

@end

@interface CategoryToolbar : UIView

@property (nonatomic, weak) id <CategoryToolbarDelegate> delegate;

@end
