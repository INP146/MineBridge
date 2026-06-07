#pragma once

#import "../BridgeTypes.h"

bool ResolveKeyStateFunction(void);
bool ResolveMouseFunctions(void);
bool ResolveScrollFunctions(void);
bool ResolvePointerCaptureFunctions(void);
id RootViewControllerForController(id controller);
id SharedApplication(void);
id KeyWindow(void);
id KeyWindowRootViewController(void);
id SharedNSApplication(void);
const char *ClassName(id obj);
bool KeyWindowCenterInQuartzCoordinates(BridgeCGPoint *point, const char **source);
void SetPointerCaptureActive(bool active, const char *reason);
bool SharesTargetWindow(id controller);
id PointerLockSourceController(id controller);
void *PlatformPointerForController(id controller);
bool PlatformPointerLockedForController(id controller);
bool CurrentPlatformPointerLocked(void);
bool CanClearPointerLockInhibit(const char *reason);
void SetPlatformPointerLocked(bool locked, const char *reason);
bool HasPlatformPointerLockPreference(id controller);
void UpdateMouseLookAllowed(bool allowed, const char *reason);
bool MouseLookGateAllowsPointerLock(void);
bool RefreshMouseLookGateFromNative(id controller, const char *reason);
bool ShouldPreferPointerLocked(id controller);
void ReconcilePointerCapture(id controller, const char *reason);
void SetNeedsPointerLockUpdate(id controller);
void SetNeedsPointerLockUpdateCandidate(id controller, const char *label, __unsafe_unretained id *seen, unsigned int *seenCount);
void SetNeedsPointerLockUpdateForVisibleChain(void);
bool RequestPointerLockIfNeeded(void);
bool HasRecentNativeMouseMovement(void);
void ClearPointerLockIfNeeded(void);
