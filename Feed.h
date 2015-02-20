//
//  Feed.h
//  RSSReader
//
//  Created by Ziyang Tan on 2/19/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Feed : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * url;

@end
