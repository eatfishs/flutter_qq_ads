#import "FlutterQqAdsPlugin.h"
#import "GDTSDKConfig.h"
#import "SplashPage.h"
#import "InterstitialPage.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>

@interface FlutterQqAdsPlugin()
@property (strong, nonatomic) FlutterEventSink eventSink;
@property (strong, nonatomic) SplashPage *splashAd;
@property (strong, nonatomic) InterstitialPage *iad;
@property (retain, nonatomic) UIView *bottomView;
@property (nonatomic, assign) BOOL fullScreenAd;
@property (weak,nonatomic) NSString *posId;

@end

@implementation FlutterQqAdsPlugin
// 广告位id
NSString *const kPosId=@"posId";

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* methodChannel = [FlutterMethodChannel
                                           methodChannelWithName:@"flutter_qq_ads"
                                           binaryMessenger:[registrar messenger]];
    FlutterEventChannel* eventChannel=[FlutterEventChannel eventChannelWithName:@"flutter_qq_ads_event" binaryMessenger:[registrar messenger]];
    FlutterQqAdsPlugin* instance = [[FlutterQqAdsPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:methodChannel];
    [eventChannel setStreamHandler:instance];
    
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    }else if ([@"requestIDFA" isEqualToString:call.method]) {
        [self requestIDFA:call result:result];
    }else if ([@"initAd" isEqualToString:call.method]) {
        [self initAd:call result:result];
    }else if([@"showSplashAd" isEqualToString:call.method]) {
        [self showSplashAd:call result:result];
    }else if ([@"showInterstitialAd" isEqualToString:call.method]){
        [self showInterstitialAd:call result:result];
    }else {
        result(FlutterMethodNotImplemented);
    }
}
// 请求 IDFA
- (void) requestIDFA:(FlutterMethodCall*) call result:(FlutterResult) result{
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            BOOL requestResult=status == ATTrackingManagerAuthorizationStatusAuthorized;
            NSLog(@"requestIDFA:%@",requestResult?@"YES":@"NO");
            result(@(requestResult));
        }];
    } else {
        result(@(YES));
    }
}

// 初始化广告
- (void) initAd:(FlutterMethodCall*) call result:(FlutterResult) result{
    NSString* appId=call.arguments[@"appId"];
    BOOL initSuccess=[GDTSDKConfig registerAppId:appId];
    result(@(initSuccess));
}

// 显示开屏广告
- (void) showSplashAd:(FlutterMethodCall*) call result:(FlutterResult) result{
    self.posId=call.arguments[kPosId];
    self.splashAd=[[SplashPage alloc] init];
    [self.splashAd showAd:self.posId methodCall:call eventSink:self.eventSink];
    result(@(YES));
}

// 显示插屏广告
- (void) showInterstitialAd:(FlutterMethodCall*) call result:(FlutterResult) result{
    self.posId=call.arguments[kPosId];
    self.iad=[[InterstitialPage alloc] init];
    [self.iad showAd:self.posId methodCall:call eventSink:self.eventSink];
    result(@(YES));
}


#pragma mark - FlutterStreamHandler
- (FlutterError * _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    self.eventSink=nil;
    return nil;
}

- (FlutterError * _Nullable)onListenWithArguments:(id _Nullable)arguments eventSink:(nonnull FlutterEventSink)events {
    self.eventSink=events;
    return nil;
}

// 添加事件
-(void) addEvent:(NSObject *) event{
    if(self.eventSink!=nil){
        self.eventSink(event);
    }
}

@end
