//
//  Application.h
//  MyFavoriteApps
//
//  Created by T. Binkowski on 5/17/12.
//  Copyright (c) 2012 University of Chicago. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Artist, Category;

@interface Application : NSManagedObject

@property (nonatomic, retain) NSString * trackId;
@property (nonatomic, retain) NSString * trackName;
@property (nonatomic, retain) NSData * iconData;
@property (nonatomic, retain) Artist *artist;
@property (nonatomic, retain) NSSet *categories;
@end

@interface Application (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(Category *)value;
- (void)removeCategoriesObject:(Category *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

@end
