//
//  ListTableViewController.m
//  Muttro
//
//  Created by Trevor Vieweg on 6/9/15.
//  Copyright (c) 2015 Trevor Vieweg. All rights reserved.
//

#import "ListTableViewController.h"
#import "DataSource.h"
#import <MapKit/MapKit.h>

@interface ListTableViewController ()

@end

@implementation ListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0)
    {
        return 1;
    }
    else{
        return [[DataSource sharedInstance].searchResults.mapItems count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return @"Favorites";
    else
        return @"Search Results";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        
        //TODO: Hookup Favorites
        cell.textLabel.text = @"Favorites Go Here";
    
    } else {
        
        MKMapItem *item = [DataSource sharedInstance].searchResults.mapItems[indexPath.row];
        cell.textLabel.text = item.name;
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DataSource *data = [DataSource sharedInstance];
    data.lastTappedItem = data.searchResults.mapItems[indexPath.row];
    [self.navigationController popToRootViewControllerAnimated:YES]; 

}

@end
