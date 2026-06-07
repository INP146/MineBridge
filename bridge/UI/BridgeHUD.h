#pragma once

#import "../BridgeTypes.h"

void BridgeHUDRefresh(void);
void BridgeHUDEditorBegin(bool returnToMenuOnEnd, bool restoreMouseLookOnEnd);
void BridgeHUDEditorEnd(const char *reason);
bool BridgeHUDEditorHandleKeyDown(unsigned short keyCode);
void BridgeHUDEditorHandleKeyUp(unsigned short keyCode);
