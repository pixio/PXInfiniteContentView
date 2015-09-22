//
//  PXMultiForwarder.m
//  PXMultiForwarder
//
//  Created by Spencer Phippen on 2015/08/17.
//
//

#import "PXMultiForwarder.h"

// http://clang.llvm.org/docs/AutomaticReferenceCounting.html#method-families
static BOOL isSelectorInList(SEL sel, const char* strings[], const int lengths[], int listLength) {
    NSString* name = NSStringFromSelector(sel);
    NSUInteger cLength = [name lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    const char* cName = [name UTF8String];
    
    // Skip leading underscores
    while (*cName == '_') {
        cName++;
        cLength--;
    }
    
    for (int i = 0; i < listLength; i++) {
        if (cLength < lengths[i])
            continue;
        
        int result = memcmp(cName, strings[i], lengths[i]);
        if (result != 0)
            continue;
        
        if (cLength == lengths[i])
            return TRUE;
        
        char after = cName[lengths[i]];
        bool islowercaseAlpha = (after >= 'a') && (after <= 'z');
        if (!islowercaseAlpha)
            return TRUE;
    }
    
    return FALSE;
}
static BOOL isValidSelector(SEL sel) {
    static const char* strings[2] = {"alloc", "init"};
    static int lengths[2] = {5, 4};
    return !isSelectorInList(sel, strings, lengths, 2);
}
static BOOL isSelectorOwning(SEL sel) {
    static const char* strings[3] = {"copy", "mutableCopy", "new"};
    static int lengths[3] = {4, 11, 3};
    return isSelectorInList(sel, strings, lengths, 3);
}

static BOOL shouldCollect(NSMethodSignature* sig) {
    const char* const objEncoding = @encode(NSObject*);
    const char* const classEncoding = @encode(typeof([NSObject class]));
    
    BOOL shouldCollect = (strcmp(objEncoding, [sig methodReturnType]) == 0)
                      || (strcmp(classEncoding, [sig methodReturnType]) == 0);
    return shouldCollect;
}

static BOOL needToChange(NSMethodSignature* sig) {
    const char* const classEncoding = @encode(typeof([NSObject class]));
    return strcmp(classEncoding, [sig methodReturnType]) == 0;
}

static NSMethodSignature* makeSignatureForSignature(NSMethodSignature* sig) {
    if (!needToChange(sig)) {
        return sig;
    }

    NSMutableData* encodingString = [NSMutableData data];
    void (^appendCString)(const char*) = ^(const char* data) {
        [encodingString appendBytes:data length:strlen(data)];
    };
    
    const char* returnType = @encode(id);
    appendCString(returnType);
    
    for (NSUInteger i = 0; i < [sig numberOfArguments]; i++)
        appendCString([sig getArgumentTypeAtIndex:i]);

    [encodingString appendBytes:"\0" length:1];
    
    return [NSMethodSignature signatureWithObjCTypes:[encodingString bytes]];
}

@interface PXMultiForwarder ()
- (PXMultiForwarder*) basicAccumulateWrapperForNSObjectSelector:(SEL)sel;
@end

@implementation PXMultiForwarder

- (instancetype) initWithObjects:(id)firstObject, ... {
    NSMutableArray* objects = [NSMutableArray array];
    va_list argumentList;
    va_start(argumentList, firstObject);
    for (id thisObject = firstObject; thisObject != nil; thisObject = va_arg(argumentList, id)) {
        [objects addObject:thisObject];
    }
    va_end(argumentList);

    return [self initWithArrayOfObjects:objects];
}

- (instancetype) initWithArrayOfObjects:(NSArray*)objects {
    if ([objects count] == 0)
        return nil;
    _wrappedObjects = [objects copy];
    return self;
}

- (void) dealloc {
    [_wrappedObjects release];
    [super dealloc];
}

- (NSMethodSignature*) methodSignatureForSelector:(SEL)sel {
    id firstObject = [_wrappedObjects objectAtIndex:0];
    NSMethodSignature* sig = [firstObject methodSignatureForSelector:sel];
    return makeSignatureForSignature(sig);
}

- (void) forwardInvocation:(NSInvocation*)invocation {
    if (!isValidSelector([invocation selector])) {
        NSLog(@"[ERROR]: PXMultiForwarder asked to forward invalid selector: %@", NSStringFromSelector([invocation selector]));
        NSException* exception = [NSException exceptionWithName:NSInternalInconsistencyException reason:[@"Unforwardable selector sent to PXMultiForwarder: " stringByAppendingString:NSStringFromSelector([invocation selector])] userInfo:nil];
        [exception raise];
    }
    if (shouldCollect([invocation methodSignature])) {
        PXMultiForwarder* wrapper = [self makeAnotherWrapperWithInvocation:invocation];
        [invocation setReturnValue:&wrapper];
    } else {
        for (id obj in _wrappedObjects) {
            [invocation invokeWithTarget:obj];
        }
    }
}

- (Class) class {
    return (Class)[self basicAccumulateWrapperForNSObjectSelector:_cmd];
}

- (Class) superclass {
    return (Class)[self basicAccumulateWrapperForNSObjectSelector:_cmd];
}

- (id) copy {
    return [self basicAccumulateWrapperForNSObjectSelector:_cmd];
}

- (id) mutableCopy {
    return [self basicAccumulateWrapperForNSObjectSelector:_cmd];
}

- (PXMultiForwarder*) basicAccumulateWrapperForNSObjectSelector:(SEL)sel {
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:[NSObject methodSignatureForSelector:sel]];
    [invocation setSelector:sel];
    return [self makeAnotherWrapperWithInvocation:invocation];
}

- (PXMultiForwarder*) makeAnotherWrapperWithInvocation:(NSInvocation*)invocation {
    NSAssert(isValidSelector([invocation selector]), @"Invalid selector for forwarding with PXMultiForwarder");
    BOOL owning = isSelectorOwning([invocation selector]);
    NSMutableArray* toWrap = [NSMutableArray array];
    for (id obj in _wrappedObjects) {
        id returnObject;
        [invocation invokeWithTarget:obj];
        [invocation getReturnValue:&returnObject];
        [toWrap addObject:returnObject];
        if (owning)
            [returnObject release];
    }
    PXMultiForwarder* wrapper = [[PXMultiForwarder alloc] initWithArrayOfObjects:toWrap];
    if (!owning)
        [wrapper autorelease];

    return wrapper;
}

@end
