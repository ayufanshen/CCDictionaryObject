//
//  DictionaryObjectContainer.h
//  tataUFO
//
//  Created by Can on 9/15/14.
//  Copyright (c) 2014 http://chencan.github.io. All rights reserved.
//

#import "DictionaryObject.h"

@interface DictionaryObjectContainer : DictionaryObject

@property (nonatomic, strong) NSNumber *start;
@property (nonatomic, strong) NSNumber *total;
@property (nonatomic, strong) NSNumber *limit;

@property (nonatomic, copy) NSString *objClassName;
@property (nonatomic, copy) NSString *objectName;

- (id)initWithObjectArray:(NSArray *)objArray
              objClassName:(NSString *)className
                objectName:(NSString *)objName;
- (id)initWithObjectArray:(NSArray *)objArray
              objClassName:(NSString *)objClassName
                objectName:(NSString *)objName
             needFormatKey:(BOOL)flag;

- (NSArray*)objectArray;

@end
