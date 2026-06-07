#import "../BridgeInternal.h"

const char *kLogPath = "/Users/user/Library/Containers/io.playcover.PlayCover/minebridge.log";
const char *kControllerClassName = "minecraftpeViewControllerImpl";
const char *kTargetGameVersion = "26.21";
const char *kPluginVersion = "0.1";
const char *kBridgeVersion = "26.21.0.1";
const size_t kAppPlatformPointerLockedOffset = 0x412;
const unsigned short kBridgeMenuKeyM = 0x10;
HookEntry gHooks[128];
int gHookCount = 0;
bool gTriedKeyboardConnect = false;
bool gMouseConnected = false;
unsigned int gMouseConnectAttempts = 0;
id gKeyboardInput = nil;
id gMouseInput = nil;
id gLastController = nil;
id gMouseButtons[3];
id gScrollInput = nil;
id gScrollXAxis = nil;
id gScrollYAxis = nil;
void (^gKeyChangedHandler)(id keyboardInput, id key, unsigned short keyCode, BOOL pressed) = nil;
void (^gMouseMovedHandler)(id mouseInput, float deltaX, float deltaY) = nil;
void (^gMousePressedHandlers[3])(id buttonInput, float value, BOOL pressed) = { nil, nil, nil };
void (^gMouseValueHandlers[3])(id buttonInput, float value, BOOL pressed) = { nil, nil, nil };
void (^gMouseTouchedHandlers[3])(id buttonInput, float value, BOOL pressed, BOOL touched) = { nil, nil, nil };
void (^gScrollChangedHandler)(id scrollInput, float xValue, float yValue) = nil;
void (^gScrollXAxisChangedHandler)(id axisInput, float value) = nil;
void (^gScrollYAxisChangedHandler)(id axisInput, float value) = nil;
bool gMouseButtonStates[3];
bool gMouseButtonSuppressedByBridgeUI[3];
float gScrollXValue = 0.0f;
float gScrollYValue = 0.0f;
bool gPressedKeys[UINT16_MAX + 1];
bool gSuppressedKeys[UINT16_MAX + 1];
bool gMenuSuppressedKeys[UINT16_MAX + 1];
bool gMissingMacKeyLogged[UINT16_MAX + 1];
unsigned short gActiveKeyCodes[256];
unsigned int gActiveKeyCount = 0;
dispatch_source_t gPollTimer = nil;
dispatch_source_t gMouseRetryTimer = nil;
dispatch_source_t gSyntheticMouseTimer = nil;
dispatch_source_t gControllerDiscoveryTimer = nil;
CGEventSourceKeyStateFn gCGEventSourceKeyState = NULL;
CGGetLastMouseDeltaFn gCGGetLastMouseDelta = NULL;
CGEventSourceCounterForEventTypeFn gCGEventSourceCounterForEventType = NULL;
CGEventSourceButtonStateFn gCGEventSourceButtonState = NULL;
CGEventTapCreateFn gCGEventTapCreate = NULL;
CGEventGetIntegerValueFieldFn gCGEventGetIntegerValueField = NULL;
CGEventTapEnableFn gCGEventTapEnable = NULL;
CGAssociateMouseAndMouseCursorPositionFn gCGAssociateMouseAndMouseCursorPosition = NULL;
CGDisplayHideCursorFn gCGDisplayHideCursor = NULL;
CGDisplayShowCursorFn gCGDisplayShowCursor = NULL;
CGWarpMouseCursorPositionFn gCGWarpMouseCursorPosition = NULL;
CGMainDisplayIDFn gCGMainDisplayID = NULL;
CGDisplayBoundsFn gCGDisplayBounds = NULL;
bool gTriedResolveKeyState = false;
bool gTriedResolveMouseFunctions = false;
bool gTriedResolveScrollFunctions = false;
bool gTriedResolvePointerCaptureFunctions = false;
bool gKeyStateUnavailableLogged = false;
bool gMouseFunctionsUnavailableLogged = false;
bool gScrollFunctionsUnavailableLogged = false;
bool gPointerCaptureFunctionsUnavailableLogged = false;
bool gPointerLockWanted = false;
bool gPointerLockInhibited = true;
unsigned short gPointerLockReleaseKeyCode = 0;
bool gPointerLockRearmAllowedByToggle = false;
bool gPointerLockRearmAllowedByMouseClick = false;
bool gPointerCaptureActive = false;
bool gPointerCursorDetached = false;
bool gPointerCursorHidden = false;
bool gTextInputActive = false;
bool gClearingPointerLock = false;
bool gPointerLockReturnLogged = false;
bool gDropNextMouseDeltaAfterPointerLock = false;
bool gDropInitialSyntheticMouseDelta = true;
bool gPointerRegionNilLogged = false;
bool gPointerRegionLogged = false;
bool gTouchSuppressionLogged = false;
bool gPointerRearmBlockedLogged = false;
bool gNativePrefersPointerLockedLogged = false;
BOOL gNativePrefersPointerLockedLastValue = NO;
bool gMouseLookAllowed = false;
bool gMouseLookAllowedLogged = false;
bool gNativeMouseMovementLogged = false;
bool gSyntheticMouseMovementSuppressedLogged = false;
bool gMouseCountersInitialized = false;
uint32_t gMouseMoveCounters[4];
uint64_t gLastNativeMouseMoveUsec = 0;
CFMachPortRef gScrollEventTap = NULL;
CFRunLoopSourceRef gScrollEventTapSource = NULL;
unsigned int gControllerDiscoveryAttempts = 0;
id gBridgeMenuOverlayView = nil;
id gBridgeHUDToggleButton = nil;
id gBridgeHUDSprintStatusButton = nil;
id gBridgeHUDSettingsButton = nil;
id gBridgeSprintModeButton = nil;
id gBridgeSprintKeyButton = nil;
bool gBridgeMenuVisible = false;
bool gBridgeMenuRestoreMouseLookOnHide = false;
bool gBridgeMenuCapturingSprintKey = false;
bool gBridgeHUDEditorActive = false;
BridgeHUDElement gBridgeHUDSelectedElement = BridgeHUDElementNone;
bool gBridgeHUDEnabled = false;
bool gBridgeHUDSprintStatusEnabled = true;
double gBridgeHUDSprintX = 1620.0;
double gBridgeHUDSprintY = 160.0;
double gBridgeHUDSprintSize = 90.0;
double gBridgeHUDSprintAlpha = 0.50;
BridgeSprintMode gBridgeSprintMode = BridgeSprintModeNative;
unsigned short gBridgeSprintKeyCode = 0xE0;
bool gBridgeSprintToggleDesired = false;
bool gBridgeSprintToggleHeldInGame = false;
bool gSuppressOriginalPressesBegan = false;
void BridgeVLog(const char *format, va_list args) {
    FILE *file = fopen(kLogPath, "a");
    if (file == NULL) {
        return;
    }

    struct timeval tv;
    gettimeofday(&tv, NULL);
    fprintf(file, "[%ld.%03d] ", tv.tv_sec, (int)(tv.tv_usec / 1000));

    vfprintf(file, format, args);

    fprintf(file, "\n");
    fclose(file);
}

void BridgeLog(const char *format, ...) {
    va_list args;
    va_start(args, format);
    BridgeVLog(format, args);
    va_end(args);
}

void BridgeTraceLog(const char *format, ...) {
    if (!MC_KEYBOARD_BRIDGE_VERBOSE) {
        return;
    }

    va_list args;
    va_start(args, format);
    BridgeVLog(format, args);
    va_end(args);
}

uint64_t NowUsec(void) {
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return (uint64_t)tv.tv_sec * 1000000ULL + (uint64_t)tv.tv_usec;
}

bool RespondsTo(id obj, SEL sel) {
    return obj != nil && ((BOOL (*)(id, SEL, SEL))objc_msgSend)(obj, @selector(respondsToSelector:), sel);
}

id ObjectValue(id obj, const char *selectorName) {
    SEL sel = sel_registerName(selectorName);
    if (!RespondsTo(obj, sel)) {
        return nil;
    }
    return ((id (*)(id, SEL))objc_msgSend)(obj, sel);
}

void *PointerValue(id obj, const char *selectorName) {
    SEL sel = sel_registerName(selectorName);
    if (!RespondsTo(obj, sel)) {
        return NULL;
    }
    return ((void *(*)(id, SEL))objc_msgSend)(obj, sel);
}

Ivar FindIvarInClassHierarchy(Class cls, const char *ivarName) {
    while (cls != Nil) {
        Ivar ivar = class_getInstanceVariable(cls, ivarName);
        if (ivar != NULL) {
            return ivar;
        }
        cls = class_getSuperclass(cls);
    }
    return NULL;
}

id ObjectIvarValue(id obj, const char *ivarName) {
    if (obj == nil) {
        return nil;
    }

    Ivar ivar = FindIvarInClassHierarchy(object_getClass(obj), ivarName);
    if (ivar == NULL) {
        return nil;
    }

    void **slot = (void **)((char *)(__bridge void *)obj + ivar_getOffset(ivar));
    return slot == NULL || *slot == NULL ? nil : (__bridge id)(*slot);
}

unsigned long ULongValue(id obj, const char *selectorName) {
    SEL sel = sel_registerName(selectorName);
    if (!RespondsTo(obj, sel)) {
        return 0;
    }
    return ((unsigned long (*)(id, SEL))objc_msgSend)(obj, sel);
}

bool IsTargetController(id self) {
    const char *className = self == nil ? NULL : class_getName(object_getClass(self));
    return className != NULL && strcmp(className, kControllerClassName) == 0;
}

IMP OriginalFor(id self, SEL sel) {
    Class cls = object_getClass(self);
    while (cls != Nil) {
        for (int i = 0; i < gHookCount; i++) {
            if (gHooks[i].cls == cls && gHooks[i].sel == sel) {
                return gHooks[i].original;
            }
        }
        cls = class_getSuperclass(cls);
    }
    return NULL;
}

bool HookAlreadyInstalled(Class cls, SEL sel) {
    for (int i = 0; i < gHookCount; i++) {
        if (gHooks[i].cls == cls && gHooks[i].sel == sel) {
            return true;
        }
    }
    return false;
}
