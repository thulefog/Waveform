//
//  BridgedTemplate.mm
//
//  Created by John Matthew Weston in April 2017
//  Revised January 2018, October 2021
//
//  Copyright © 2017-2021. All rights reserved.
//

#include "BridgeTemplate.hpp"
#include "TimeDomainMeasures.h"

#include <iterator>
#include <vector>
using namespace std;

struct BridgedAdapter {
    TimeDomainMeasures *_wrappedInnerInstancePointer;
};

// Pointer to implementation, outer

@implementation BridgedPort

- (id) init {
    if (self = [super init]) {
        _wrappedOuterInstancePointer = new BridgedAdapter();
        _wrappedOuterInstancePointer->_wrappedInnerInstancePointer = new TimeDomainMeasures();
        
        //alternative
        TimeDomainMeasures* tdm = new TimeDomainMeasures();
        self._pointerToImplementationInnerBinding = (void *)tdm;
        
    } return self;
}

- (void) dealloc {
    delete _wrappedOuterInstancePointer->_wrappedInnerInstancePointer;
    delete _wrappedOuterInstancePointer;
}

-(void)processDataOuter:(const float * _Nonnull)array count:(NSInteger)count output:(float * _Nonnull)outputArray {
    TimeDomainMeasures tdm;
    tdm.processDataInner(array, (int)count, outputArray);
}

- (void) pass: (double[]) data andDataLength: (int) dataLength {
    double x[] = { 1, 2, 3, 4, 5 };
    std::vector<double> v(std::begin(x), std::end(x));
    std::vector<double> vector_storage(data, data + dataLength);
    //std::vector<double> v(std::begin(data), std::end(data));
}
- (void) execute: ( void *) data {
    cout << "execute" << endl;
}

@end

