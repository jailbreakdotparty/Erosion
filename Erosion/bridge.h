//
//  bridge.h
//  Erosion
//
//  Created by lunginspector on 8/14/26.
//

#ifndef bridge_h
#define bridge_h

#import "Exploits/bad_query.h"
#import <Foundation/Foundation.h>

@interface LSApplicationWorkspace : NSObject
+ (instancetype)defaultWorkspace;
- (bool)openApplicationWithBundleID:(NSString*)bundleID;
@end

#endif /* bridge_h */
