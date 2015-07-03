//
//  ListTableViewController.m
//  Muttro
//
//  Created by Trevor Vieweg on 6/9/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//
#import <MapKit/MapKit.h>
#import "ListTableViewController.h"
#import "DataSource.h"
#import "SearchAnnotation.h"
#import "POITableViewCell.h"
#import "AnnotationWebViewController.h"

const double kPTMetersToMilesConversion = 0.000621371;

@interface ListTableViewController () <POITableViewCellDelegate>

@end

@implementation ListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[DataSource sharedInstance] addObserver:self forKeyPath:@"favoriteLocations" options:0 context:nil];
    
    [self.tableView registerClass:[POITableViewCell class] forCellReuseIdentifier:@"POICell"];
    
    UIBarButtonItem *mapButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"maps"] style:UIBarButtonItemStylePlain target:self action:@selector(mapTapped:)];
    
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.title = @"Muttro";
    self.navigationItem.leftBarButtonItem = mapButton;

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0)
    {
        if ([DataSource sharedInstance].favoriteLocations.count > 0) {
            return [DataSource sharedInstance].favoriteLocations.count;
        } else {
            return 1;
        }
        
    } else {
        return [DataSource sharedInstance].searchResultsAnnotations.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return @"Favorites";
    else
        return @"Search Results";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    POITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"POICell" forIndexPath:indexPath];
    
    cell.delegate = self;
    
    if (indexPath.section == 0) {
        
        if ([DataSource sharedInstance].favoriteLocations.count > 0) {

            cell.searchAnnotation = [DataSource sharedInstance].favoriteLocations[indexPath.row];
            cell.poiName.text = cell.searchAnnotation.title;
            cell.poiName.textColor = [UIColor blackColor];
            
            [self setDistanceToPoiText:cell];
            cell.distanceToPOI.hidden = NO;
            cell.phoneButton.hidden = NO;
            cell.webButton.hidden = NO;
            cell.mapButton.hidden = NO;
            cell.categoryImage.hidden = NO;
            [self setImageForCellCategoryButton:cell];
            
            [cell.favoriteButton setFavoriteButtonState:cell.searchAnnotation.favoriteState];
            cell.favoriteButton.hidden = NO;
            cell.userInteractionEnabled = YES;
            
        } else {
            cell.poiName.text = @"Star items to favorite";
            cell.poiName.textColor = [UIColor grayColor];
            
            cell.categoryImage.hidden = YES;
            cell.favoriteButton.hidden = YES;
            cell.distanceToPOI.hidden = YES;
            cell.phoneButton.hidden = YES;
            cell.webButton.hidden = YES;
            cell.mapButton.hidden = YES;
            cell.userInteractionEnabled = NO;
        }
    
    } else {
        
        cell.searchAnnotation = [DataSource sharedInstance].searchResultsAnnotations[indexPath.row];
        cell.poiName.text = cell.searchAnnotation.title;
        [cell.favoriteButton setFavoriteButtonState:cell.searchAnnotation.favoriteState];
        [self setImageForCellCategoryButton:cell];
        
        [self setDistanceToPoiText:cell];
        
    }
    
    cell.layoutMargins = UIEdgeInsetsZero;
    
    return cell;
}

- (void) setImageForCellCategoryButton:(POITableViewCell *)cell {
    cell.categoryImage.image = [cell.searchAnnotation setImageForCategory:cell.searchAnnotation.category];
}


- (void)setDistanceToPoiText:(POITableViewCell *)cell {
    cell.searchAnnotation.distanceToUser = [[DataSource sharedInstance] findDistanceFromUser:cell.searchAnnotation];
    CLLocationDistance distanceInMiles = cell.searchAnnotation.distanceToUser * kPTMetersToMilesConversion;
    
    NSString *textToDisplay;

    if (distanceInMiles < 1.0) {
        textToDisplay = @"<1 mi away";

    } else {
        textToDisplay = [NSString stringWithFormat:@"%.01f mi away", distanceInMiles];
    }
    
    cell.distanceToPOI.text = textToDisplay;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {

        SearchAnnotation *tappedAnnotation = [DataSource sharedInstance].favoriteLocations[indexPath.row];
        [DataSource sharedInstance].lastTappedAnnotation = tappedAnnotation;
        [DataSource sharedInstance].locationWasTapped = YES;
        

        CATransition *transition = [CATransition animation];
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        transition.duration = 0.45;
        [transition setType:kCATransitionPush];
        transition.subtype = kCATransitionFromRight;
        transition.delegate = self;
        [self.navigationController.view.layer addAnimation:transition forKey:nil];
        
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController popToRootViewControllerAnimated:NO];
    } else {
        SearchAnnotation *tappedAnnotation = [DataSource sharedInstance].searchResultsAnnotations[indexPath.row];
        [DataSource sharedInstance].lastTappedAnnotation = tappedAnnotation;
        [DataSource sharedInstance].locationWasTapped = YES;
        
        CATransition *transition = [CATransition animation];
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        transition.duration = 0.45;
        [transition setType:kCATransitionPush];
        transition.subtype = kCATransitionFromRight;
        transition.delegate = self;
        [self.navigationController.view.layer addAnimation:transition forKey:nil];
        
        self.navigationController.navigationBarHidden = NO;
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 110;
}

- (void) mapTapped:(UIBarButtonItem *)sender {
    
    CATransition *transition = [CATransition animation];
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    transition.duration = 0.45;
    [transition setType:kCATransitionPush];
    transition.subtype = kCATransitionFromRight;
    transition.delegate = self;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController popToRootViewControllerAnimated:NO];
    
}

#pragma mark - POITableViewCellDelegate

- (void) cellDidPressLikeButton:(POITableViewCell *)cell {
    
    [[DataSource sharedInstance] toggleFavoriteStatus:cell.searchAnnotation];
    [cell.favoriteButton setFavoriteButtonState:cell.searchAnnotation.favoriteState];

}

- (void) cellDidPressPhoneButton:(CalloutAnnotationView *)annotationView {
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

- (void) cellDidPressWebButton:(CalloutAnnotationView *)annotationView {
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

- (void) cellDidPressMapButton:(CalloutAnnotationView *)annotationView {
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

#pragma mark - KVO

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == [DataSource sharedInstance] && [keyPath isEqualToString:@"favoriteLocations"]) {
        
        int kindOfChange = [change[NSKeyValueChangeKindKey] intValue];
        
        if (kindOfChange == NSKeyValueChangeSetting ||
            kindOfChange == NSKeyValueChangeInsertion ||
            kindOfChange == NSKeyValueChangeRemoval ||
            kindOfChange == NSKeyValueChangeReplacement) {
            //Someone set a brand new annotations array
            [self.tableView reloadData];

        }
    }
}

- (void) dealloc {
    [[DataSource sharedInstance] removeObserver:self forKeyPath:@"favoriteLocations"];
}

@end
