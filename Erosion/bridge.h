//
//  bridge.h
//  Erosion
//
//  Created by lunginspector on 8/14/26.
//

#ifndef bridge_h
#define bridge_h

#import "Libraries/libarchive/libarchive.h"
#import "Exploits/worse_query.h"
#import "Exploits/pathleak.h"
#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>

typedef struct CF_BRIDGED_TYPE(id) __SecTask *SecTaskRef;

SecTaskRef _Nullable SecTaskCreateFromSelf(CFAllocatorRef _Nullable allocator) CF_RETURNS_RETAINED;

CFTypeRef _Nullable SecTaskCopyValueForEntitlement(SecTaskRef _Nonnull task, CFStringRef _Nonnull entitlement, CFErrorRef _Nullable * _Nullable error) CF_RETURNS_RETAINED;

@interface LSApplicationWorkspace : NSObject
+ (instancetype)defaultWorkspace;
- (bool)openApplicationWithBundleID:(NSString*)bundleID;
@end

#endif /* bridge_h */
