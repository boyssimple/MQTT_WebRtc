//
//  ViewController.m
//  WebrtcIM
//
//  Created by luowei on 2018/11/19.
//  Copyright © 2018年 luowei. All rights reserved.
//

#import "ViewController.h"
#import "YYMqttClient.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[YYMqttClient shareInstance] connect];
}

- (IBAction)testConnect:(id)sender {
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [[YYMqttClient shareInstance] sendMessage:@"{\"message\":\"测试信息\"}" toUser:delegate.remoteClient];
}

- (IBAction)videoAction:(id)sender {
    [self startCommunication:YES];
}

- (void)startCommunication:(BOOL)isVideo
{
    AppDelegate *delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    WebRTCClient *client = [WebRTCClient sharedInstance];
    [client startEngine];
    client.myJID = delegate.client;
    client.remoteJID = delegate.remoteClient;
    
    [client showRTCViewByRemoteName:delegate.remoteClient isVideo:isVideo isCaller:YES];
    
}
@end
