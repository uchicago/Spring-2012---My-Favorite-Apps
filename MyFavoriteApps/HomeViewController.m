//
//  HomeViewController.m
//  MyFavoriteApps
//
//  Created by T. Binkowski on 5/17/12.
//  Copyright (c) 2012 University of Chicago. All rights reserved.
//

#import "HomeViewController.h"
#import "DataSingleton.h"
#import "Application.h"
#import "Artist.h"
#import "Category.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

@synthesize fetchedResultsController = __fetchedResultsController;
@synthesize managedObjectContext = __managedObjectContext;

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Lifecycle
////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
   
    // Fetch the data
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Fetched results controller Delegate
////////////////////////////////////////////////////////////////////////////////
/*******************************************************************************
 * @method          fetchedResultsController
 * @abstract        <# Abstract #>
 * @description     <# Description #>
 ******************************************************************************/
- (NSFetchedResultsController *)fetchedResultsController 
{    
    if (__fetchedResultsController != nil) {
        return __fetchedResultsController; 
    }
    
    // Create and configure a fetch request with the Book entity.
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Application"];
    
	// Create the sort descriptors array.
	NSSortDescriptor *authorDescriptor = [[NSSortDescriptor alloc] initWithKey:@"artist.artistName" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:authorDescriptor, nil];
	[fetchRequest setSortDescriptors:sortDescriptors];
	
	// Create and initialize the fetch results controller.
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                        managedObjectContext:self.managedObjectContext 
                                                                          sectionNameKeyPath:@"artist.artistName" cacheName:nil];
	self.fetchedResultsController.delegate = self;
	return self.fetchedResultsController;
}    

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Table view data source
////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ApplicationCell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

/*******************************************************************************
 * @method          configureCell:
 * @abstract        <# Abstract #>
 * @description     <# Description #>
 ******************************************************************************/
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    Application *app = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = app.trackName;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Section Index
////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	// Display the authors' names as section headings.
    return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
    return [self.fetchedResultsController sectionIndexTitles];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*******************************************************************************
 * @method          tableView:commitEditingStyle:
 * @abstract        <# Abstract #>
 * @description     <# Description #>
 ******************************************************************************/
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSError *error;
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
         
         [self.tableView beginUpdates]; // Avoid  NSInternalInconsistencyException

         // Delete the role object that was swiped
         Application *toDelete = [self.fetchedResultsController objectAtIndexPath:indexPath];
         NSLog(@"Deleting (%@)", toDelete.trackName);
         [self.managedObjectContext deleteObject:toDelete];
         
        // Save
        if (![self.managedObjectContext save:&error]) {
            // Handle the error.
        }
        
         // Delete the (now empty) row on the table
         [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
       
        // Fetch the data
        if (![[self fetchedResultsController] performFetch:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            exit(-1);  // Fail
        }
        
        [self.tableView endUpdates];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Search
/*******************************************************************************
 * @method          filterContentForSearchText:searchText scope:
 * @abstract        <# Abstract #>
 * @description     <# Description #>
 ******************************************************************************/
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSString *query = self.searchDisplayController.searchBar.text;
    if (query && query.length) {
        NSLog(@"SearchString:%@ Query:%@",searchText,query);  
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"trackName contains[cd] %@", query];
        [self.fetchedResultsController.fetchRequest setPredicate:predicate];
    }
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error])
        NSLog(@"Error: %@", [error localizedDescription]);
}

/*******************************************************************************
 * @method          searchDisplayController
 * @abstract        <# Abstract #>
 * @description     <# Description #>
 ******************************************************************************/
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    NSLog(@"Search String:%@",searchString);
    [self filterContentForSearchText:searchString scope:nil];
    return YES;
}
@end
