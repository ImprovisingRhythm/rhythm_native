#import "DisplayModeDelegatePlugin.h"

@implementation DisplayModeDelegatePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel =
      [FlutterMethodChannel methodChannelWithName:@"rhythm_native/display_mode_delegate"
                                  binaryMessenger:[registrar messenger]];
  DisplayModeDelegatePlugin* instance = [[DisplayModeDelegatePlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  result(FlutterMethodNotImplemented);
}

@end