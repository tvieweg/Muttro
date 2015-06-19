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
    
    [[DataSource sharedInstance] addObserver:self forKeyPath:@"favoriteLocations" options:0 context:nil];
    
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
            
            [cell.favoriteButton setFavoriteButtonState:cell.searchAnnotation.favoriteState];
            cell.favoriteButton.hidden = NO;
            cell.userInteractionEnabled = YES;
            
        } else {
            cell.poiName.text = @"Star items to favorite";
            cell.poiName.textColor = [UIColor grayColor];
            cell.favoriteButton.hidden = YES;
            cell.userInteractionEnabled = NO;
        }
    
    } else {
        
        cell.searchAnnotation = [DataSource sharedInstance].searchResultsAnnotations[indexPath.row];
        cell.poiName.text = cell.searchAnnotation.title;
        [cell.favoriteButton setFavoriteButtonState:cell.searchAnnotation.favoriteState];
        
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
    
    [[DataSource sharedInstance] toggleFavoriteStatus:cell.searchAnnotation];
    [cell.favoriteButton setFavoriteButtonState:cell.searchAnnotation.favoriteState];

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
        } /*else if () {
            //We have an incremental change: inserted, deleted, or replaced images.
            
            //Get a list of the index (or indices) that changed
            NSIndexSet *indexSetOfChanges = change[NSKeyValueChangeIndexesKey];
            
            //Convert this NSIndexSet to an NSArray of NSIndexPaths (which is what the table view animation methods require)
            NSMutableArray *indexPathsThatChanged = [NSMutableArray array];
            [indexSetOfChanges enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                [indexPathsThatChanged addObject:newIndexPath];
            }];
            
            //Call 'beginUpdates' to tell the table view we're about to make changes
            [self.tableView beginUpdates];
            
            //Tell the table view what the changes are
            if (kindOfChange == NSKeyValueChangeInsertion) {
                [self.tableView insertRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            
            } else if (kindOfChange == NSKeyValueChangeRemoval) {
                [self.tableView deleteRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];

            } else if (kindOfChange == NSKeyValueChangeReplacement) {
                [self.tableView reloadRowsAtIndexPaths:indexPathsThatChanged withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
            [self.tableView endUpdates];
            [self.tableView reloadData];

        }*/
        
    }
}

- (void) dealloc {
    [[DataSource sharedInstance] removeObserver:self forKeyPath:@"favoriteLocations"];
}


@end
