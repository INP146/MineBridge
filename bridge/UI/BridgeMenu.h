#pragma once

#import "../BridgeTypes.h"

id BridgeColorWithWhiteAlpha(double white, double alpha);
id BridgeColorWithRedGreenBlueAlpha(double red, double green, double blue, double alpha);
id BridgeString(const char *text);
id BridgeFont(double size, bool bold);
id BridgeViewWithFrame(BridgeCGRect frame);
id BridgeLabelWithFrame(BridgeCGRect frame, const char *text, double fontSize, bool bold, id textColor, long alignment, long lines);
void ShowBridgeMenu(const char *reason);
void HideBridgeMenu(const char *reason);
void ShowBridgeLoadedToast(void);
bool IsBridgeMenuChordKey(unsigned short keyCode);
bool BridgeMenuHandleCapturedKey(unsigned short keyCode);
void ToggleBridgeMenuFromHotkey(void);
