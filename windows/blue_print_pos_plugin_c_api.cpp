#include "include/blue_print_pos/blue_print_pos_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "blue_print_pos_plugin.h"

void BluePrintPosPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  blue_print_pos::BluePrintPosPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
