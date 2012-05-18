//
//  DataSingleton.m
//  MyFavoriteApps
//
//  Created by T. Binkowski on 5/17/12.
//  Copyright (c) 2012 University of Chicago. All rights reserved.
//

#import "DataSingleton.h"
#import "Application.h"
#import "Category.h"
#import "Artist.h"

//#import "GTMHTTPFetcher.h"

@implementation DataSingleton

@synthesize managedObjectContext;

/*******************************************************************************
 * @method          sharedInstance
 * @abstract        Create the singleton
 * @description     Not sure about the block stuff, but it words
 ******************************************************************************/
+ (id)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

#pragma mark - Setup
/*******************************************************************************
 * @method      init
 * @abstract    Overwrite the init method to get the date and set the user defaults
 * @description <# description #>
 *******************************************************************************/
- (id)init 
{
    if (self = [super init]) {
        // do extra init here
    }
    return self;
}

#pragma mark - Load Default Data
/*******************************************************************************
 * @method          loadDefaultData
 * @abstract        Load sample data from a plist file in the bundle
 * @description     File named "Data.plist"
 ******************************************************************************/
- (void)loadDefaultData
{ 
   NSString *path = [[NSBundle mainBundle] pathForResource:@"Data" ofType:@"plist"];
   NSArray *data = [NSArray arrayWithContentsOfFile:path];
   NSLog(@"Data:%@",data);
   for (NSDictionary *app in data) {
       NSDictionary *currentDict = [NSDictionary dictionaryWithDictionary:app];
       NSString *artist = [NSString stringWithString:[currentDict objectForKey:@"Artist"]];
       NSString *appName = [NSString stringWithString:[currentDict objectForKey:@"Application"]];
       NSArray *categories = [NSArray arrayWithArray:[[currentDict objectForKey:@"Categories"] componentsSeparatedByString:@","]];
   
       // Call our method to add to core data store
       [self addApplication:appName fromArtist:artist withCategories:categories];
   }	
    
   // Debugging methods 
   //[self dumpCategories];
   //[self dumpArtists];
}

/*******************************************************************************
 * @method          addApplication:fromArtist:withCategories
 * @abstract        Add data to core data store
 * @description     <# Description #>
 ******************************************************************************/
- (void)addApplication:(NSString *)application fromArtist:(NSString *)artist withCategories:(NSArray *)categories
{
    NSLog(@"Adding %@",artist);
    
    // Create a new instance of Application objecte
	Application *app = (Application *)[NSEntityDescription insertNewObjectForEntityForName:@"Application" 
                                                                    inManagedObjectContext:self.managedObjectContext];
    app.trackName = application;
    
    // Create a new Artist object (if needed)
   	NSError *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Artist"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"artistName == %@", artist];
    fetchRequest.propertiesToFetch = [NSArray arrayWithObjects:@"artistName", nil];

    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (fetchedItems.count == 0) {
        Artist *art = (Artist *)[NSEntityDescription insertNewObjectForEntityForName:@"Artist" inManagedObjectContext:self.managedObjectContext];
        art.artistName = artist;
        app.artist = art;  // Add the artist entity to the artist property
    } else {
        app.artist = [fetchedItems lastObject];
    }
    
    // Category stuff
    fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Category"];
    //fetchRequest.propertiesToFetch = [NSArray arrayWithObjects:@"name", nil];  
    NSArray *fetchedItems2 = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    // Create a set of all seen categories
    NSMutableSet *seenCategories = [[NSMutableSet alloc] init];
    for (Category *c in fetchedItems2)
        [seenCategories addObject:c.name];
    
    for (NSString *cs in categories) {
        // Create a new category if we haven't seen it.
        if (![[seenCategories allObjects] containsObject:cs] ) {
            Category *newCat = (Category *)[NSEntityDescription insertNewObjectForEntityForName:@"Category" inManagedObjectContext:self.managedObjectContext];
            newCat.name = cs;
            [newCat addApplicationsObject:app];
            [app addCategoriesObject:newCat];
        }
        
        // Add the data to existing category
        for (Category *c in fetchedItems2) {
            if ([c.name isEqualToString:cs]) {
                [c addApplicationsObject:app];
                [app addCategoriesObject:c];
            }
        }
    }
    
	// Commit the change to on-disk store
	if (![self.managedObjectContext save:&error]) {
		// Handle the error.
	}
}

/*******************************************************************************
 * @method      deleteAllObjects
 * @abstract    <# abstract #>
 * @description <# description #>
 *******************************************************************************/
- (void) deleteAllObjects: (NSString *) entityDescription  
{
    NSError *error;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityDescription];
    NSArray *items = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *managedObject in items) {
        [self.managedObjectContext deleteObject:managedObject];
        NSLog(@"%@ object deleted",entityDescription);
    }
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error deleting %@ - error:%@",entityDescription,error);
    }
}

#pragma mark - Paths
/*******************************************************************************
 * @method          <# Method Name #>
 * @abstract        <# Abstract #>
 * @description     <# Description #>
 ******************************************************************************/
- (NSURL *)applicationCacheDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - API
/*******************************************************************************
 * @method      downloadHome
 * @abstract    <# abstract #>
 * @description <# description #>
 *******************************************************************************/
- (void)downloadHome 
{/*
    if (![self connectedWithMessage:nil]) return;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/home/",API_URL]];    
    GTMHTTPFetcher* myFetcher = [GTMHTTPFetcher fetcherWithRequest:[NSURLRequest requestWithURL:url]];
    [myFetcher beginFetchWithCompletionHandler:^(NSData *retrievedData, NSError *error) {
		if (error != nil) {
            DLog(@"ERROR:%@",error);
		} else {
            NSDictionary *json = [self jsonToDictionary:retrievedData forKey:nil];          
            //DLog(@"%@",json);
            [delegate requestHomeDataDidLoad:[json objectForKey:@"appoftheday"] 
                             popularSearches:[json objectForKey:@"searches"]];		
        }
	}];
    */
}

#pragma mark - Debugging Methods
/*******************************************************************************
 * @method      dumpCategories
 * @abstract    <# abstract #>
 * @description <# description #>
 *******************************************************************************/
- (void)dumpCategories 
{
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Category"];
    
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (Category *c in fetchedItems) {
        NSLog(@"Cat:%@",c.name);
        for (Application *a in c.applications)
            NSLog(@"\t%@",a.trackName);
    }
}

/*******************************************************************************
 * @method      dumpArtists
 * @abstract    <# abstract #>
 * @description <# description #>
 *******************************************************************************/
- (void)dumpArtists
{
    NSError *error = nil;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Artist"];
    
    NSArray *fetchedItems = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    for (Artist *a in fetchedItems) {
        NSLog(@"Artist:%@",a.artistName);
        for (Application *apps in a.applications)
            NSLog(@"\t%@",apps.trackName);
    }
}

/*******************************************************************************
 * @method          dumpDefaults
 * @abstract        <# Abstract #>
 * @description     <# Description #>
 ******************************************************************************/
- (void) dumpUserDefaults 
{
    NSLog(@"Standard User Defaults:%@",[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
}
@end


