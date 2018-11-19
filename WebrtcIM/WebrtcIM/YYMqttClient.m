//
//  YYMqttClient.m
//  WebrtcIM
//
//  Created by luowei on 2018/11/19.
//  Copyright © 2018年 luowei. All rights reserved.
//

#import "YYMqttClient.h"
#import "MQTTClient.h"

@interface YYMqttClient()<MQTTSessionManagerDelegate>
@property (strong, nonatomic) MQTTSessionManager *manager;
@property (nonatomic, strong) NSString *clientId;
@end
@implementation YYMqttClient


static YYMqttClient *_imManager;
+(YYMqttClient *)shareInstance{
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        _imManager = [[YYMqttClient alloc]init];
    });
    return _imManager;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.host = @"192.168.7.63";
        self.port = 1883;
    }
    return self;
}


/**
 连接服务器
 */
- (void)connect{
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.clientId = delegate.client;
    if (!self.manager) {
        self.manager = [[MQTTSessionManager alloc] init];
        self.manager.delegate = self;
        self.manager.subscriptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:MQTTQosLevelExactlyOnce]
                                                                 forKey:[self getTopic:self.clientId]];
        
        [self.manager connectTo:self.host
                           port:self.port
                            tls:FALSE
                      keepalive:60
                          clean:FALSE
                           auth:FALSE
                           user:self.clientId
                           pass:nil will:TRUE
                      willTopic:[self getWillTopic]
                        willMsg:[@"offline" dataUsingEncoding:NSUTF8StringEncoding]
                        willQos:MQTTQosLevelExactlyOnce
                 willRetainFlag:FALSE
                   withClientId:self.clientId
                 securityPolicy:nil
                   certificates:nil
                  protocolLevel:MQTTProtocolVersion311
                 connectHandler:^(NSError *error) {
                     
                 }];
    } else {
        [self.manager connectToLast:^(NSError *error) {
            
        }];
    }
    
    /*
     * MQTTCLient: observe the MQTTSessionManager's state to display the connection status
     */
    
    [self.manager addObserver:self
                   forKeyPath:@"state"
                      options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                      context:nil];
}

- (NSString *)getTopic:(NSString*)toUser{
    return [NSString stringWithFormat:@"/m/s/%@",toUser];
}

- (NSString *)getWillTopic{
    return [NSString stringWithFormat:@"/chat/will/%@",self.clientId];
}



/**
 发送消息
 
 @param message 消息体
 @param handler 发送回调
 */
- (void)sendMessage:(NSString*)message toUser:(NSString*)toUser{
    if (self.manager) {
         NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
        [self.manager sendData:data topic:[self getTopic:toUser] qos:MQTTQosLevelExactlyOnce retain:FALSE];
    }
}

#pragma mark - MQTTSessionManagerDelegate

/*
 * MQTTSessionManagerDelegate
 */
- (void)handleMessage:(NSData *)data onTopic:(NSString *)topic retained:(BOOL)retained {
    /*
     * MQTTClient: process received message
     */
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    if ([dict objectForKey:@"message"]) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"消息" message:[dict objectForKey:@"message"] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    } else if ([dict objectForKey:@"sdp"] || dict[@"type"]){
        AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [WebRTCClient sharedInstance].myJID = delegate.client;
        [WebRTCClient sharedInstance].remoteJID = delegate.remoteClient;
        [[NSNotificationCenter defaultCenter] postNotificationName:kReceivedSinalingMessageNotification object:dict];
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    switch (self.manager.state) {
        case MQTTSessionManagerStateClosed:
            NSLog(@"closed");
            break;
        case MQTTSessionManagerStateClosing:
            NSLog(@"closing");
            break;
        case MQTTSessionManagerStateConnected:
            NSLog(@"connected");
            break;
        case MQTTSessionManagerStateConnecting:
            NSLog(@"connecting");
            break;
        case MQTTSessionManagerStateError:
            NSLog(@"error");
            break;
        case MQTTSessionManagerStateStarting:
        default:
            NSLog(@"not connected");
            break;
    }
}
@end
