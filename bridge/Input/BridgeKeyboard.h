#pragma once

#import "../BridgeTypes.h"

id ButtonForKeyCode(unsigned short keyCode);
bool MacKeyCodeForHIDUsage(unsigned short hidUsage, unsigned short *macKeyCode);
bool IsFunctionKey(unsigned short keyCode);
bool IsGameplayRearmKey(unsigned short keyCode);
void AddActiveKeyCode(unsigned short keyCode);
void RemoveActiveKeyCode(unsigned short keyCode);
bool SendKeyCode(unsigned short keyCode, BOOL pressed);
void SuppressKeyCodeUntilRelease(unsigned short keyCode, bool fromMenu);
void ReleaseKeyCode(unsigned short keyCode, const char *reason);
void BridgeSuppressActiveGameKeysForUI(const char *reason);
void BridgeInvalidateSprintGameLatch(const char *reason);
void BridgeClearSprintToggleState(const char *reason);
void BridgeApplySprintToggleIfNeeded(const char *reason);
void PollPhysicalKeys(void);
void StartKeyPollerIfNeeded(void);
void PressKeyCode(unsigned short keyCode);
void ReleaseAllKeys(void);
bool PressSetContainsSuppressedKey(id presses);
void EmitPressSet(id controller, id presses, BOOL pressed);
void ReplacementPressesBegan(id self, SEL _cmd, id presses, id event);
void ReplacementPressesEnded(id self, SEL _cmd, id presses, id event);
void ReplacementPressesCancelled(id self, SEL _cmd, id presses, id event);
void ReplacementSetKeyChangedHandler(id self, SEL _cmd, id block);
