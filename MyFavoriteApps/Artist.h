//
//  Artist.h
//  MyFavoriteApps
//
//  Created by T. Binkowski on 5/17/12.
//  Copyright (c) 2012 University of Chicago. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Application;

@interface Artist : NSManagedObject

@property (nonatomic, retain) NSString * artistId;
@property (nonatomic, retain) NSString * artistName;
@property (nonatomic, retain) NSSet *applications;
@end

@interface Artist (CoreDataGeneratedAccessors)

- (void)addApplicationsObject:(Application *)value;
- (void)removeApplicationsObject:(Application *)value;
- (void)addApplications:(NSSet *)values;
- (void)removeApplications:(NSSet *)values;

@end
