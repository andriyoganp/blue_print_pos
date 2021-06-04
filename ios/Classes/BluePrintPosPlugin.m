#import "BluePrintPosPlugin.h"
#if __has_include(<blue_print_pos/blue_print_pos-Swift.h>)
#import <blue_print_pos/blue_print_pos-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "blue_print_pos-Swift.h"
#endif

@implementation BluePrintPosPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftBluePrintPosPlugin registerWithRegistrar:registrar];
}
@end
