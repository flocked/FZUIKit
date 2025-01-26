//
//  _ObjectProxy.h
//  
//
//  Created by Florian Zand on 26.01.25.
//

#import <Foundation/Foundation.h>

@interface _ObjectProxy : NSProxy

@property (nonatomic, strong) id target;

- (instancetype)initWithTarget:(id)target;

@end

@interface NSObject (Proxy)

- (instancetype)_objectProxy;

@end

@implementation NSObject (Proxy)

- (instancetype)_objectProxy {
    return (id)[[_ObjectProxy alloc] initWithTarget:self];
}

@end

@interface _InvocationResult : NSObject

@property (nonatomic, strong) NSString *selectorName;
@property (nonatomic, strong) NSArray *arguments;
@property (nonatomic, strong) id returnValue;

- (instancetype)initWithSelector:(NSString *)selector
                        arguments:(NSArray *)arguments
                     returnValue:(id)returnValue;

@end
