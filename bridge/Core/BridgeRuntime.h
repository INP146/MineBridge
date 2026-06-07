#pragma once

#import "../BridgeTypes.h"

extern const char *kControllerClassName;
extern const char *kTargetGameVersion;
extern const char *kPluginVersion;
extern const char *kBridgeVersion;
extern const size_t kAppPlatformPointerLockedOffset;
extern const unsigned short kBridgeMenuKeyM;

void BridgeVLog(const char *format, va_list args);
void BridgeLog(const char *format, ...);
void BridgeTraceLog(const char *format, ...);
uint64_t NowUsec(void);
bool RespondsTo(id obj, SEL sel);
id ObjectValue(id obj, const char *selectorName);
void *PointerValue(id obj, const char *selectorName);
Ivar FindIvarInClassHierarchy(Class cls, const char *ivarName);
id ObjectIvarValue(id obj, const char *ivarName);
unsigned long ULongValue(id obj, const char *selectorName);
bool IsTargetController(id self);
IMP OriginalFor(id self, SEL sel);
bool HookAlreadyInstalled(Class cls, SEL sel);
