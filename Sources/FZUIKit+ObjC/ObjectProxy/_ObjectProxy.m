//
//  MyProxy.m
//  
//
//  Created by Florian Zand on 26.01.25.
//

#import <Foundation/Foundation.h>
#import "include/_ObjectProxy.h"

@implementation _ObjectProxy

- (instancetype)initWithTarget:(id)target {
    _target = target;
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [_target methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation setTarget:_target];
    if (self.invocationHandler) {
        _ProxyInvocation *proxyInvocation = [[_ProxyInvocation alloc] initWithInvocation:invocation];
        self.invocationHandler(proxyInvocation);
    } else {
        [invocation invoke];
    }
}

@end

@implementation _ProxyInvocation {
    NSInvocation *_invocation;
}

- (instancetype)initWithInvocation:(NSInvocation *)invocation {
    self = [super init];
    if (self) {
        _invocation = invocation;
    }
    return self;
}

- (SEL)selector {
    return _invocation.selector;
}

- (void)setSelector:(SEL)selector {
    _invocation.selector = selector;
}

- (id)target {
    return _invocation.target;
}

- (void)setTarget:(id)target {
    _invocation.target = target;
}

- (NSArray *)arguments {
    return [self extractArguments];
}

- (NSArray *)extractArguments {
    NSMutableArray *args = [NSMutableArray array];
    NSMethodSignature *sig = _invocation.methodSignature;
    NSUInteger count = sig.numberOfArguments;

    for (NSUInteger i = 2; i < count; i++) {
        const char *argType = [sig getArgumentTypeAtIndex:i];

        // Skip const/volatile qualifiers for cleaner comparisons
        while (*argType == 'r' || *argType == 'n' || *argType == 'N' ||
               *argType == 'o' || *argType == 'O' || *argType == 'R' || *argType == 'V') {
            argType++;
        }

        // Handle object types
        if (strcmp(argType, "@") == 0) {
            __unsafe_unretained id arg = nil;
            [_invocation getArgument:&arg atIndex:i];
            [args addObject:arg ?: NSNull.null];

        // Handle class objects (Class)
        } else if (strcmp(argType, "#") == 0) {
            Class arg = nil;
            [_invocation getArgument:&arg atIndex:i];
            [args addObject:arg ?: NSNull.null];

        // Handle selectors (SEL)
        } else if (strcmp(argType, ":") == 0) {
            SEL arg = NULL;
            [_invocation getArgument:&arg atIndex:i];
            NSString *selName = arg ? NSStringFromSelector(arg) : @"(null)";
            [args addObject:selName];

        // Handle pointer types (void * and typed pointers)
        } else if (argType[0] == '^') {
            void *ptr = NULL;
            [_invocation getArgument:&ptr atIndex:i];
            if (ptr) {
                // Represent pointer as NSNumber (address)
                [args addObject:[NSValue valueWithPointer:ptr]];
            } else {
                [args addObject:NSNull.null];
            }

        // Handle C arrays (unfortunately encoded as '[') - treat as NSNull (unsupported)
        } else if (argType[0] == '[') {
            [args addObject:NSNull.null];

        // Handle unions
        } else if (argType[0] == '(') {
            NSUInteger argSize = 0;
            NSGetSizeAndAlignment(argType, &argSize, NULL);
            void *buffer = malloc(argSize);
            [_invocation getArgument:buffer atIndex:i];
            NSValue *val = [NSValue valueWithBytes:buffer objCType:argType];
            free(buffer);
            [args addObject:val];

        // Handle structs
        } else if (argType[0] == '{') {
            NSUInteger argSize = 0;
            NSGetSizeAndAlignment(argType, &argSize, NULL);
            void *buffer = malloc(argSize);
            [_invocation getArgument:buffer atIndex:i];
            NSValue *val = [NSValue valueWithBytes:buffer objCType:argType];
            free(buffer);
            [args addObject:val];

        // Handle common scalar types
        } else if (strcmp(argType, "c") == 0) {
            char val = 0;
            [_invocation getArgument:&val atIndex:i];
            [args addObject:@(val)];

        } else if (strcmp(argType, "i") == 0) {
            int val = 0;
            [_invocation getArgument:&val atIndex:i];
            [args addObject:@(val)];

        } else if (strcmp(argType, "s") == 0) {
            short val = 0;
            [_invocation getArgument:&val atIndex:i];
            [args addObject:@(val)];

        } else if (strcmp(argType, "l") == 0) {
            long val = 0;
            [_invocation getArgument:&val atIndex:i];
            [args addObject:@(val)];

        } else if (strcmp(argType, "q") == 0) {
            long long val = 0;
            [_invocation getArgument:&val atIndex:i];
            [args addObject:@(val)];

        } else if (strcmp(argType, "C") == 0) {
            unsigned char val = 0;
            [_invocation getArgument:&val atIndex:i];
            [args addObject:@(val)];

        } else if (strcmp(argType, "I") == 0) {
            unsigned int val = 0;
            [_invocation getArgument:&val atIndex:i];
            [args addObject:@(val)];

        } else if (strcmp(argType, "S") == 0) {
            unsigned short val = 0;
            [_invocation getArgument:&val atIndex:i];
            [args addObject:@(val)];

        } else if (strcmp(argType, "L") == 0) {
            unsigned long val = 0;
            [_invocation getArgument:&val atIndex:i];
            [args addObject:@(val)];

        } else if (strcmp(argType, "Q") == 0) {
            unsigned long long val = 0;
            [_invocation getArgument:&val atIndex:i];
            [args addObject:@(val)];

        } else if (strcmp(argType, "f") == 0) {
            float val = 0;
            [_invocation getArgument:&val atIndex:i];
            [args addObject:@(val)];

        } else if (strcmp(argType, "d") == 0) {
            double val = 0;
            [_invocation getArgument:&val atIndex:i];
            [args addObject:@(val)];

        } else if (strcmp(argType, "B") == 0) {
            bool val = 0;
            [_invocation getArgument:&val atIndex:i];
            [args addObject:@(val)];

        } else {
            // Unknown type — return NSNull
            [args addObject:NSNull.null];
        }
    }

    return [args copy];
}

- (void)setArguments:(NSArray *)arguments {
    NSMethodSignature *sig = _invocation.methodSignature;
    NSUInteger count = sig.numberOfArguments;

    NSAssert(arguments.count == (count - 2), @"Arguments count mismatch");

    for (NSUInteger i = 2; i < count; i++) {
        id arg = arguments[i - 2];
        const char *argType = [sig getArgumentTypeAtIndex:i];

        // Skip const/volatile qualifiers
        while (*argType == 'r' || *argType == 'n' || *argType == 'N' ||
               *argType == 'o' || *argType == 'O' || *argType == 'R' || *argType == 'V') {
            argType++;
        }

        if (strcmp(argType, "@") == 0) {
            // Object
            id value = (arg == NSNull.null) ? nil : arg;
            [_invocation setArgument:&value atIndex:i];

        } else if (strcmp(argType, "#") == 0) {
            // Class
            Class value = (arg == NSNull.null) ? nil : arg;
            [_invocation setArgument:&value atIndex:i];

        } else if (strcmp(argType, ":") == 0) {
            // Selector
            SEL sel = NULL;
            if ([arg isKindOfClass:[NSString class]]) {
                sel = NSSelectorFromString(arg);
            }
            [_invocation setArgument:&sel atIndex:i];

        } else if (argType[0] == '^') {
            // Pointer
            void *ptr = NULL;
            if ([arg isKindOfClass:[NSValue class]]) {
                ptr = [arg pointerValue];
            }
            [_invocation setArgument:&ptr atIndex:i];

        } else if (argType[0] == '(' || argType[0] == '{') {
            // Union or struct
            NSUInteger argSize = 0;
            NSGetSizeAndAlignment(argType, &argSize, NULL);
            void *buffer = malloc(argSize);
            if ([arg isKindOfClass:[NSValue class]] && strcmp([arg objCType], argType) == 0) {
                [arg getValue:buffer];
                [_invocation setArgument:buffer atIndex:i];
            } else {
                // If type mismatch or not NSValue, set zeroed buffer
                memset(buffer, 0, argSize);
                [_invocation setArgument:buffer atIndex:i];
            }
            free(buffer);

        } else if (strcmp(argType, "c") == 0) {
            char val = 0;
            if ([arg respondsToSelector:@selector(charValue)]) val = [arg charValue];
            [_invocation setArgument:&val atIndex:i];

        } else if (strcmp(argType, "i") == 0) {
            int val = 0;
            if ([arg respondsToSelector:@selector(intValue)]) val = [arg intValue];
            [_invocation setArgument:&val atIndex:i];

        } else if (strcmp(argType, "s") == 0) {
            short val = 0;
            if ([arg respondsToSelector:@selector(shortValue)]) val = [arg shortValue];
            [_invocation setArgument:&val atIndex:i];

        } else if (strcmp(argType, "l") == 0) {
            long val = 0;
            if ([arg respondsToSelector:@selector(longValue)]) val = [arg longValue];
            [_invocation setArgument:&val atIndex:i];

        } else if (strcmp(argType, "q") == 0) {
            long long val = 0;
            if ([arg respondsToSelector:@selector(longLongValue)]) val = [arg longLongValue];
            [_invocation setArgument:&val atIndex:i];

        } else if (strcmp(argType, "C") == 0) {
            unsigned char val = 0;
            if ([arg respondsToSelector:@selector(unsignedCharValue)]) val = [arg unsignedCharValue];
            [_invocation setArgument:&val atIndex:i];

        } else if (strcmp(argType, "I") == 0) {
            unsigned int val = 0;
            if ([arg respondsToSelector:@selector(unsignedIntValue)]) val = [arg unsignedIntValue];
            [_invocation setArgument:&val atIndex:i];

        } else if (strcmp(argType, "S") == 0) {
            unsigned short val = 0;
            if ([arg respondsToSelector:@selector(unsignedShortValue)]) val = [arg unsignedShortValue];
            [_invocation setArgument:&val atIndex:i];

        } else if (strcmp(argType, "L") == 0) {
            unsigned long val = 0;
            if ([arg respondsToSelector:@selector(unsignedLongValue)]) val = [arg unsignedLongValue];
            [_invocation setArgument:&val atIndex:i];

        } else if (strcmp(argType, "Q") == 0) {
            unsigned long long val = 0;
            if ([arg respondsToSelector:@selector(unsignedLongLongValue)]) val = [arg unsignedLongLongValue];
            [_invocation setArgument:&val atIndex:i];

        } else if (strcmp(argType, "f") == 0) {
            float val = 0;
            if ([arg respondsToSelector:@selector(floatValue)]) val = [arg floatValue];
            [_invocation setArgument:&val atIndex:i];

        } else if (strcmp(argType, "d") == 0) {
            double val = 0;
            if ([arg respondsToSelector:@selector(doubleValue)]) val = [arg doubleValue];
            [_invocation setArgument:&val atIndex:i];

        } else if (strcmp(argType, "B") == 0) {
            bool val = 0;
            if ([arg respondsToSelector:@selector(boolValue)]) val = [arg boolValue];
            [_invocation setArgument:&val atIndex:i];

        } else {
            // Unknown type, set NULL or zero
            NSUInteger argSize = 0;
            NSGetSizeAndAlignment(argType, &argSize, NULL);
            void *buffer = calloc(1, argSize);
            [_invocation setArgument:buffer atIndex:i];
            free(buffer);
        }
    }
}

- (id)returnValue {
    return [self extractReturnValue];
}

- (id)extractReturnValue {
    const char *returnType = _invocation.methodSignature.methodReturnType;
    if (strcmp(returnType, @encode(void)) == 0) {
        return nil;
    }

    #define WRAP(type) ^{ \
        type value = 0; \
        [_invocation getReturnValue:&value]; \
        return @(value); \
    }()

    if (strcmp(returnType, @encode(BOOL)) == 0) return WRAP(BOOL);
    if (strcmp(returnType, @encode(int)) == 0) return WRAP(int);
    if (strcmp(returnType, @encode(unsigned int)) == 0) return WRAP(unsigned int);
    if (strcmp(returnType, @encode(short)) == 0) return WRAP(short);
    if (strcmp(returnType, @encode(unsigned short)) == 0) return WRAP(unsigned short);
    if (strcmp(returnType, @encode(long)) == 0) return WRAP(long);
    if (strcmp(returnType, @encode(unsigned long)) == 0) return WRAP(unsigned long);
    if (strcmp(returnType, @encode(long long)) == 0) return WRAP(long long);
    if (strcmp(returnType, @encode(unsigned long long)) == 0) return WRAP(unsigned long long);
    if (strcmp(returnType, @encode(float)) == 0) return WRAP(float);
    if (strcmp(returnType, @encode(double)) == 0) return WRAP(double);
    if (strcmp(returnType, @encode(char)) == 0) return WRAP(char);
    if (strcmp(returnType, @encode(unsigned char)) == 0) return WRAP(unsigned char);

    if (strcmp(returnType, @encode(id)) == 0 || returnType[0] == '@') {
        __unsafe_unretained id value = nil;
        [_invocation getReturnValue:&value];
        return value;
    }

    if (returnType[0] == '^') { // pointer
        void *ptr = NULL;
        [_invocation getReturnValue:&ptr];
        return [NSValue valueWithPointer:ptr];
    }

    if (returnType[0] == '{') { // struct
        NSUInteger size = 0;
        NSGetSizeAndAlignment(returnType, &size, NULL);
        void *buffer = malloc(size);
        [_invocation getReturnValue:buffer];
        NSValue *value = [NSValue valueWithBytes:buffer objCType:returnType];
        free(buffer);
        return value;
    }

    if (returnType[0] == '(') { // union
        NSUInteger size = 0;
        NSGetSizeAndAlignment(returnType, &size, NULL);
        void *buffer = malloc(size);
        [_invocation getReturnValue:buffer];
        NSValue *value = [NSValue valueWithBytes:buffer objCType:returnType];
        free(buffer);
        return value;
    }

    return nil;
}

- (void)setReturnValue:(id)value {
    const char *returnType = _invocation.methodSignature.methodReturnType;
    if (strcmp(returnType, @encode(void)) == 0) return;

    #define UNWRAP(type, selector) { \
        type v = [value selector]; \
        [_invocation setReturnValue:&v]; \
        return; \
    }

    if ([value isKindOfClass:[NSNumber class]]) {
        if (strcmp(returnType, @encode(BOOL)) == 0) UNWRAP(BOOL, boolValue);
        if (strcmp(returnType, @encode(int)) == 0) UNWRAP(int, intValue);
        if (strcmp(returnType, @encode(unsigned int)) == 0) UNWRAP(unsigned int, unsignedIntValue);
        if (strcmp(returnType, @encode(short)) == 0) UNWRAP(short, shortValue);
        if (strcmp(returnType, @encode(unsigned short)) == 0) UNWRAP(unsigned short, unsignedShortValue);
        if (strcmp(returnType, @encode(long)) == 0) UNWRAP(long, longValue);
        if (strcmp(returnType, @encode(unsigned long)) == 0) UNWRAP(unsigned long, unsignedLongValue);
        if (strcmp(returnType, @encode(long long)) == 0) UNWRAP(long long, longLongValue);
        if (strcmp(returnType, @encode(unsigned long long)) == 0) UNWRAP(unsigned long long, unsignedLongLongValue);
        if (strcmp(returnType, @encode(float)) == 0) UNWRAP(float, floatValue);
        if (strcmp(returnType, @encode(double)) == 0) UNWRAP(double, doubleValue);
        if (strcmp(returnType, @encode(char)) == 0) UNWRAP(char, charValue);
        if (strcmp(returnType, @encode(unsigned char)) == 0) UNWRAP(unsigned char, unsignedCharValue);
    }

    if (strcmp(returnType, @encode(id)) == 0 || returnType[0] == '@') {
        id obj = value;
        [_invocation setReturnValue:&obj];
        return;
    }

    if ([value isKindOfClass:[NSValue class]]) {
        if (returnType[0] == '^') { // pointer
            void *ptr = [value pointerValue];
            [_invocation setReturnValue:&ptr];
            return;
        }

        if (returnType[0] == '{' || returnType[0] == '(') { // struct or union
            NSUInteger size = 0;
            NSGetSizeAndAlignment(returnType, &size, NULL);
            void *buffer = malloc(size);
            [value getValue:buffer];
            [_invocation setReturnValue:buffer];
            free(buffer);
            return;
        }
    }
}

- (void)invoke {
    [_invocation invoke];
}

@end
