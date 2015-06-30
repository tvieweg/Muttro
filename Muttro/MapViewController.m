//
//  MapViewController.m
//  Muttro
//
//  Created by Trevor Vieweg on 6/7/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "MapViewController.h"
#import "DataSource.h"
#import "ListTableViewController.h"
#import "SearchAnnotation.h"
#import "CalloutAnnotation.h"
#import "CalloutAnnotationView.h"
#import "QuickSearchToolbar.h"
#import "AnnotationWebViewController.h"

const float kMapSpan = 0.03;
const float kMaxEpsilon = 0.005;

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, CalloutAnnotationViewDelegate, QuickSearchToolbarDelegate>

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (weak, nonatomic) UIGestureRecognizer *hideKeyboardTapGestureRecognizer;
@property (strong, nonatomic) QuickSearchToolbar *quickSearchToolbar;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //KVO for favoriteLocations
    [[DataSource sharedInstance] addObserver:self forKeyPath:@"favoriteLocations" options:0 context:nil];
    
    [[DataSource sharedInstance] addObserver:self forKeyPath:@"currentLocation" options:0 context:nil];

    
    //init search bar
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.backgroundColor = [UIColor whiteColor];
    self.searchBar.alpha = 0.8;

    //init Quick Search toolbar
    self.quickSearchToolbar = [[QuickSearchToolbar alloc] init];
    self.quickSearchToolbar.delegate = self;
    
    //init MapView
    self.mapView = [[MKMapView alloc] init];
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    
    //init Bar Buttons
    UIBarButtonItem *locationButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"location"] style:UIBarButtonItemStylePlain target:self action:@selector(locationTapped:)];
    
    UIBarButtonItem *listButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list"] style:UIBarButtonItemStylePlain target:self action:@selector(listTapped:)];
    
    //init Gesture Recognizer
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    self.hideKeyboardTapGestureRecognizer = tap;
    [self.hideKeyboardTapGestureRecognizer addTarget:self action:@selector(tapGestureDidFire:)];
    
    //add Subviews
    [self.view addGestureRecognizer:tap];
    self.navigationItem.rightBarButtonItem = locationButton;
    self.navigationItem.leftBarButtonItem = listButton;
    
    //Custom coloring
    UIColor *primaryColor = [UIColor colorWithRed:6/255.0 green:142/255.0 blue:192/255.0 alpha:1.0];
    UIColor *textColor = [UIColor colorWithRed:235/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];

    self.navigationController.navigationBar.barTintColor = primaryColor;
    self.navigationController.navigationBar.tintColor = textColor;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : textColor};
    
    self.navigationItem.title = @"Muttro";
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.quickSearchToolbar];
    
}

- (void) viewDidAppear:(BOOL)animated {
    
    NSArray *selectedAnnotations = self.mapView.selectedAnnotations;
    for(id annotation in selectedAnnotations) {
        [self.mapView deselectAnnotation:annotation animated:NO];
    }
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self addSearchAndFavoriteAnnotationsToMap];
    
    if ([DataSource sharedInstance].locationWasTapped) {
        
        [DataSource sharedInstance].shouldUpdateMapRegionToUserLocation = NO;
        [DataSource sharedInstance].locationWasTapped = NO;
        [self setMapRegionToLocation: [DataSource sharedInstance].lastTappedAnnotation.coordinate withSpanRange:kMapSpan];
        [self.mapView selectAnnotation:[DataSource sharedInstance].lastTappedAnnotation animated:YES];
        
    } else {
        [DataSource sharedInstance].shouldUpdateMapRegionToUserLocation = YES;
    }
    
}

#pragma mark - Search

-(void)searchUsingSearchQuery:(NSString *)searchText {
    [[DataSource sharedInstance] searchWithParameters:searchText withCompletionBlock:^(NSError *error) {
        
        NSArray *selectedAnnotations = self.mapView.selectedAnnotations;
        for(id annotation in selectedAnnotations) {
            [self.mapView deselectAnnotation:annotation animated:NO];
        }

        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView setRegion:[DataSource sharedInstance].searchResults.boundingRegion];
        [self addSearchAndFavoriteAnnotationsToMap];

    }];
    
}

-(void)addSearchAndFavoriteAnnotationsToMap {
    NSMutableArray *searchAnnotationsToDisplay = [[DataSource sharedInstance] checkFavoritesAgainstSearchAndRemoveDuplicates];
    
    [self.mapView addAnnotations:searchAnnotationsToDisplay];
    [self.mapView addAnnotations:[DataSource sharedInstance].favoriteLocations];
}

#pragma mark - Search Bar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    [self searchUsingSearchQuery:self.searchBar.text];
    [self.searchBar resignFirstResponder];
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
    
    for (SearchAnnotation *annotation in [DataSource sharedInstance].favoriteLocations) {
        
        [self.mapView addAnnotation:annotation];
        
    }
    
    //Deselect annotations before next search. This resolves issue where crashes occurred when removing all previous annotations before next search.
    NSArray *selectedAnnotations = self.mapView.selectedAnnotations;
    for(id annotation in selectedAnnotations) {
        [self.mapView deselectAnnotation:annotation animated:YES];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    self.searchBar.showsCancelButton = NO;

}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UIView * txt in self.view.subviews){
        if ([txt isKindOfClass:[UITextField class]] && [txt isFirstResponder]) {
            [txt resignFirstResponder];
        }
    }
}

#pragma mark - Layouts

- (void)viewWillLayoutSubviews {
    CGFloat navBarHeight = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    CGFloat quickSearchToolbarHeight = 65;
    self.mapView.frame = CGRectMake(0, CGRectGetMaxY(self.searchBar.frame), self.view.frame.size.width, self.view.frame.size.height - navBarHeight - quickSearchToolbarHeight);
    self.searchBar.frame = CGRectMake(0, navBarHeight, self.view.bounds.size.width, 40);
    self.quickSearchToolbar.frame = CGRectMake(0, self.view.bounds.size.height - quickSearchToolbarHeight, self.view.bounds.size.width, quickSearchToolbarHeight);

}

#pragma mark - MKMapViewDelegate

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[SearchAnnotation class]]) {
        
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"SearchAnnotation"];
        
        if (annotationView == nil) {
            SearchAnnotation *newAnnotation = (SearchAnnotation *)annotation;
            annotationView = [newAnnotation annotationView];
        } else {
            annotationView.annotation = annotation;
            
            //Set image when annotation is being reused. 
            SearchAnnotation *tmpAnnotation = (SearchAnnotation *)annotation;
            if(tmpAnnotation.favoriteState == FavoriteStateFavorited) {
                UIImage *tmpImage = [[UIImage alloc] init]; 
                tmpImage = [tmpAnnotation setImageForFavoriteCategory:tmpAnnotation.favoriteCategory];
                annotationView.image = tmpImage;
            } else {
                annotationView.image = [UIImage imageNamed:@"pawprint"];
            }

        }
        
        return annotationView;
        
    } else if ([annotation isKindOfClass:[CalloutAnnotation class]]){
        
        CalloutAnnotationView *annotationView = (CalloutAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CalloutAnnotation"];
        
        if (annotationView == nil) {
            CalloutAnnotation *newAnnotation = (CalloutAnnotation *)annotation;
            annotationView = [newAnnotation annotationView];
            annotationView.delegate = self; 
        } else {
            annotationView.annotation = annotation;
        }

        return annotationView; 
        
    } else {
        
        return nil;

    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {

    if([view.annotation isKindOfClass:[SearchAnnotation class]]) {
        [DataSource sharedInstance].shouldUpdateMapRegionToUserLocation = NO;
        CalloutAnnotation *calloutAnnotation = [[CalloutAnnotation alloc] initForAnnotation: (SearchAnnotation *) view.annotation];
        [self.mapView addAnnotation:calloutAnnotation];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mapView selectAnnotation:calloutAnnotation animated:YES];

            //Move to annotation if the view is not contained on the current view.
            if (!CGRectContainsRect(self.mapView.frame, calloutAnnotation.annotationView.frame)) {
                [self setMapRegionToLocation:view.annotation.coordinate withSpanRange:self.mapView.region.span.longitudeDelta];
            }
        });
        
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    if ([view.annotation isKindOfClass:[CalloutAnnotation class]]) {
        
        //Check favorite state to ensure annotation is not about to be changed. This check prevents a crash where the mapView tries to remove the annotation twice (KVO change + deselect)
        CalloutAnnotation *currentAnnotation = (CalloutAnnotation *)view.annotation;
        if (currentAnnotation.searchAnnotation.favoriteState != FavoriteStateUnFavoriting &&
            currentAnnotation.searchAnnotation.favoriteState != FavoriteStateFavoriting) {
            [mapView removeAnnotation:view.annotation];
        }
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
   
    [DataSource sharedInstance].region = self.mapView.region;
    
    //TODO: If the user is scrolling and a search just happened, find more items in the search. If not, end the search. This could be done by making the user clear text in the search bar. Needs to be a significant change in distance. Check that this isn't updating against user location updates.
    
    /*if (![self.searchBar.text isEqualToString:@""]) {
        //Search for whatever the thing is.
        [self searchUsingTextInSearchBar]; 
    }*/
    
}

#pragma mark - Bar Buttons
    
- (void)locationTapped:(UIBarButtonItem *)sender {
    [DataSource sharedInstance].shouldUpdateMapRegionToUserLocation = YES;
    [self setMapRegionToLocation:self.mapView.userLocation.coordinate withSpanRange:kMapSpan];
}


- (void) listTapped:(UIBarButtonItem *)sender {
    ListTableViewController *listVC = [[ListTableViewController alloc] init];
    
    CATransition *transition = [CATransition animation];
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    transition.duration = 0.45;
    [transition setType:kCATransitionPush];
    transition.subtype = kCATransitionFromLeft;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController pushViewController:listVC animated:NO];
}

#pragma mark - TapGestureRecognizer

- (void)tapGestureDidFire:(UITapGestureRecognizer *)sender {
    [self.searchBar resignFirstResponder];
    self.searchBar.showsCancelButton = NO;

}

#pragma mark - Miscellaneous

- (void) setMapRegionToLocation:(CLLocationCoordinate2D)location withSpanRange:(CLLocationDegrees)spanRange {
    
    MKCoordinateSpan span = MKCoordinateSpanMake(spanRange, spanRange);
    MKCoordinateRegion region = MKCoordinateRegionMake(location, span);
    [self.mapView setRegion:region animated:YES];
    
}

- (void) reloadAnnotations {
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:[DataSource sharedInstance].favoriteLocations];
    [self addSearchAndFavoriteAnnotationsToMap];
}

#pragma mark - KVO

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == [DataSource sharedInstance] && [keyPath isEqualToString:@"favoriteLocations"]) {
        
        int kindOfChange = [change[NSKeyValueChangeKindKey] intValue];
        
        if (kindOfChange == NSKeyValueChangeSetting) {
            [self reloadAnnotations];
        }
    } else if (object == [DataSource sharedInstance] && [keyPath isEqualToString:@"currentLocation"]) {
        CLLocation *location = [DataSource sharedInstance].currentLocation; 
        CLLocationCoordinate2D mapCenter = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
        [self setMapRegionToLocation:mapCenter withSpanRange:kMapSpan];
    }
}

- (void) dealloc {
    [[DataSource sharedInstance] removeObserver:self forKeyPath:@"favoriteLocations"];
    [[DataSource sharedInstance] removeObserver:self forKeyPath:@"currentLocation"];

}

#pragma mark - CalloutAnnotationViewDelegate

- (void) didPressFavoriteButton:(CalloutAnnotationView *)annotationView {
    
    //Update data model.
    [[DataSource sharedInstance] toggleFavoriteStatus:annotationView.searchAnnotation];
    
    
    if (annotationView.searchAnnotation.favoriteState == FavoriteStateFavorited) {
        
        //Update annotation marker and refresh callout view.
        
        UIImage *tmpImage = [[UIImage alloc] init];
        
        tmpImage = [annotationView.searchAnnotation setImageForFavoriteCategory:annotationView.searchAnnotation.favoriteCategory];
        
        [self.mapView viewForAnnotation:annotationView.searchAnnotation].image = tmpImage;
        
        [self mapView:self.mapView didSelectAnnotationView:[annotationView.searchAnnotation annotationView]];
        
    } else if (annotationView.searchAnnotation.favoriteState == FavoriteStateNotFavorited) {
        
        //By default, the annotation should be removed, unless the current search contains the annotation (i.e., the user found it on this search.)
        BOOL keepAnnotation = NO;
        
        //Look for annotation in search results. If it's there, update keepAnnotation
        for (MKMapItem *searchItem in [[DataSource sharedInstance].searchResults mapItems]) {
            
            float searchLat = searchItem.placemark.coordinate.latitude;
            float searchLong = searchItem.placemark.coordinate.longitude;
            
            float favoriteLat = annotationView.searchAnnotation.coordinate.latitude;
            float favoriteLong = annotationView.searchAnnotation.coordinate.longitude;
            
            if (fabs(searchLat - favoriteLat) <= kMaxEpsilon && fabs(searchLong - favoriteLong) <= kMaxEpsilon) {
                keepAnnotation = YES;
            }
        }
        
        //If the annotation should stay, update the annotation marker and refresh the callout view. If not, remove the search and callout annotations. 
        if (keepAnnotation) {
            [self.mapView viewForAnnotation:annotationView.searchAnnotation].image = [UIImage imageNamed:@"pawprint"];
            [self mapView:self.mapView didSelectAnnotationView:[annotationView.searchAnnotation annotationView]];
        } else {
            [self.mapView removeAnnotation:annotationView.searchAnnotation];
            [self.mapView deselectAnnotation:annotationView.annotation animated:YES];
        }
    }
}

- (void) didPressPhoneButton:(CalloutAnnotationView *)annotationView {
    NSString *phoneURL = @"tel:";
    if (annotationView.searchAnnotation.phoneNumber != nil) {
        NSString *annotationPhoneNumber = [phoneURL stringByAppendingString:annotationView.searchAnnotation.phoneNumber];
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:annotationPhoneNumber]];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Whoops!", @"Error")
                                                        message: NSLocalizedString(@"These guys need a phone number!", @"No phone")
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"OK", nil)
                                              otherButtonTitles: nil];
        
        [alert show];
    }
}

- (void) didPressWebButton:(CalloutAnnotationView *)annotationView {
    if (annotationView.searchAnnotation.url != nil) {
        [DataSource sharedInstance].selectedAnnotationURL = annotationView.searchAnnotation.url;
        AnnotationWebViewController *webVC = [[AnnotationWebViewController alloc] init];
        [self.navigationController pushViewController:webVC animated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Whoops!", @"Error")
                                                        message: NSLocalizedString(@"No website here! We're off the grid now, Charlie", @"No website")
                                                       delegate: nil
                                              cancelButtonTitle: NSLocalizedString(@"OK", nil)
                                              otherButtonTitles: nil];
        
        [alert show];

    }
}

- (void) didPressMapButton:(CalloutAnnotationView *)annotationView {
    // Check for iOS 6
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        // Create an MKMapItem to pass to the Maps app
        CLLocationCoordinate2D coordinate = annotationView.searchAnnotation.coordinate;
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate
                                                       addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:annotationView.searchAnnotation.title];
        // Pass the map item to the Maps app
        [mapItem openInMapsWithLaunchOptions:nil];
    }
    
}

- (void) categoryWasChanged:(NSInteger)category forCalloutView:(CalloutAnnotationView *)annotationView {
    annotationView.searchAnnotation.favoriteCategory = category;
    [[DataSource sharedInstance] setFavoriteCategory:annotationView.searchAnnotation toCategory:category];
    [annotationView setImageForCategoryButton];
    
    UIImage *tmpImage = [[UIImage alloc] init];
    
    if(annotationView.searchAnnotation.favoriteState == FavoriteStateFavorited) {
        tmpImage = [annotationView.searchAnnotation setImageForFavoriteCategory:annotationView.searchAnnotation.favoriteCategory];
    
    } else {
        
        tmpImage = [UIImage imageNamed:@"pawprint"];
    }
    
    [self.mapView viewForAnnotation:annotationView.searchAnnotation].image = tmpImage;
}


#pragma mark - QuickSearchToolbarDelegate

- (void) didPressParkButton:(QuickSearchToolbar *)sender {
    [self searchUsingSearchQuery:@"park"];
}

- (void) didPressVetButton:(QuickSearchToolbar *)sender {
    [self searchUsingSearchQuery:@"boarding"];
}

- (void) didPressGroomerButton:(QuickSearchToolbar *)sender {
    [self searchUsingSearchQuery:@"grooming"];
}

- (void) didPressDayCareButton:(QuickSearchToolbar *)sender {
    [self searchUsingSearchQuery:@"sitting"];
}

- (void) didPressPetStoreButton:(QuickSearchToolbar *)sender {
    [self searchUsingSearchQuery:@"pet supplies"];
}

@end
