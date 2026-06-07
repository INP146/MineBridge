#import "../BridgeInternal.h"

bool ResolveKeyStateFunction(void) {
    if (gTriedResolveKeyState) {
        return gCGEventSourceKeyState != NULL;
    }

    gTriedResolveKeyState = true;
    void *handle = dlopen("/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics", RTLD_LAZY);
    gCGEventSourceKeyState = (CGEventSourceKeyStateFn)dlsym(handle == NULL ? RTLD_DEFAULT : handle, "CGEventSourceKeyState");
    BridgeLog("resolve CGEventSourceKeyState=%p", (void *)gCGEventSourceKeyState);
    return gCGEventSourceKeyState != NULL;
}

bool ResolveMouseFunctions(void) {
    if (gTriedResolveMouseFunctions) {
        return gCGGetLastMouseDelta != NULL && gCGEventSourceCounterForEventType != NULL && gCGEventSourceButtonState != NULL;
    }

    gTriedResolveMouseFunctions = true;
    void *handle = dlopen("/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics", RTLD_LAZY);
    void *symbolHandle = handle == NULL ? RTLD_DEFAULT : handle;
    gCGGetLastMouseDelta = (CGGetLastMouseDeltaFn)dlsym(symbolHandle, "CGGetLastMouseDelta");
    gCGEventSourceCounterForEventType = (CGEventSourceCounterForEventTypeFn)dlsym(symbolHandle, "CGEventSourceCounterForEventType");
    gCGEventSourceButtonState = (CGEventSourceButtonStateFn)dlsym(symbolHandle, "CGEventSourceButtonState");
    BridgeLog("resolve mouse functions delta=%p counter=%p button=%p",
              (void *)gCGGetLastMouseDelta,
              (void *)gCGEventSourceCounterForEventType,
              (void *)gCGEventSourceButtonState);
    return gCGGetLastMouseDelta != NULL && gCGEventSourceCounterForEventType != NULL && gCGEventSourceButtonState != NULL;
}

bool ResolveScrollFunctions(void) {
    if (gTriedResolveScrollFunctions) {
        return gCGEventTapCreate != NULL && gCGEventGetIntegerValueField != NULL && gCGEventTapEnable != NULL;
    }

    gTriedResolveScrollFunctions = true;
    void *handle = dlopen("/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics", RTLD_LAZY);
    void *symbolHandle = handle == NULL ? RTLD_DEFAULT : handle;
    gCGEventTapCreate = (CGEventTapCreateFn)dlsym(symbolHandle, "CGEventTapCreate");
    gCGEventGetIntegerValueField = (CGEventGetIntegerValueFieldFn)dlsym(symbolHandle, "CGEventGetIntegerValueField");
    gCGEventTapEnable = (CGEventTapEnableFn)dlsym(symbolHandle, "CGEventTapEnable");
    BridgeLog("resolve scroll functions tapCreate=%p getField=%p tapEnable=%p",
              (void *)gCGEventTapCreate,
              (void *)gCGEventGetIntegerValueField,
              (void *)gCGEventTapEnable);
    return gCGEventTapCreate != NULL && gCGEventGetIntegerValueField != NULL && gCGEventTapEnable != NULL;
}

bool ResolvePointerCaptureFunctions(void) {
    if (gTriedResolvePointerCaptureFunctions) {
        return gCGAssociateMouseAndMouseCursorPosition != NULL &&
               gCGDisplayHideCursor != NULL &&
               gCGDisplayShowCursor != NULL;
    }

    gTriedResolvePointerCaptureFunctions = true;
    void *handle = dlopen("/System/Library/Frameworks/CoreGraphics.framework/CoreGraphics", RTLD_LAZY);
    void *symbolHandle = handle == NULL ? RTLD_DEFAULT : handle;
    gCGAssociateMouseAndMouseCursorPosition = (CGAssociateMouseAndMouseCursorPositionFn)dlsym(symbolHandle, "CGAssociateMouseAndMouseCursorPosition");
    gCGDisplayHideCursor = (CGDisplayHideCursorFn)dlsym(symbolHandle, "CGDisplayHideCursor");
    gCGDisplayShowCursor = (CGDisplayShowCursorFn)dlsym(symbolHandle, "CGDisplayShowCursor");
    gCGWarpMouseCursorPosition = (CGWarpMouseCursorPositionFn)dlsym(symbolHandle, "CGWarpMouseCursorPosition");
    gCGMainDisplayID = (CGMainDisplayIDFn)dlsym(symbolHandle, "CGMainDisplayID");
    gCGDisplayBounds = (CGDisplayBoundsFn)dlsym(symbolHandle, "CGDisplayBounds");
    BridgeLog("resolve pointer capture functions associate=%p hide=%p show=%p warp=%p mainDisplay=%p bounds=%p",
              (void *)gCGAssociateMouseAndMouseCursorPosition,
              (void *)gCGDisplayHideCursor,
              (void *)gCGDisplayShowCursor,
              (void *)gCGWarpMouseCursorPosition,
              (void *)gCGMainDisplayID,
              (void *)gCGDisplayBounds);
    return gCGAssociateMouseAndMouseCursorPosition != NULL &&
           gCGDisplayHideCursor != NULL &&
           gCGDisplayShowCursor != NULL;
}

id RootViewControllerForController(id controller) {
    id view = ObjectValue(controller, "view");
    id window = ObjectValue(view, "window");
    return ObjectValue(window, "rootViewController");
}

id SharedApplication(void) {
    Class applicationClass = objc_getClass("UIApplication");
    SEL sharedApplicationSel = sel_registerName("sharedApplication");
    if (applicationClass == Nil || !RespondsTo((id)applicationClass, sharedApplicationSel)) {
        return nil;
    }
    return ((id (*)(id, SEL))objc_msgSend)((id)applicationClass, sharedApplicationSel);
}

id KeyWindow(void) {
    return ObjectValue(SharedApplication(), "keyWindow");
}

id KeyWindowRootViewController(void) {
    return ObjectValue(KeyWindow(), "rootViewController");
}

id SharedNSApplication(void) {
    Class applicationClass = objc_getClass("NSApplication");
    SEL sharedApplicationSel = sel_registerName("sharedApplication");
    if (applicationClass == Nil || !RespondsTo((id)applicationClass, sharedApplicationSel)) {
        return nil;
    }
    return ((id (*)(id, SEL))objc_msgSend)((id)applicationClass, sharedApplicationSel);
}

const char *ClassName(id obj) {
    return obj == nil ? "<nil>" : class_getName(object_getClass(obj));
}

bool CenterPointForCocoaWindowFrame(BridgeCGRect windowFrame, BridgeCGPoint *point) {
    if (point == NULL || gCGMainDisplayID == NULL || gCGDisplayBounds == NULL) {
        return false;
    }
    if (windowFrame.size.width <= 0.0 || windowFrame.size.height <= 0.0) {
        return false;
    }

    uint32_t display = gCGMainDisplayID();
    BridgeCGRect displayBounds = gCGDisplayBounds(display);
    double cocoaX = windowFrame.origin.x + windowFrame.size.width * 0.5;
    double cocoaY = windowFrame.origin.y + windowFrame.size.height * 0.5;
    point->x = cocoaX;
    point->y = displayBounds.origin.y + displayBounds.size.height - cocoaY;
    return true;
}

bool WindowFrame(id nsWindow, BridgeCGRect *frame) {
    if (frame == NULL || nsWindow == nil || !RespondsTo(nsWindow, sel_registerName("frame"))) {
        return false;
    }
    BridgeCGRect windowFrame = ((BridgeCGRect (*)(id, SEL))objc_msgSend)(nsWindow, sel_registerName("frame"));
    if (windowFrame.size.width <= 0.0 || windowFrame.size.height <= 0.0) {
        return false;
    }
    *frame = windowFrame;
    return true;
}

bool LargestApplicationWindowFrame(BridgeCGRect *frame) {
    if (frame == NULL) {
        return false;
    }

    id nsApplication = SharedNSApplication();
    id windows = ObjectValue(nsApplication, "windows");
    unsigned long count = ULongValue(windows, "count");
    bool found = false;
    double bestArea = 0.0;
    BridgeCGRect bestFrame = { { 0.0, 0.0 }, { 0.0, 0.0 } };

    for (unsigned long i = 0; i < count; i++) {
        id window = ((id (*)(id, SEL, unsigned long))objc_msgSend)(windows, @selector(objectAtIndex:), i);
        BridgeCGRect candidate = { { 0.0, 0.0 }, { 0.0, 0.0 } };
        if (!WindowFrame(window, &candidate)) {
            continue;
        }

        double area = candidate.size.width * candidate.size.height;
        if (!found || area > bestArea) {
            found = true;
            bestArea = area;
            bestFrame = candidate;
        }
    }

    if (!found) {
        return false;
    }

    *frame = bestFrame;
    return true;
}

bool KeyWindowCenterInQuartzCoordinates(BridgeCGPoint *point, const char **source) {
    if (source != NULL) {
        *source = "none";
    }

    id nsApplication = SharedNSApplication();
    BridgeCGRect windowFrame = { { 0.0, 0.0 }, { 0.0, 0.0 } };
    if (WindowFrame(ObjectValue(nsApplication, "keyWindow"), &windowFrame) &&
        CenterPointForCocoaWindowFrame(windowFrame, point)) {
        if (source != NULL) {
            *source = "ns-key";
        }
        return true;
    }
    if (WindowFrame(ObjectValue(nsApplication, "mainWindow"), &windowFrame) &&
        CenterPointForCocoaWindowFrame(windowFrame, point)) {
        if (source != NULL) {
            *source = "ns-main";
        }
        return true;
    }
    if (LargestApplicationWindowFrame(&windowFrame) &&
        CenterPointForCocoaWindowFrame(windowFrame, point)) {
        if (source != NULL) {
            *source = "ns-windows";
        }
        return true;
    }

    return false;
}

void SetPointerCaptureActive(bool active, const char *reason) {
    if (active == gPointerCaptureActive) {
        return;
    }

    if (!ResolvePointerCaptureFunctions()) {
        if (!gPointerCaptureFunctionsUnavailableLogged) {
            BridgeLog("pointer capture unavailable reason=%s",
                      reason == NULL ? "<nil>" : reason);
            gPointerCaptureFunctionsUnavailableLogged = true;
        }
        return;
    }

    uint32_t display = gCGMainDisplayID == NULL ? 0 : gCGMainDisplayID();
    if (active) {
        BridgeCGPoint center = { 0.0, 0.0 };
        const char *centerSource = "none";
        bool hasCenter = KeyWindowCenterInQuartzCoordinates(&center, &centerSource);
        int32_t warpError = -1;
        if (hasCenter && gCGWarpMouseCursorPosition != NULL) {
            warpError = gCGWarpMouseCursorPosition(center);
        }

        int32_t associateError = gCGAssociateMouseAndMouseCursorPosition(0);
        if (associateError == 0) {
            gPointerCursorDetached = true;
        }

        int32_t hideError = associateError == 0 ? gCGDisplayHideCursor(display) : -1;
        if (hideError == 0) {
            gPointerCursorHidden = true;
        }

        gPointerCaptureActive = associateError == 0;
        BridgeLog("pointer capture enable reason=%s active=%d display=%u hasCenter=%d centerSource=%s centerX=%.1f centerY=%.1f warpError=%d associateError=%d hideError=%d",
                  reason == NULL ? "<nil>" : reason,
                  gPointerCaptureActive ? 1 : 0,
                  display,
                  hasCenter ? 1 : 0,
                  centerSource == NULL ? "<nil>" : centerSource,
                  center.x,
                  center.y,
                  warpError,
                  associateError,
                  hideError);
        BridgeApplySprintToggleIfNeeded(reason);
        return;
    }

    int32_t associateError = 0;
    int32_t showError = 0;
    if (gPointerCursorDetached) {
        associateError = gCGAssociateMouseAndMouseCursorPosition(1);
        gPointerCursorDetached = false;
    }
    if (gPointerCursorHidden) {
        showError = gCGDisplayShowCursor(display);
        gPointerCursorHidden = false;
    }
    gPointerCaptureActive = false;
    BridgeInvalidateSprintGameLatch(reason);
    BridgeLog("pointer capture disable reason=%s display=%u associateError=%d showError=%d",
              reason == NULL ? "<nil>" : reason,
              display,
              associateError,
              showError);
}

bool SharesTargetWindow(id controller) {
    if (controller == nil || gLastController == nil) {
        return false;
    }

    id targetWindow = ObjectValue(ObjectValue(gLastController, "view"), "window");
    id controllerWindow = ObjectValue(ObjectValue(controller, "view"), "window");
    id keyWindow = KeyWindow();
    return (targetWindow != nil && controllerWindow != nil && targetWindow == controllerWindow) ||
           (keyWindow != nil && controllerWindow != nil && keyWindow == controllerWindow);
}

id PointerLockSourceController(id controller) {
    if (IsTargetController(controller)) {
        return controller;
    }
    if (controller != nil && controller == KeyWindowRootViewController()) {
        return gLastController;
    }
    if (SharesTargetWindow(controller)) {
        return gLastController;
    }
    return nil;
}

void *PlatformPointerForController(id controller) {
    id source = PointerLockSourceController(controller);
    if (source == nil) {
        return NULL;
    }
    return PointerValue(source, "platform");
}

bool PlatformPointerLockedForController(id controller) {
    uint8_t *platform = (uint8_t *)PlatformPointerForController(controller);
    return platform != NULL && platform[kAppPlatformPointerLockedOffset] != 0;
}

bool CurrentPlatformPointerLocked(void) {
    return PlatformPointerLockedForController(gLastController);
}

bool CanClearPointerLockInhibit(const char *reason) {
    if (reason == NULL) {
        return false;
    }
    if (strcmp(reason, "text-input-ended") == 0) {
        return true;
    }
    if (strcmp(reason, "prefersPointerLocked") == 0) {
        return gPointerLockReleaseKeyCode == 0 ||
               gPointerLockRearmAllowedByToggle ||
               gPointerLockRearmAllowedByMouseClick;
    }
    return false;
}

void SetPlatformPointerLocked(bool locked, const char *reason) {
    uint8_t *platform = (uint8_t *)PlatformPointerForController(gLastController);
    if (platform == NULL) {
        gPointerLockWanted = locked;
        BridgeLog("platform pointer lock unavailable locked=%d reason=%s controller=%p",
                  locked ? 1 : 0,
                  reason == NULL ? "<nil>" : reason,
                  (__bridge void *)gLastController);
        return;
    }

    uint8_t before[9];
    uint8_t *byteWindow = platform + kAppPlatformPointerLockedOffset - 3;
    memcpy(before, byteWindow, sizeof(before));
    bool oldValue = platform[kAppPlatformPointerLockedOffset] != 0;
    platform[kAppPlatformPointerLockedOffset] = locked ? 1 : 0;
    gPointerLockWanted = locked;
    if (oldValue != locked) {
        uint8_t after[9];
        memcpy(after, byteWindow, sizeof(after));
        BridgeLog("platform pointer lock changed old=%d new=%d reason=%s platform=%p offset=0x%zx bytesBefore=%02x %02x %02x %02x %02x %02x %02x %02x %02x bytesAfter=%02x %02x %02x %02x %02x %02x %02x %02x %02x",
                  oldValue ? 1 : 0,
                  locked ? 1 : 0,
                  reason == NULL ? "<nil>" : reason,
                  platform,
                  kAppPlatformPointerLockedOffset,
                  (unsigned int)before[0],
                  (unsigned int)before[1],
                  (unsigned int)before[2],
                  (unsigned int)before[3],
                  (unsigned int)before[4],
                  (unsigned int)before[5],
                  (unsigned int)before[6],
                  (unsigned int)before[7],
                  (unsigned int)before[8],
                  (unsigned int)after[0],
                  (unsigned int)after[1],
                  (unsigned int)after[2],
                  (unsigned int)after[3],
                  (unsigned int)after[4],
                  (unsigned int)after[5],
                  (unsigned int)after[6],
                  (unsigned int)after[7],
                  (unsigned int)after[8]);
        if (locked) {
            gDropNextMouseDeltaAfterPointerLock = true;
            gPointerLockReturnLogged = false;
        } else {
            BridgeInvalidateSprintGameLatch(reason);
        }
    }
}

bool HasPlatformPointerLockPreference(id controller) {
    return !gTextInputActive &&
           !gBridgeMenuVisible &&
           !gBridgeHUDEditorActive &&
           PointerLockSourceController(controller) != nil &&
           PlatformPointerLockedForController(controller);
}

void UpdateMouseLookAllowed(bool allowed, const char *reason) {
    if (gMouseLookAllowed == allowed && gMouseLookAllowedLogged) {
        return;
    }

    gMouseLookAllowed = allowed;
    gMouseLookAllowedLogged = true;
    BridgeLog("mouse-look gate allowed=%d reason=%s platform=%d wanted=%d inhibited=%d textInput=%d",
              allowed ? 1 : 0,
              reason == NULL ? "<nil>" : reason,
              CurrentPlatformPointerLocked() ? 1 : 0,
              gPointerLockWanted ? 1 : 0,
              gPointerLockInhibited ? 1 : 0,
              gTextInputActive ? 1 : 0);
}

bool MouseLookGateAllowsPointerLock(void) {
    return gMouseLookAllowed && !gTextInputActive && !gBridgeMenuVisible && !gBridgeHUDEditorActive;
}

bool RefreshMouseLookGateFromNative(id controller, const char *reason) {
    id source = PointerLockSourceController(controller);
    if (source == nil) {
        UpdateMouseLookAllowed(false, reason);
        return false;
    }

    IMP original = OriginalFor(source, sel_registerName("prefersPointerLocked"));
    BOOL nativeResult = NO;
    if (original != NULL) {
        nativeResult = ((BOOL (*)(id, SEL))original)(source, sel_registerName("prefersPointerLocked"));
    }
    if (!gNativePrefersPointerLockedLogged || gNativePrefersPointerLockedLastValue != nativeResult) {
        BridgeLog("native prefersPointerLocked result=%d controller=%p class=%s platform=%d source=%p reason=%s",
                  nativeResult ? 1 : 0,
                  (__bridge void *)source,
                  ClassName(source),
                  PlatformPointerLockedForController(source) ? 1 : 0,
                  (__bridge void *)PointerLockSourceController(source),
                  reason == NULL ? "<nil>" : reason);
        gNativePrefersPointerLockedLogged = true;
        gNativePrefersPointerLockedLastValue = nativeResult;
    }
    if (!nativeResult &&
        PlatformPointerLockedForController(source) &&
        !gPointerLockWanted &&
        !gPointerCaptureActive &&
        !gClearingPointerLock) {
        BridgeLog("clearing stale platform lock after native prefersPointerLocked=0 reason=%s",
                  reason == NULL ? "<nil>" : reason);
        ClearPointerLockIfNeeded();
    }
    UpdateMouseLookAllowed(nativeResult && !gTextInputActive, reason);
    return MouseLookGateAllowsPointerLock();
}

bool ShouldPreferPointerLocked(id controller) {
    return gPointerLockWanted &&
           HasPlatformPointerLockPreference(controller) &&
           MouseLookGateAllowsPointerLock() &&
           !gPointerLockInhibited;
}

void ReconcilePointerCapture(id controller, const char *reason) {
    id candidate = controller != nil ? controller : gLastController;
    bool hasSource = PointerLockSourceController(candidate) != nil;
    bool platformLocked = hasSource && PlatformPointerLockedForController(candidate);
    bool shouldCapture = hasSource && platformLocked && !gTextInputActive && !gBridgeMenuVisible && !gBridgeHUDEditorActive && gMouseInput != nil;

    if (shouldCapture) {
        if (gPointerLockInhibited) {
            if (!CanClearPointerLockInhibit(reason)) {
                if (!gPointerRearmBlockedLogged) {
                    BridgeLog("pointer lock kept inhibited reason=%s controller=%p class=%s releaseKey=%u rearmToggle=%d rearmClick=%d platform=%d",
                              reason == NULL ? "<nil>" : reason,
                              (__bridge void *)candidate,
                              ClassName(candidate),
                              gPointerLockReleaseKeyCode,
                              gPointerLockRearmAllowedByToggle ? 1 : 0,
                              gPointerLockRearmAllowedByMouseClick ? 1 : 0,
                              platformLocked ? 1 : 0);
                    gPointerRearmBlockedLogged = true;
                }
                gPointerLockWanted = false;
                SetPointerCaptureActive(false, reason);
                return;
            }

            gPointerLockInhibited = false;
            gPointerLockRearmAllowedByToggle = false;
            gPointerLockRearmAllowedByMouseClick = false;
            gPointerRearmBlockedLogged = false;
            BridgeLog("pointer lock inhibit cleared by platform state reason=%s controller=%p class=%s",
                      reason == NULL ? "<nil>" : reason,
                      (__bridge void *)candidate,
                      ClassName(candidate));
        }
        gPointerLockWanted = true;
        SetPointerCaptureActive(true, reason);
        BridgeApplySprintToggleIfNeeded(reason);
        return;
    }

    if (hasSource && !platformLocked && !gClearingPointerLock && (gPointerCaptureActive || gPointerLockWanted)) {
        BridgeInvalidateSprintGameLatch(reason);
        if (!gPointerLockInhibited) {
            BridgeLog("pointer lock inhibited by native platform unlock reason=%s controller=%p class=%s",
                      reason == NULL ? "<nil>" : reason,
                      (__bridge void *)candidate,
                      ClassName(candidate));
        }
        gPointerLockInhibited = true;
        gPointerLockRearmAllowedByToggle = false;
        gPointerLockRearmAllowedByMouseClick = false;
        gPointerLockReleaseKeyCode = 0;
    }

    if (!platformLocked || gTextInputActive || gBridgeMenuVisible || gBridgeHUDEditorActive) {
        gPointerLockWanted = false;
    }
    SetPointerCaptureActive(false, reason);
}

void SetNeedsPointerLockUpdate(id controller) {
    SEL updateSel = sel_registerName("setNeedsUpdateOfPrefersPointerLocked");
    if (!RespondsTo(controller, updateSel)) {
        BridgeLog("pointer lock update unavailable controller=%p class=%s",
                  (__bridge void *)controller,
                  ClassName(controller));
        return;
    }

    ((void (*)(id, SEL))objc_msgSend)(controller, updateSel);
    BridgeTraceLog("pointer lock update requested wanted=%d platform=%d controller=%p class=%s source=%p keyRoot=%p",
                   gPointerLockWanted ? 1 : 0,
                   PlatformPointerLockedForController(controller) ? 1 : 0,
                   (__bridge void *)controller,
                   ClassName(controller),
                   (__bridge void *)PointerLockSourceController(controller),
                   (__bridge void *)KeyWindowRootViewController());
}

void SetNeedsPointerLockUpdateCandidate(id controller, const char *label, __unsafe_unretained id *seen, unsigned int *seenCount) {
    if (controller == nil) {
        BridgeTraceLog("pointer lock update candidate nil label=%s", label == NULL ? "<nil>" : label);
        return;
    }

    for (unsigned int i = 0; i < *seenCount; i++) {
        if (seen[i] == controller) {
            return;
        }
    }

    if (*seenCount < 16) {
        seen[*seenCount] = controller;
        (*seenCount)++;
    }

    BridgeTraceLog("pointer lock update candidate label=%s controller=%p class=%s source=%p",
                   label == NULL ? "<nil>" : label,
                   (__bridge void *)controller,
                   ClassName(controller),
                   (__bridge void *)PointerLockSourceController(controller));
    SetNeedsPointerLockUpdate(controller);
}

void SetNeedsPointerLockUpdateForVisibleChain(void) {
    if (gLastController == nil) {
        BridgeLog("pointer lock update skipped without controller");
        return;
    }

    __unsafe_unretained id seen[16] = { nil };
    unsigned int seenCount = 0;

    id keyRoot = KeyWindowRootViewController();
    id root = RootViewControllerForController(gLastController);
    SetNeedsPointerLockUpdateCandidate(keyRoot, "keyWindow.rootViewController", seen, &seenCount);
    SetNeedsPointerLockUpdateCandidate(root, "controller.view.window.rootViewController", seen, &seenCount);
    SetNeedsPointerLockUpdateCandidate(gLastController, "target", seen, &seenCount);

    id presented = ObjectValue(keyRoot != nil ? keyRoot : root, "presentedViewController");
    for (unsigned int depth = 0; depth < 6 && presented != nil; depth++) {
        SetNeedsPointerLockUpdateCandidate(presented, "presentedViewController", seen, &seenCount);
        presented = ObjectValue(presented, "presentedViewController");
    }
}

bool RequestPointerLockIfNeeded(void) {
    if (gTextInputActive || gBridgeMenuVisible || gBridgeHUDEditorActive) {
        gPointerLockInhibited = true;
        ReconcilePointerCapture(gLastController,
                                gBridgeHUDEditorActive ? "mouse-input-hud-editor" :
                                gBridgeMenuVisible ? "mouse-input-bridge-menu" : "mouse-input-text-input");
        return false;
    }

    if (!MouseLookGateAllowsPointerLock() &&
        !RefreshMouseLookGateFromNative(gLastController, "mouse-input-refresh")) {
        if (gPointerLockWanted || gPointerCaptureActive) {
            BridgeLog("mouse-look gate blocked pointer lock on mouse input allowed=%d platform=%d wanted=%d capture=%d",
                      gMouseLookAllowed ? 1 : 0,
                      CurrentPlatformPointerLocked() ? 1 : 0,
                      gPointerLockWanted ? 1 : 0,
                      gPointerCaptureActive ? 1 : 0);
            gPointerLockInhibited = true;
            ClearPointerLockIfNeeded();
        } else if (CurrentPlatformPointerLocked()) {
            BridgeLog("mouse-look gate clearing stale native platform lock allowed=0 platform=1 wanted=0 capture=0");
            ClearPointerLockIfNeeded();
        }
        ReconcilePointerCapture(gLastController, "mouse-look-gate-blocked");
        return false;
    }

    if (gPointerLockInhibited) {
        BridgeLog("pointer lock inhibit cleared by mouse-look gate on mouse input platform=%d",
                  CurrentPlatformPointerLocked() ? 1 : 0);
        gPointerLockInhibited = false;
        gPointerLockRearmAllowedByToggle = false;
        gPointerLockRearmAllowedByMouseClick = false;
        gPointerRearmBlockedLogged = false;
    }

    if (!CurrentPlatformPointerLocked() && (gPointerCaptureActive || gPointerLockWanted)) {
        if (!gPointerLockInhibited) {
            BridgeLog("mouse-input observed native platform unlock; inhibiting pointer relock");
        }
        gPointerLockInhibited = true;
        ReconcilePointerCapture(gLastController, "mouse-input-native-unlock");
        return false;
    }
    if (gPointerLockInhibited && !CurrentPlatformPointerLocked()) {
        ReconcilePointerCapture(gLastController, "mouse-input-inhibited");
        return false;
    }

    if (!CurrentPlatformPointerLocked()) {
        SetPlatformPointerLocked(true, "mouse-input");
    }

    SetNeedsPointerLockUpdateForVisibleChain();
    ReconcilePointerCapture(gLastController, "mouse-input");
    return CurrentPlatformPointerLocked() && !gPointerLockInhibited && !gTextInputActive && !gBridgeHUDEditorActive;
}

bool HasRecentNativeMouseMovement(void) {
    if (gLastNativeMouseMoveUsec == 0) {
        return false;
    }
    uint64_t now = NowUsec();
    return now >= gLastNativeMouseMoveUsec && now - gLastNativeMouseMoveUsec < 250000ULL;
}

void ClearPointerLockIfNeeded(void) {
    if (!gPointerLockWanted && !CurrentPlatformPointerLocked()) {
        ReconcilePointerCapture(gLastController, "clear-no-pointer-state");
        return;
    }

    SetPointerCaptureActive(false, "clear");
    gClearingPointerLock = true;
    SetPlatformPointerLocked(false, "clear");
    gClearingPointerLock = false;
    gPointerLockReturnLogged = false;
    gPointerRegionLogged = false;
    gPointerRegionNilLogged = false;
    gTouchSuppressionLogged = false;
    SetNeedsPointerLockUpdateForVisibleChain();
    ReconcilePointerCapture(gLastController, "clear-after-platform");
}
