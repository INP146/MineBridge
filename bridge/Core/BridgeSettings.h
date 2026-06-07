#pragma once

#import "../BridgeTypes.h"

typedef enum {
    BridgeSprintModeNative = 0,
    BridgeSprintModeToggle = 1,
} BridgeSprintMode;

void BridgeSettingsLoad(void);
void BridgeSettingsSaveHUDEnabled(bool enabled);
void BridgeSettingsSaveHUDSprintStatusEnabled(bool enabled);
void BridgeSettingsSaveHUDKeystrokesEnabled(bool enabled);
void BridgeSettingsSaveHUDSprintLayout(double x, double y, double size, double alpha);
void BridgeSettingsSaveHUDKeystrokesLayout(double x, double y, double size, double alpha);
void BridgeSettingsResetHUDSprintLayout(void);
void BridgeSettingsResetHUDKeystrokesLayout(void);
void BridgeSettingsSaveSprintMode(BridgeSprintMode mode);
void BridgeSettingsSaveSprintKeyCode(unsigned short keyCode);
const char *BridgeKeyName(unsigned short keyCode);
