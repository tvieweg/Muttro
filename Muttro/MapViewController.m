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

const float kDistanceThreshold = 200;
const float kMaxTimeBetweenMapUpdates = 15.0;
const float kMapSpan = 0.03;
const float kMaxEpsilon = 0.005;

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, CalloutAnnotationViewDelegate>

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (weak, nonatomic) UIGestureRecognizer *hideKeyboardTapGestureRecognizer;
@property (assign, nonatomic) BOOL shouldUpdateMapRegionToUserLocation;

@end

@implementation MapViewController

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:YES];
    if ([DataSource sharedInstance].locationWasTapped) {
       
        self.shouldUpdateMapRegionToUserLocation = NO;
        [DataSource sharedInstance].locationWasTapped = NO;
        [self setMapRegionToLocation: [DataSource sharedInstance].lastTappedCoordinate withSpanRange:kMapSpan];
        
    } else {
        self.shouldUpdateMapRegionToUserLocation = YES;
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //KVO for favoriteLocations
    [[DataSource sharedInstance] addObserver:self forKeyPath:@"favoriteLocations" options:0 context:nil];
    
    //init search bar
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.backgroundColor = [UIColor whiteColor];
    self.searchBar.alpha = 0.8;

    
    //init MapView
    self.mapView = [[MKMapView alloc] init];
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    
    //init Bar Buttons
    UIBarButtonItem *locationButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"location"] style:UIBarButtonItemStylePlain target:self action:@selector(locationTapped:)];
    
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"filter"] style:UIBarButtonItemStylePlain target:self action:@selector(filterTapped:)];
    
    UIBarButtonItem *listButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list"] style:UIBarButtonItemStylePlain target:self action:@selector(listTapped:)];
    
    //init Gesture Recognizer
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
    self.hideKeyboardTapGestureRecognizer = tap;
    [self.hideKeyboardTapGestureRecognizer addTarget:self action:@selector(tapGestureDidFire:)];

    
    [self startLocationManager];
    
    //add Subviews
    [self.view addGestureRecognizer:tap];
    self.navigationItem.rightBarButtonItems = @[filterButton, locationButton];
    self.navigationItem.leftBarButtonItem = listButton;
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.searchBar];
    
}

#pragma mark - Search

-(void)searchUsingTextInSearchBar {
    [[DataSource sharedInstance] searchWithParameters:self.searchBar.text withCompletionBlock:^(NSError *error) {
        
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView setRegion:[DataSource sharedInstance].searchResults.boundingRegion];
        [self addSearchAndFavoriteAnnotationsToMap];

    }];
    
}

-(void)addSearchAndFavoriteAnnotationsToMap {
    NSMutableArray *mapsToDisplay = [[DataSource sharedInstance] checkFavoritesAgainstSearchAndRemoveDuplicates];
    for (MKMapItem *mapItem in mapsToDisplay) {
        
        SearchAnnotation *annotation = [[SearchAnnotation alloc] initWithMapItem:mapItem];
        
        [self.mapView addAnnotation:annotation];
        
    }
    
    for (SearchAnnotation *favAnnotation in [DataSource sharedInstance].favoriteLocations) {
        [self.mapView addAnnotation:favAnnotation];
    }
}

#pragma mark - Search Bar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    [self searchUsingTextInSearchBar];
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

#pragma mark - Location Manager

- (void)startLocationManager {
    
    // Create the location manager if this object does not
    // already have one.
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        
    }
    [self.locationManager requestWhenInUseAuthorization];
    self.locationManager.delegate = self;
    
    // Set a movement threshold for new events.
    self.locationManager.distanceFilter = kDistanceThreshold; // meters
    
    [self.locationManager startUpdatingLocation];
}

- (void) locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {

    //TODO: If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (fabs(howRecent) < kMaxTimeBetweenMapUpdates) {
        // If the event is recent, do something with it.
        
        if (self.shouldUpdateMapRegionToUserLocation) {
            //We aren't looking at a location tapped from the list view.
            CLLocationCoordinate2D mapCenter = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
            [self setMapRegionToLocation:mapCenter withSpanRange:kMapSpan];
        }
    }
    
}

#pragma mark - Layouts

- (void)viewWillLayoutSubviews {
    CGFloat navBarHeight = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    self.mapView.frame = CGRectMake(0, navBarHeight, self.view.frame.size.width, self.view.frame.size.height - navBarHeight);
    self.searchBar.frame = CGRectMake(0, navBarHeight, self.view.bounds.size.width, 40);

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
                annotationView.image = [UIImage imageNamed:@"pawprint-yellow"];
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
    self.shouldUpdateMapRegionToUserLocation = YES;
    [self setMapRegionToLocation:self.mapView.userLocation.coordinate withSpanRange:kMapSpan];
}
- (void) filterTapped:(UIBarButtonItem *)sender {
    NSLog(@"Filter tapped!");
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

#pragma mark - Key/Value Observation

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == [DataSource sharedInstance] && [keyPath isEqualToString:@"favoriteLocations"]) {
        
        int kindOfChange = [change[NSKeyValueChangeKindKey] intValue];
        
        if (kindOfChange == NSKeyValueChangeSetting) {
            [self reloadAnnotations];
        }
    }
}

- (void) dealloc {
    [[DataSource sharedInstance] removeObserver:self forKeyPath:@"favoriteLocations"];
}

#pragma mark - CalloutAnnotationViewDelegate

- (void) didToggleFavoriteButton:(CalloutAnnotationView *)annotationView {
    
    //Update data model.
    [[DataSource sharedInstance] toggleFavoriteStatus:annotationView.searchAnnotation];
    
    
    if (annotationView.searchAnnotation.favoriteState == FavoriteStateFavorited) {
        
        //Update annotation marker and refresh callout view.
        [self.mapView viewForAnnotation:annotationView.searchAnnotation].image = [UIImage imageNamed:@"pawprint-yellow"];
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

@end
