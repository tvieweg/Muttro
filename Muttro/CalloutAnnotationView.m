//
//  CalloutAnnotationView.m
//  Muttro
//
//  Created by Trevor Vieweg on 6/12/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import "FavoritesButton.h"
#import "CalloutAnnotationView.h"
#import "DataSource.h"
#import "CategoryToolbar.h"

const float kCAAnnotationFrameWidth = 280.0;
const float kCAAnnotationFrameHeight = 160.0;
const float kCAAnnotationFrameOffsetX = 0.0;
const float kCAAnnotationFrameOffsetY = 100.0;
const float kCALabelHeight = 35.0;
const float kCAButtonWidth = 35.0;
const float kCAButtonSpacing = 6.0;

@interface CalloutAnnotationView () <CategoryToolbarDelegate>

@property (nonatomic, strong) FavoritesButton *favoriteButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *phoneButton;
@property (nonatomic, strong) UIButton *webButton;
@property (nonatomic, strong) UIButton *mapButton;
@property (nonatomic, strong) UITextView *annotationURL;
@property (nonatomic, strong) UITextView *annotationPhoneNumber;
@property (nonatomic, strong) UIButton *categoryButton;
@property (nonatomic, strong) CategoryToolbar *categoryBar;
@property (nonatomic, strong) UITapGestureRecognizer *hideCategoryGestureRecognizer;
@property (nonatomic, strong) UIImageView *yelpImage;


@end

@implementation CalloutAnnotationView

- (instancetype) initWithAnnotation:(SearchAnnotation *)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super init];
    
    if (self) {
        
        self.searchAnnotation = annotation;
        
        CGSize size = CGSizeMake(kCAAnnotationFrameWidth, kCAAnnotationFrameHeight);
        CGPoint offset = CGPointMake(kCAAnnotationFrameOffsetX, kCAAnnotationFrameOffsetY);
        
        self.frame = CGRectMake(0.0, 0.0, size.width, size.height);
        self.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
        self.canShowCallout = NO;
        self.centerOffset = offset;
        self.layer.cornerRadius = 10.0;
        
        //Add title and information
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.bounds.size.width - 50, kCALabelHeight)];
        self.titleLabel.text = self.searchAnnotation.title;
        
        CGRect urlFrame = CGRectMake(0, CGRectGetMaxY(self.titleLabel.frame), self.frame.size.width, kCALabelHeight);
        self.annotationURL = [[UITextView alloc] initWithFrame:urlFrame];
        self.annotationURL.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
        self.annotationURL.editable = NO;
        if (self.searchAnnotation.url != nil) {
            self.annotationURL.text = [self.searchAnnotation.url absoluteString];
        } else {
            self.annotationURL.text = @"(no website listed)"; 
        }
        [self.annotationURL setDataDetectorTypes:UIDataDetectorTypeLink];
        
        CGRect phoneNumberFrame = CGRectMake(0, CGRectGetMaxY(self.annotationURL.frame), self.frame.size.width, kCALabelHeight - 5);
        self.annotationPhoneNumber = [[UITextView alloc] initWithFrame:phoneNumberFrame];
        self.annotationPhoneNumber.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
        self.annotationPhoneNumber.editable = NO;
        if (self.searchAnnotation.phoneNumber != nil ) {
            self.annotationPhoneNumber.text = self.searchAnnotation.phoneNumber;
        } else {
            self.annotationPhoneNumber.text = @"(no phone listed)";
        }
        [self.annotationPhoneNumber setDataDetectorTypes:UIDataDetectorTypePhoneNumber];

        
        //Favorite button
        self.favoriteButton = [[FavoritesButton alloc] init];
        [self.favoriteButton setFavoriteButtonState:self.searchAnnotation.favoriteState];
        self.favoriteButton.frame = CGRectMake(self.frame.size.width - 50, -5, 44, 44);
        [self.favoriteButton addTarget:self action:@selector(favoritePressed:) forControlEvents:UIControlEventTouchUpInside];
        
        
        //Category button
        self.categoryButton = [[UIButton alloc] initWithFrame:CGRectMake(10, self.bounds.size.height - kCAButtonWidth - kCAButtonSpacing - 20, kCAButtonWidth, kCAButtonWidth)];
        [self setImageForCategoryButton]; 
        [self.categoryButton addTarget:self action:@selector(categoryPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        
        //Yelp image
        self.yelpImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"poweredByYelp"]];
        self.yelpImage.frame = CGRectMake(self.frame.size.width - 90, self.frame.size.height - 22, 80, 17);;
        
        
        //Action Buttons
        self.phoneButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - kCAButtonWidth*3 - kCAButtonSpacing * 3, self.bounds.size.height - kCAButtonWidth - kCAButtonSpacing - 20, kCAButtonWidth, kCAButtonWidth)];
        [self.phoneButton setImage:[UIImage imageNamed:@"phone"] forState:UIControlStateNormal];
        [self.phoneButton addTarget:self action:@selector(phonePressed:) forControlEvents:UIControlEventTouchUpInside];
        
        self.webButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - kCAButtonWidth * 2 - kCAButtonSpacing * 2, self.bounds.size.height - kCAButtonWidth - kCAButtonSpacing - 20, kCAButtonWidth, kCAButtonWidth)];
        [self.webButton setImage:[UIImage imageNamed:@"web"] forState:UIControlStateNormal];
        [self.webButton addTarget:self action:@selector(webPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        self.mapButton = [[UIButton alloc] initWithFrame:CGRectMake(self.bounds.size.width - kCAButtonWidth - kCAButtonSpacing, self.bounds.size.height - kCAButtonWidth - kCAButtonSpacing - 20, kCAButtonWidth, kCAButtonWidth)];
        [self.mapButton setImage:[UIImage imageNamed:@"directions"] forState:UIControlStateNormal];
        [self.mapButton addTarget:self action:@selector(mapPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        
        //Category popout
        self.categoryBar = [[CategoryToolbar alloc] init];
        self.categoryBar.delegate = self;
        self.categoryBar.backgroundColor = [UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1.0];
        
        
        //Gesture Recognizer
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        self.hideCategoryGestureRecognizer = tap;
        [self.hideCategoryGestureRecognizer addTarget:self action:@selector(tapGestureDidFire:)];
        [self addGestureRecognizer:self.hideCategoryGestureRecognizer];

        
        //Create line divider in view
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(0, CGRectGetMaxY(self.titleLabel.frame))];
        [path addLineToPoint:CGPointMake(size.width, CGRectGetMaxY(self.titleLabel.frame))];
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        shapeLayer.path = [path CGPath];
        shapeLayer.strokeColor = [[UIColor grayColor] CGColor];
        shapeLayer.lineWidth = 0.5;
        shapeLayer.fillColor = [[UIColor clearColor] CGColor];

        NSArray *subviews = @[self.titleLabel, self.annotationURL, self.annotationPhoneNumber, self.favoriteButton, self.categoryButton, self.yelpImage, self.phoneButton, self.webButton, self.mapButton];
        
        for (UIView *view in subviews) {
            [self addSubview:view];
        }
        
        [self.layer addSublayer:shapeLayer];
        
    }
    
    return self;

}

- (void)tapGestureDidFire:(UITapGestureRecognizer *)sender {
    
    if ([[self subviews] containsObject:self.categoryBar]) {
        [self.categoryBar removeFromSuperview];
    }
}

- (void) setImageForCategoryButton {
        UIImage *tmpImage = [[UIImage alloc] init];
        tmpImage = [self.searchAnnotation setImageForCategory:self.searchAnnotation.category];
        [self.categoryButton setImage:tmpImage forState:UIControlStateNormal]; 
}

- (void) favoritePressed:(FavoritesButton *)sender {
    [self.delegate didPressFavoriteButton: self];
}

- (void) phonePressed:(UIButton *)sender {
    [self.delegate didPressPhoneButton:self];
}

- (void) webPressed:(UIButton *)sender {
    [self.delegate didPressWebButton:self];
}

- (void) mapPressed:(UIButton *)sender {
    [self.delegate didPressMapButton:self]; 
}

- (void) categoryPressed:(UIButton *)sender {
    if (self.searchAnnotation.favoriteState == FavoriteStateFavorited) {

        if ([[self subviews] containsObject:self.categoryBar]) {
            [self.categoryBar removeFromSuperview];
        } else {
            self.categoryBar.frame = CGRectMake(0, self.categoryButton.frame.origin.y, self.frame.size.width, 60);
            [self addSubview:self.categoryBar];
        }
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Heel boy!", @"Error")
                                                        message: NSLocalizedString(@"You can only set categories on a favorite item", @"Favorite category warning")
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"OK", nil)
                                              otherButtonTitles: nil];
        
        [alert show];

    }
    
}

#pragma mark - CategoryToolbarDelegate

- (void) categoryParkButtonPressed:(CategoryToolbar *)toolbar {
    [self.delegate categoryWasChanged:CategoryPark forCalloutView:self];
    [self.categoryBar removeFromSuperview];
}

- (void) categoryGroomingButtonPressed:(CategoryToolbar *)toolbar {
    [self.delegate categoryWasChanged:CategoryGroomers forCalloutView:self];
    [self.categoryBar removeFromSuperview];
}

- (void) categoryVetButtonPressed:(CategoryToolbar *)toolbar {
    [self.delegate categoryWasChanged:CategoryVet forCalloutView:self];
    [self.categoryBar removeFromSuperview];
}

- (void) categoryDayCareButtonPressed:(CategoryToolbar *)toolbar {
    [self.delegate categoryWasChanged:CategoryDayCare forCalloutView:self];
    [self.categoryBar removeFromSuperview];
}

- (void) categoryPetStoreButtonPressed:(CategoryToolbar *)toolbar {
    [self.delegate categoryWasChanged:CategoryPetStore forCalloutView:self];
    [self.categoryBar removeFromSuperview];
}

@end
