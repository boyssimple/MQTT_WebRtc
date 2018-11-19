//
//  YYMqttClient.h
//  WebrtcIM
//
//  Created by luowei on 2018/11/19.
//  Copyright © 2018年 luowei. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface YYMqttClient : NSObject

@property (nonatomic, strong) NSString *host;
@property (nonatomic, assign) UInt32 port;
@property (nonatomic, assign) NSTimeInterval timeout;
+(YYMqttClient *)shareInstance;
- (void)connect;
- (void)sendMessage:(NSString*)message toUser:(NSString*)toUser;
@end

NS_ASSUME_NONNULL_END
