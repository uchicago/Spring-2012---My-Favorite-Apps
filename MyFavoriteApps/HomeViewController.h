//
//  HomeViewController.h
//  MyFavoriteApps
//
//  Created by T. Binkowski on 5/17/12.
//  Copyright (c) 2012 University of Chicago. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UITableViewController 
<NSFetchedResultsControllerDelegate,UISearchDisplayDelegate,UISearchBarDelegate>

@property (nonatomic,strong) NSManagedObjectContext* managedObjectContext;
@property (nonatomic,strong) NSFetchedResultsController* fetchedResultsController;
@end
