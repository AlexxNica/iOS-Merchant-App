// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Merchant.m instead.

#import "_Merchant.h"

const struct MerchantAttributes MerchantAttributes = {
	.name = @"name",
	.walletAddress = @"walletAddress",
};

const struct MerchantRelationships MerchantRelationships = {
};

const struct MerchantFetchedProperties MerchantFetchedProperties = {
};

@implementation MerchantID
@end

@implementation _Merchant

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Merchant" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Merchant";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Merchant" inManagedObjectContext:moc_];
}

- (MerchantID*)objectID {
	return (MerchantID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic name;






@dynamic walletAddress;











@end
