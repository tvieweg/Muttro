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

const float kDistanceThreshold = 200;
const float kMaxTimeBetweenMapUpdates = 15.0;
const float kMapSpan = 0.03;

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate>

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) DataSource *data;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (weak, nonatomic) UIGestureRecognizer *hideKeyboardTapGestureRecognizer;
@property (assign, nonatomic) BOOL shouldUpdateMapRegionToUserLocation;

@end

@implementation MapViewController

- (void)viewWillAppear:(BOOL)animated {
    
    if ([DataSource sharedInstance].lastTappedItem != nil) {
        self.shouldUpdateMapRegionToUserLocation = NO;
        [self setMapRegionToLocation: self.data.lastTappedItem.placemark.coordinate withSpanRange:kMapSpan];
        
    } else {
        self.shouldUpdateMapRegionToUserLocation = YES;
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.data = [DataSource sharedInstance];
    
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.searchBar.backgroundColor = [UIColor whiteColor];
    self.searchBar.alpha = 0.8;

    
    //init MapView
    self.mapView = [[MKMapView alloc] init];
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    
    //init Bar Buttons
    UIBarButtonItem *locationButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"location.png"] style:UIBarButtonItemStylePlain target:self action:@selector(locationTapped:)];
    
    UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"filter.png"] style:UIBarButtonItemStylePlain target:self action:@selector(filterTapped:)];
    
    UIBarButtonItem *listButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list.png"] style:UIBarButtonItemStylePlain target:self action:@selector(listTapped:)];
    
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
    [self.data searchWithParameters:self.searchBar.text withCompletionBlock:^(NSError *error) {
        [self.mapView setRegion:self.data.searchResults.boundingRegion];
        [self.mapView removeAnnotations:self.mapView.annotations];
        
        for (MKMapItem *mapItem in [self.data.searchResults mapItems]) {
            
            NSLog(@"Name: %@, MKAnnotation title: %@", [mapItem name], [[mapItem placemark] title]);
            NSLog(@"Coordinate: %f %f", [[mapItem placemark] coordinate].latitude, [[mapItem placemark] coordinate].longitude);
            // Should use a weak copy of self
            NSLog(@"%@", mapItem);
            
            SearchAnnotation *annotation = [[SearchAnnotation alloc] initWithMapItem:mapItem];
            
            [self.mapView addAnnotation:annotation];
            
        }
    }];
    
}

#pragma mark - Search Bar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {

    [self searchUsingTextInSearchBar];
    [self.searchBar resignFirstResponder];
    
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    self.searchBar.showsCancelButton = YES;
    
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
        }
        
        return annotationView;
        
    } else if ([annotation isKindOfClass:[CalloutAnnotation class]]){
            
        CalloutAnnotation *newAnnotation = (CalloutAnnotation *)annotation;
        MKAnnotationView *annotationView = [newAnnotation annotationView];
        
        return annotationView; 
        
        
    } else {
        
        return nil;

    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {

    if([view.annotation isKindOfClass:[SearchAnnotation class]]) {
        CalloutAnnotation *calloutAnnotation = [[CalloutAnnotation alloc] initForAnnotation:view.annotation];
        [self.mapView addAnnotation:calloutAnnotation];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.mapView selectAnnotation:calloutAnnotation animated:YES];

            if (!CGRectContainsRect(self.mapView.frame, calloutAnnotation.annotationView.frame)) {
                [self setMapRegionToLocation:view.annotation.coordinate withSpanRange:self.mapView.region.span.longitudeDelta];
            }
        });
        
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    
    if ([view.annotation isKindOfClass:[CalloutAnnotation class]]) {
        [mapView removeAnnotation:view.annotation];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    
   
    self.data.region = self.mapView.region;
     //TODO: If the user is scrolling and a search just happened, find more items in the search. If not, end the search. This could be done by making the user clear text in the search bar. Needs to be a significant change in distance. Check that this isn't updating against user location updates.
    
    /*if (![self.searchBar.text isEqualToString:@""]) {
        //Search for whatever the thing is.
        [self searchUsingTextInSearchBar]; 
    }*/
    NSLog(@"Updated data region");
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
    [self.navigationController pushViewController:listVC animated:YES];
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

@end
