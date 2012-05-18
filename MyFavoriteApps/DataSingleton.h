//
//  DataSingleton.h
//  MyFavoriteApps
//
//  Created by T. Binkowski on 5/17/12.
//  Copyright (c) 2012 University of Chicago. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataSingleton : NSObject

// The applications core data context
@property (strong,nonatomic) NSManagedObjectContext *managedObjectContext;

// Methods
+ (id)sharedInstance;
- (void)loadDefaultData;
- (void) deleteAllObjects: (NSString *) entityDescription;
@end
