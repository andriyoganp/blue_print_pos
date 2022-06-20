#ifndef FLUTTER_PLUGIN_BLUE_PRINT_POS_PLUGIN_H_
#define FLUTTER_PLUGIN_BLUE_PRINT_POS_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace blue_print_pos {

class BluePrintPosPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  BluePrintPosPlugin();

  virtual ~BluePrintPosPlugin();

  // Disallow copy and assign.
  BluePrintPosPlugin(const BluePrintPosPlugin&) = delete;
  BluePrintPosPlugin& operator=(const BluePrintPosPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace blue_print_pos

#endif  // FLUTTER_PLUGIN_BLUE_PRINT_POS_PLUGIN_H_
