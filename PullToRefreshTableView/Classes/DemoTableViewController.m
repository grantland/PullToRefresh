//
//  RootViewController.m
//  PullToRefresh
//
//  Created by Leah Culver on 7/25/10.
//  Copyright Plancast 2010. All rights reserved.
//
//  Modified by Grantland Chew 12/5/11.
//

#import "DemoTableViewController.h"


@implementation DemoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Pull to Refresh";
    items = [[NSMutableArray alloc] initWithObjects:@"What time is it?", nil];
}

- (void)refresh {
    [super refresh];

    // Perform refresh
    [self performSelector:@selector(addItem) withObject:nil afterDelay:2.0];
}

- (void)addItem {
    // Add a new time
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSString *now = [dateFormatter stringFromDate:[NSDate date]];
    [items insertObject:[NSString stringWithFormat:@"%@", now] atIndex:0];

    [self.tableView reloadData];

    [self stopLoading];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    cell.textLabel.text = [items objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    return cell;
}

- (void)dealloc {
    [items release];
    [super dealloc];
}

@end

