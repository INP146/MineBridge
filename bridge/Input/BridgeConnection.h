#pragma once

#import "../BridgeTypes.h"

id KeyboardHandlerForController(id controller);
void EnsureKeyboardConnected(id controller);
void UpdateMouseButtonReferences(void);
void UpdateMouseScrollReferences(void);
id FirstAvailableMouse(Class mouseClass);
void StartMouseRetryTimerIfNeeded(id controller);
void EnsureMouseConnected(id controller);
id TargetControllerInControllerTree(id controller, unsigned int depth);
id DiscoverTargetController(void);
void TryConnectDiscoveredController(const char *reason);
void StartControllerDiscoveryTimerIfNeeded(void);
