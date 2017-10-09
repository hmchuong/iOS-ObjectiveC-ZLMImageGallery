//
//  ZLMThreadSafeMutableDictionary.h
//  PhoneBook
//
//  Created by chuonghm on 8/9/17.
//  Copyright © 2017 VNG Corp., Zalo Group. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 ZLMThreadSafeMutableDictionary
 */
@interface ZLMThreadSafeMutableDictionary : NSObject

// For supscript
- (id)objectForKeyedSubscript:(id)key;
- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying>)key;

/**
 Convert to NSDictionray

 @return NSDictionary contains all <key,value>
 */
- (NSDictionary *)toNSDictionary;

/**
 Remove object for key

 @param key - representing object
 */
- (void)removeObjectForkey:(id <NSCopying>)key;

/**
 Remove all object in dictionary
 */
- (void)removeAllObjects;

/**
 Get all keys

 @return array of keys
 */
- (NSArray *)allKeys;

/**
 Get all values

 @return array of values
 */
- (NSArray *)allValues;

@end
