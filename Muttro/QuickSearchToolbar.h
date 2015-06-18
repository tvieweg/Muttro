//
//  QuickSearchToolbar.h
//  Muttro
//
//  Created by Trevor Vieweg on 6/17/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QuickSearchToolbar;

@protocol QuickSearchToolbarDelegate <NSObject>

- (void) didPressParkButton:(QuickSearchToolbar *)sender;
- (void) didPressVetButton:(QuickSearchToolbar *)sender;
- (void) didPressGroomerButton:(QuickSearchToolbar *)sender;
- (void) didPressDayCareButton:(QuickSearchToolbar *)sender;
- (void) didPressPetStoreButton:(QuickSearchToolbar *)sender;

@end

@interface QuickSearchToolbar : UIView

@property (nonatomic, weak) id <QuickSearchToolbarDelegate> delegate;

@end
