#pragma once

#import "../BridgeTypes.h"

void EmitScrollInput(float xValue, float yValue, int64_t lineX, int64_t lineY, int64_t pointX, int64_t pointY);
CGEventRefOpaque ScrollEventTapCallback(CGEventTapProxyOpaque proxy, uint32_t type, CGEventRefOpaque event, void *refcon);
void StartScrollEventTapIfNeeded(void);
void PollSyntheticMouseInput(void);
void StartSyntheticMousePollerIfNeeded(void);
const char *MouseButtonRole(id buttonInput);
int MouseButtonIndex(id buttonInput);
void EmitMouseButtonInput(int buttonIndex, bool pressed, const char *reason);
void BridgeSuppressActiveMouseButtonsForUI(const char *reason);
void ReplacementSetMouseMovedHandler(id self, SEL _cmd, id block);
void ReplacementSetPressedChangedHandler(id self, SEL _cmd, id block);
void ReplacementSetValueChangedHandler(id self, SEL _cmd, id block);
void ReplacementSetTouchedChangedHandler(id self, SEL _cmd, id block);
float ReplacementButtonValue(id self, SEL _cmd);
BOOL ReplacementButtonIsPressed(id self, SEL _cmd);
BOOL ReplacementButtonIsTouched(id self, SEL _cmd);
const char *ScrollAxisRole(id axisInput);
void ReplacementSetDirectionPadValueChangedHandler(id self, SEL _cmd, id block);
void ReplacementSetAxisValueChangedHandler(id self, SEL _cmd, id block);
float ReplacementAxisValue(id self, SEL _cmd);
void HookMouseButtonClass(Class cls);
void HookDirectionPadClass(Class cls);
void HookAxisClass(Class cls);
void InstallMouseButtonHooksForCurrentButtons(void);
void InstallScrollHooksForCurrentScroll(void);
