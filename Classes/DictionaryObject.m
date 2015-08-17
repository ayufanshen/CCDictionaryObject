//
//  UTObject.m
//  tataUFO
//
//  Created by Can on 14-8-18.
//  Copyright (c) 2014年 tataUFO.com. All rights reserved.
//

#import "DictionaryObject.h"
#import "JSONKit.h"
#import "NSString+PropertyName.h"

@interface DictionaryObject ()


@property (nonatomic, strong) NSString *string;
@property (nonatomic, strong) NSMutableDictionary *dictionary;


@end

@implementation DictionaryObject

@dynamic string;


#pragma mark - Life cycle

- (id)init {
    self = [super init];
    if (self) {
        self.dictionary = [NSMutableDictionary dictionary];
    }
    return  self;
}


- (id)initWithDictionary:(NSDictionary *)theDictionary {
    if (!theDictionary) {
        return nil;
    }
    self = [self init];
    if (self) {
//        self.dictionary = [[NSMutableDictionary alloc] initWithDictionary:[NSString formatDicKeyTounderLineName:theDictionary]];
                self.dictionary = [[NSMutableDictionary alloc] initWithDictionary:theDictionary];
    }
    return self;
}


- (id)initWithString:(NSString *)theJsonStr {
    if (!theJsonStr || [theJsonStr length] <= 0) {
        return nil;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[theJsonStr objectFromJSONStringWithParseOptions:JKParseOptionValidFlags]];
    
    self = [self initWithDictionary:dic];
    
    
    unsigned int outCount;
    objc_property_t * props = class_copyPropertyList([self class], &outCount);
    
    for (int i = 0; i < outCount; i++) {
        
        //name:name
        //type:NSString
        //[[dic objectForKey:name] isKindOfClass:type]
        objc_property_t property = props[i];
        NSString *propertyName = [NSString stringWithCString:property_getName(property)
                                                    encoding:NSUTF8StringEncoding];
        
        NSString *propertyType = [NSString stringWithCString:property_getAttributes(property)
                                                    encoding:NSUTF8StringEncoding];
        
        NSString *type;
        if ([propertyType hasPrefix:@"T@"]) {
            type = [propertyType substringWithRange:NSMakeRange(3,[propertyType rangeOfString:@","].location-4)];
            
        }else if ([propertyType hasPrefix:@"TB"]){
            type = @"__NSCFBoolean";
        }
        
        id value = [dic objectForKey:propertyName];
        
        Class valueClass = [value class];
        Class typeClass  = NSClassFromString(type);
        
        if (![valueClass isSubclassOfClass:typeClass])
        {
            DDLogWarn(@"WARNING!! 属性名:%@ 不属于类型:%@ ,值为 %@",propertyName,type,value);
        }
        
    }
    
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    NSString *selectorName = NSStringFromSelector(selector);
    if ([selectorName rangeOfString:@"set"].location == 0) {
        return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
    }
    
    return [NSMethodSignature signatureWithObjCTypes:"@@:"];
}


- (void)forwardInvocation:(NSInvocation *)invocation {
    
    NSString *selectorName = NSStringFromSelector([invocation selector]);
    
    NSString *key = nil;
    if ([selectorName rangeOfString:@"set"].location == 0) {
        key = [[selectorName substringWithRange:NSMakeRange(3, [selectorName length]-4)] underLineName];
        
        id __unsafe_unretained obj;
        [invocation getArgument:&obj atIndex:2];
        
        [self.dictionary setObject:obj ? obj : [NSNull null] forKey:key];
    } else {
        
        
        key = [selectorName underLineName];
        
        id obj = [self.dictionary objectForKey:key];
        [invocation setReturnValue:&obj];
    }
}


- (NSString *)description {
    return [self.dictionary description];
}
#pragma mark - Interface

+ (id)objectWithString:(NSString *)theJsonStr {
    id newInstance = [[[self class] alloc] initWithString:theJsonStr];
    return newInstance;
}


+ (id)objectWithDictionary:(NSDictionary *)theDictionary {
    id newInstance = [[[self class] alloc] initWithDictionary:theDictionary];
    return newInstance;
}


- (NSString *)string {
    if (self.dictionary) {
        NSString *result = [self.dictionary JSONString];
        return result;
    }
    return nil;
}


- (void)setString:(NSString *)theJsonStr {
    NSMutableDictionary *dic = (NSMutableDictionary *)[theJsonStr objectFromJSONStringWithParseOptions:JKParseOptionValidFlags];
    if (!dic) {
        return ;
    }
    self.dictionary = dic;
}



#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)coder {
    
    self = [super init];
    if(self != nil) {
        NSDictionary * dic = [coder decodeObjectForKey:@"dictionary"];
        self.dictionary = [NSMutableDictionary dictionaryWithDictionary:dic];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    
    if (self.dictionary) {
        [coder encodeObject:self.dictionary forKey:@"dictionary"];
    } else {
        [coder encodeObject:@[] forKey:@"dictionary"];
    }
}
@end
