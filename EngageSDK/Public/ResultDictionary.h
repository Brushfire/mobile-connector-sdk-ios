//
//  ResultDictionary.h
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/25/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResultDictionary : NSObject

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (id)valueForShortPath:(NSString *)shortPath;

- (BOOL) isSuccess;
- (NSString *)faultString;
- (int)errorId;
- (NSString *)recipientId;
- (NSString *)valueForColumnName:(NSString *)columnName;

@end
