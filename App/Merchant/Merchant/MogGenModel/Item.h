#import "_Item.h"

extern NSString *const kItemNameKey;
extern NSString *const kItemPriceKey;

@interface Item : _Item {}

- (NSDictionary *)itemAsDict;

@end
