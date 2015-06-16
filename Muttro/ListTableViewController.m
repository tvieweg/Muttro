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

@interface ListTableViewController () <POITableViewCellDelegate>

@end

@implementation ListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[POITableViewCell class] forCellReuseIdentifier:@"POICell"];
    
    UIBarButtonItem *mapButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"maps"] style:UIBarButtonItemStylePlain target:self action:@selector(mapTapped:)];
    
    self.navigationItem.hidesBackButton = YES;
    
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
        return [DataSource sharedInstance].searchResults.mapItems.count;
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

            SearchAnnotation *favItem = [DataSource sharedInstance].favoriteLocations[indexPath.row];
            cell.poiName.text = favItem.title;
            [cell.favoriteButton setFavoriteButtonState:favItem.favoriteState];
            
        } else {
            cell.poiName.text = @"Star items to favorite";
            cell.poiName.textColor = [UIColor grayColor];
            //TODO make italic
        }
    
    } else {
        
        MKMapItem *searchItem = [DataSource sharedInstance].searchResults.mapItems[indexPath.row];
        cell.poiName.text = searchItem.name;
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        SearchAnnotation *tappedAnnotation = [DataSource sharedInstance].favoriteLocations[indexPath.row];
        [DataSource sharedInstance].lastTappedCoordinate = tappedAnnotation.coordinate;
        [DataSource sharedInstance].locationWasTapped = YES;
    } else {
        MKMapItem *tappedMapItem = [DataSource sharedInstance].searchResults.mapItems[indexPath.row];
        [DataSource sharedInstance].lastTappedCoordinate = tappedMapItem.placemark.coordinate;
        [DataSource sharedInstance].locationWasTapped = YES;
    }

    [self.navigationController popToRootViewControllerAnimated:YES];
     

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

- (void) cellDidPressLikeButton:(POITableViewCell *)cell {
    NSLog(@"Favorite button pressed");
    
    //If cell is in favorites, toggle favorites. If it's in search annotations, toggle from search annotations. Reload favorites table. 

}

@end
