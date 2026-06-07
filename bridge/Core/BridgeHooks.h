#pragma once

#import "../BridgeTypes.h"

bool HookInstanceMethod(Class cls, SEL sel, IMP replacement);
bool AddOrHookInstanceMethod(Class cls, SEL sel, IMP replacement, const char *types);
bool HookMethodImplementation(Class cls, SEL sel, IMP replacement);
bool InstallMarker(Class cls);
