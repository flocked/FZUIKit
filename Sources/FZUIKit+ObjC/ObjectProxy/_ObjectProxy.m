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

// Forward messages to the target object
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [_target methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    NSLog(@"invocation %@", NSStringFromSelector(invocation.selector));
    [invocation setTarget:_target];
    [invocation invoke];
    
    NSArray *argumentsArray = [self argumentsFromInvocation: invocation];
    
    const char *returnType = invocation.methodSignature.methodReturnType;
    if (strcmp(returnType, "v") == 0) {
        _InvocationResult *result = [[_InvocationResult alloc] initWithSelector: NSStringFromSelector(invocation.selector)
                                                                  arguments: argumentsArray
                                                               returnValue: nil];
    } else {
      //  id returnValue;
      //  [invocation getReturnValue:&returnValue];
        _InvocationResult *result = [[_InvocationResult alloc] initWithSelector: NSStringFromSelector(invocation.selector)
                                                                  arguments: argumentsArray
                                                               returnValue: nil];
    }
}

- (NSArray *)argumentsFromInvocation:(NSInvocation *)invocation {
    NSMutableArray *argumentsArray = [NSMutableArray array];
    NSUInteger numberOfArguments = invocation.methodSignature.numberOfArguments;
    
    
    for (NSUInteger i = 2; i < numberOfArguments; i++) { // Skip self (index 0) and _cmd (index 1)
        const char *argType = [invocation.methodSignature getArgumentTypeAtIndex:i];
/*
        if (strcmp(argType, "@") == 0) {
            // Object argument
            id argument;
            [invocation getArgument:&argument atIndex:i];
            [argumentsArray addObject:argument];
        } else if (strcmp(argType, "i") == 0) {
            // Integer argument
            id argument;
            [invocation getArgument:&argument atIndex:i];
            [argumentsArray addObject:argument];
        } else if (strcmp(argType, "f") == 0) {
            // Float argument
            id argument;
            [invocation getArgument:&argument atIndex:i];
            [argumentsArray addObject:argument];
        } else if (strcmp(argType, "d") == 0) {
            // Double argument
            id argument;
            [invocation getArgument:&argument atIndex:i];
            [argumentsArray addObject:argument];
        } else if (strcmp(argType, "c") == 0) {
            id argument;
            [invocation getArgument:&argument atIndex:i];
            [argumentsArray addObject:argument];
        } else if (strcmp(argType, "B") == 0) {
            // BOOL (Boolean) argument
            id argument;
            [invocation getArgument:&argument atIndex:i];
            [argumentsArray addObject:argument];
        } else if (strcmp(argType, "#") == 0) {
            // Class argument
            id argument;
            [invocation getArgument:&argument atIndex:i];
            [argumentsArray addObject:argument];
        } else {
            // Handle other types as needed
           // printf("\t- Unknown type %s\n", argType);
        }
        */
    }
    
    /*
    for (NSUInteger i = 2; i < numberOfArguments; i++) { // Skip self (index 0) and _cmd (index 1)
        void *argument = NULL;
        
        // Allocate space for the argument
        [invocation getArgument:&argument atIndex:i];
        
        // Convert the argument to an object if necessary, else add raw value
        if (argument) {
            id argumentObject = [NSValue valueWithBytes:argument objCType:[invocation.methodSignature getArgumentTypeAtIndex:i]];
            [argumentsArray addObject:argumentObject];
        } else {
            [argumentsArray addObject:[NSNull null]]; // Handle nil values safely
        }
    }
     */
    
    return [argumentsArray copy];
}

@end

@implementation _InvocationResult

- (instancetype)initWithSelector:(NSString *)selector
                        arguments:(NSArray *)arguments
                     returnValue:(id)returnValue {
    self = [super init];
    if (self) {
        _selectorName = selector;
        _arguments = arguments;
        _returnValue = returnValue;
    }
    return self;
}

@end
