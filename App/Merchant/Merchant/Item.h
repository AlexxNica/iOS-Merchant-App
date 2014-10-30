//
//  Item.h
//  Merchant
//
//  Created by User on 10/27/14.
//  Copyright (c) 2014 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

extern NSString *const kItemNameKey;
extern NSString *const kItemPriceKey;

@interface Item : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSDate * creation_date;

- (NSDictionary *)itemAsDict;

@end
