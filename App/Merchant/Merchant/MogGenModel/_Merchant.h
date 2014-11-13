// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Merchant.h instead.

#import <CoreData/CoreData.h>


extern const struct MerchantAttributes {
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *walletAddress;
} MerchantAttributes;

extern const struct MerchantRelationships {
} MerchantRelationships;

extern const struct MerchantFetchedProperties {
} MerchantFetchedProperties;





@interface MerchantID : NSManagedObjectID {}
@end

@interface _Merchant : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MerchantID*)objectID;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* walletAddress;



//- (BOOL)validateWalletAddress:(id*)value_ error:(NSError**)error_;






@end

@interface _Merchant (CoreDataGeneratedAccessors)

@end

@interface _Merchant (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveWalletAddress;
- (void)setPrimitiveWalletAddress:(NSString*)value;




@end
