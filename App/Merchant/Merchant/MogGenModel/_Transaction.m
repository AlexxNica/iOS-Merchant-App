// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Transaction.m instead.

#import "_Transaction.h"

const struct TransactionAttributes TransactionAttributes = {
	.creation_date = @"creation_date",
};

const struct TransactionRelationships TransactionRelationships = {
	.purchasedItems = @"purchasedItems",
};

const struct TransactionFetchedProperties TransactionFetchedProperties = {
};

@implementation TransactionID
@end

@implementation _Transaction

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Transaction" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Transaction";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Transaction" inManagedObjectContext:moc_];
}

- (TransactionID*)objectID {
	return (TransactionID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic creation_date;






@dynamic purchasedItems;

	
- (NSMutableSet*)purchasedItemsSet {
	[self willAccessValueForKey:@"purchasedItems"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"purchasedItems"];
  
	[self didAccessValueForKey:@"purchasedItems"];
	return result;
}
	






@end
