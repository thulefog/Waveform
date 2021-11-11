//
//  BridgedTemplate.hpp
//
//  Created by John Matthew Weston in April 2017
//  Revised January 2018, October 2021
//
//  Copyright © 2017-2021. All rights reserved.
//

#ifndef BridgedTemplate_hpp
#define BridgedTemplate_hpp

#import <Foundation/Foundation.h>

#include <stdio.h>

struct BridgedAdapter;

@interface BridgedPort: NSObject {
    struct BridgedAdapter *_wrappedOuterInstancePointer;
}

@property (nonatomic) void* _Nullable _pointerToImplementationInnerBinding;

@property (strong, nonatomic) id _key;

- (id) init;
- (void) dealloc;
- (void) pass: (double[]) data;
- (void)processDataOuter:(const float * _Nonnull)array count:(NSInteger)count output:(float * _Nonnull)outputArray;
    
@end

#endif /* BridgedTemplate_hpp */
