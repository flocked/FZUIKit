//
//  _ObjectProxy.h
//  
//
//  Created by Florian Zand on 26.01.25.
//

#import <Foundation/Foundation.h>

@interface _ProxyInvocation : NSObject

@property (nonatomic, strong) id target;
@property (nonatomic) SEL selector;
@property (nonatomic, strong) NSArray *arguments;
@property (nonatomic, strong) id returnValue;

- (instancetype)initWithInvocation:(NSInvocation *)invocation;
- (void)invoke;

@end

@interface _ObjectProxy : NSProxy

@property (nonatomic, strong) id target;
@property (nonatomic, copy, nullable) void (^invocationHandler)(_ProxyInvocation *invocation);

- (instancetype)initWithTarget:(id)target;

@end

@interface NSObject (Proxy)

- (instancetype)_objectProxy;
- (instancetype)_objectProxyWithHandler:(void (^)(_ProxyInvocation *invocation))handler;

@end

@implementation NSObject (Proxy)

- (instancetype)_objectProxy {
    return (id)[[_ObjectProxy alloc] initWithTarget:self];
}

- (instancetype)_objectProxyWithHandler:(void (^)(_ProxyInvocation *invocation))handler {
    _ObjectProxy *proxy = [[_ObjectProxy alloc] initWithTarget:self];
    proxy.invocationHandler = handler;
    return (id)proxy;
}

@end
