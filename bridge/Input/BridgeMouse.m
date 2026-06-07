#import "../BridgeInternal.h"

static bool ShouldSuppressMouseButtonInput(int buttonIndex, bool pressed, const char *source);

static void BridgeHUDRefreshForMouseButtonIfNeeded(int buttonIndex) {
    if (gBridgeHUDKeystrokesEnabled && (buttonIndex == 0 || buttonIndex == 1)) {
        BridgeHUDRefresh();
    }
}

void EmitScrollInput(float xValue,
                            float yValue,
                            int64_t lineX,
                            int64_t lineY,
                            int64_t pointX,
                            int64_t pointY) {
    if (gScrollInput == nil) {
        BridgeTraceLog("scroll skipped input=<nil> lineX=%lld lineY=%lld pointX=%lld pointY=%lld",
                       lineX,
                       lineY,
                       pointX,
                       pointY);
        return;
    }

    gScrollXValue = xValue;
    gScrollYValue = yValue;
    BridgeTraceLog("synthetic scroll lineX=%lld lineY=%lld pointX=%lld pointY=%lld sentX=%.3f sentY=%.3f dpadHandler=%p xHandler=%p yHandler=%p",
                   lineX,
                   lineY,
                   pointX,
                   pointY,
                   xValue,
                   yValue,
                   (__bridge void *)gScrollChangedHandler,
                   (__bridge void *)gScrollXAxisChangedHandler,
                   (__bridge void *)gScrollYAxisChangedHandler);

    if (gScrollChangedHandler != nil) {
        gScrollChangedHandler(gScrollInput, xValue, yValue);
    }
    if (gScrollXAxisChangedHandler != nil) {
        gScrollXAxisChangedHandler(gScrollXAxis, xValue);
    }
    if (gScrollYAxisChangedHandler != nil) {
        gScrollYAxisChangedHandler(gScrollYAxis, yValue);
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 20 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        if (gScrollXValue != xValue || gScrollYValue != yValue) {
            return;
        }

        gScrollXValue = 0.0f;
        gScrollYValue = 0.0f;
        if (gScrollChangedHandler != nil) {
            gScrollChangedHandler(gScrollInput, 0.0f, 0.0f);
        }
        if (gScrollXAxisChangedHandler != nil) {
            gScrollXAxisChangedHandler(gScrollXAxis, 0.0f);
        }
        if (gScrollYAxisChangedHandler != nil) {
            gScrollYAxisChangedHandler(gScrollYAxis, 0.0f);
        }
    });
}

CGEventRefOpaque ScrollEventTapCallback(CGEventTapProxyOpaque proxy, uint32_t type, CGEventRefOpaque event, void *refcon) {
    (void)proxy;
    (void)refcon;

    static const uint32_t kEventTapDisabledByTimeout = 0xFFFFFFFE;
    static const uint32_t kEventTapDisabledByUserInput = 0xFFFFFFFF;
    static const uint32_t kEventScrollWheel = 22;
    static const int32_t kScrollDeltaAxis1 = 11;
    static const int32_t kScrollDeltaAxis2 = 12;
    static const int32_t kScrollPointDeltaAxis1 = 96;
    static const int32_t kScrollPointDeltaAxis2 = 97;

    if (type == kEventTapDisabledByTimeout || type == kEventTapDisabledByUserInput) {
        if (gCGEventTapEnable != NULL && gScrollEventTap != NULL) {
            gCGEventTapEnable(gScrollEventTap, true);
            BridgeLog("scroll event tap re-enabled type=%u", type);
        }
        return event;
    }

    if (type != kEventScrollWheel || event == NULL || gCGEventGetIntegerValueField == NULL) {
        return event;
    }

    int64_t lineY = gCGEventGetIntegerValueField(event, kScrollDeltaAxis1);
    int64_t lineX = gCGEventGetIntegerValueField(event, kScrollDeltaAxis2);
    int64_t pointY = gCGEventGetIntegerValueField(event, kScrollPointDeltaAxis1);
    int64_t pointX = gCGEventGetIntegerValueField(event, kScrollPointDeltaAxis2);
    float xValue = lineX != 0 ? (float)lineX : (float)pointX / 10.0f;
    float yValue = lineY != 0 ? (float)lineY : (float)pointY / 10.0f;

    if (xValue == 0.0f && yValue == 0.0f) {
        return event;
    }
    if (gBridgeMenuVisible || gBridgeHUDEditorActive) {
        BridgeTraceLog("scroll suppressed by bridge ui lineX=%lld lineY=%lld pointX=%lld pointY=%lld menu=%d hudEditor=%d",
                       lineX,
                       lineY,
                       pointX,
                       pointY,
                       gBridgeMenuVisible ? 1 : 0,
                       gBridgeHUDEditorActive ? 1 : 0);
        return event;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        EmitScrollInput(xValue, yValue, lineX, lineY, pointX, pointY);
    });
    return event;
}

void StartScrollEventTapIfNeeded(void) {
    if (gScrollEventTap != NULL) {
        return;
    }

    if (!ResolveScrollFunctions()) {
        if (!gScrollFunctionsUnavailableLogged) {
            BridgeLog("scroll event tap unavailable");
            gScrollFunctionsUnavailableLogged = true;
        }
        return;
    }

    static const uint32_t kCGSessionEventTap = 1;
    static const uint32_t kCGHeadInsertEventTap = 0;
    static const uint32_t kCGEventTapOptionListenOnly = 1;
    static const uint32_t kCGEventScrollWheel = 22;
    uint64_t scrollMask = 1ULL << kCGEventScrollWheel;

    gScrollEventTap = gCGEventTapCreate(kCGSessionEventTap,
                                        kCGHeadInsertEventTap,
                                        kCGEventTapOptionListenOnly,
                                        scrollMask,
                                        ScrollEventTapCallback,
                                        NULL);
    if (gScrollEventTap == NULL) {
        BridgeLog("scroll event tap create failed");
        return;
    }

    gScrollEventTapSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, gScrollEventTap, 0);
    if (gScrollEventTapSource == NULL) {
        BridgeLog("scroll event tap runloop source failed tap=%p", gScrollEventTap);
        return;
    }

    CFRunLoopAddSource(CFRunLoopGetMain(), gScrollEventTapSource, kCFRunLoopCommonModes);
    gCGEventTapEnable(gScrollEventTap, true);
    BridgeLog("started scroll event tap tap=%p source=%p", gScrollEventTap, gScrollEventTapSource);
}

void PollSyntheticMouseInput(void) {
    if (gMouseInput == nil && gMouseMovedHandler == nil) {
        return;
    }

    if (!ResolveMouseFunctions()) {
        if (!gMouseFunctionsUnavailableLogged) {
            BridgeLog("synthetic mouse unavailable");
            gMouseFunctionsUnavailableLogged = true;
        }
        return;
    }

    static const uint32_t moveEventTypes[] = {
        5,  // kCGEventMouseMoved
        6,  // kCGEventLeftMouseDragged
        7,  // kCGEventRightMouseDragged
        27, // kCGEventOtherMouseDragged
    };

    bool moved = false;
    for (unsigned int i = 0; i < sizeof(moveEventTypes) / sizeof(moveEventTypes[0]); i++) {
        uint32_t counter = gCGEventSourceCounterForEventType(1, moveEventTypes[i]);
        if (!gMouseCountersInitialized) {
            gMouseMoveCounters[i] = counter;
            continue;
        }
        if (counter != gMouseMoveCounters[i]) {
            moved = true;
            gMouseMoveCounters[i] = counter;
        }
    }
    if (!gMouseCountersInitialized) {
        gMouseCountersInitialized = true;
    }

    if (moved && gMouseMovedHandler != nil && gMouseInput != nil) {
        if (HasRecentNativeMouseMovement()) {
            int32_t ignoredX = 0;
            int32_t ignoredY = 0;
            gCGGetLastMouseDelta(&ignoredX, &ignoredY);
            if (!gSyntheticMouseMovementSuppressedLogged) {
                BridgeLog("suppressing synthetic mouse movement because native GCMouse movement is active input=%p drainedDx=%d drainedDy=%d",
                          (__bridge void *)gMouseInput,
                          ignoredX,
                          ignoredY);
                gSyntheticMouseMovementSuppressedLogged = true;
            }
            goto poll_buttons;
        }

        int32_t deltaX = 0;
        int32_t deltaY = 0;
        gCGGetLastMouseDelta(&deltaX, &deltaY);
        if (deltaX != 0 || deltaY != 0) {
            if (gDropInitialSyntheticMouseDelta) {
                gDropInitialSyntheticMouseDelta = false;
                BridgeLog("dropped initial synthetic mouse delta after bridge load dx=%d rawDy=%d",
                          deltaX,
                          deltaY);
                goto poll_buttons;
            }
            float sentY = (float)-deltaY;
            bool shouldForwardMouseMove = RequestPointerLockIfNeeded();
            if (!shouldForwardMouseMove) {
                BridgeTraceLog("synthetic mouseMoved suppressed by pointer gate dx=%d rawDy=%d menu=%d textInput=%d allowed=%d platform=%d",
                               deltaX,
                               deltaY,
                               gBridgeMenuVisible ? 1 : 0,
                               gTextInputActive ? 1 : 0,
                               gMouseLookAllowed ? 1 : 0,
                               CurrentPlatformPointerLocked() ? 1 : 0);
                goto poll_buttons;
            }
            if (gDropNextMouseDeltaAfterPointerLock) {
                gDropNextMouseDeltaAfterPointerLock = false;
                BridgeLog("dropped first synthetic mouse delta after pointer lock dx=%d rawDy=%d",
                          deltaX,
                          deltaY);
                goto poll_buttons;
            }
            BridgeTraceLog("synthetic mouseMoved dx=%d rawDy=%d sentY=%.3f input=%p",
                           deltaX,
                           deltaY,
                           sentY,
                           (__bridge void *)gMouseInput);
            gMouseMovedHandler(gMouseInput, (float)deltaX, sentY);
        }
    }

poll_buttons:
    for (int button = 0; button < 3; button++) {
        if (gMouseButtons[button] == nil) {
            continue;
        }

        bool pressed = gCGEventSourceButtonState(1, button);
        if (pressed == gMouseButtonStates[button]) {
            continue;
        }

        gMouseButtonStates[button] = pressed;
        BridgeHUDRefreshForMouseButtonIfNeeded(button);
        if (ShouldSuppressMouseButtonInput(button, pressed, "synthetic button")) {
            if (!pressed) {
                gMouseButtonSuppressedByBridgeUI[button] = false;
            }
            continue;
        }
        BridgeTraceLog("synthetic buttonChanged role=%s value=%.1f pressed=%d pressedHandler=%p valueHandler=%p touchedHandler=%p",
                       button == 0 ? "left" : button == 1 ? "right" : "middle",
                       pressed ? 1.0 : 0.0,
                       pressed ? 1 : 0,
                       (__bridge void *)gMousePressedHandlers[button],
                       (__bridge void *)gMouseValueHandlers[button],
                       (__bridge void *)gMouseTouchedHandlers[button]);
        EmitMouseButtonInput(button, pressed, "synthetic-poll");
    }
}

void StartSyntheticMousePollerIfNeeded(void) {
    if (gSyntheticMouseTimer != nil) {
        return;
    }

    gSyntheticMouseTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(gSyntheticMouseTimer, dispatch_time(DISPATCH_TIME_NOW, 0), 5 * NSEC_PER_MSEC, 1 * NSEC_PER_MSEC);
    dispatch_source_set_event_handler(gSyntheticMouseTimer, ^{
        PollSyntheticMouseInput();
    });
    dispatch_resume(gSyntheticMouseTimer);
    BridgeLog("started synthetic mouse poller");
}
const char *MouseButtonRole(id buttonInput) {
    if (gMouseInput == nil || buttonInput == nil) {
        return "unknown";
    }

    UpdateMouseButtonReferences();
    if (buttonInput == gMouseButtons[0]) {
        return "left";
    }
    if (buttonInput == gMouseButtons[1]) {
        return "right";
    }
    if (buttonInput == gMouseButtons[2]) {
        return "middle";
    }
    return "other";
}

int MouseButtonIndex(id buttonInput) {
    UpdateMouseButtonReferences();
    for (int i = 0; i < 3; i++) {
        if (buttonInput != nil && buttonInput == gMouseButtons[i]) {
            return i;
        }
    }
    return -1;
}

void EmitMouseButtonInput(int buttonIndex, bool pressed, const char *reason) {
    if (buttonIndex < 0 || buttonIndex >= 3 || gMouseButtons[buttonIndex] == nil) {
        return;
    }

    id button = gMouseButtons[buttonIndex];
    float value = pressed ? 1.0f : 0.0f;
    BridgeTraceLog("emit mouse button role=%s pressed=%d reason=%s valueHandler=%p pressedHandler=%p touchedHandler=%p",
                   buttonIndex == 0 ? "left" : buttonIndex == 1 ? "right" : "middle",
                   pressed ? 1 : 0,
                   reason == NULL ? "<nil>" : reason,
                   (__bridge void *)gMouseValueHandlers[buttonIndex],
                   (__bridge void *)gMousePressedHandlers[buttonIndex],
                   (__bridge void *)gMouseTouchedHandlers[buttonIndex]);
    if (gMouseValueHandlers[buttonIndex] != nil) {
        gMouseValueHandlers[buttonIndex](button, value, pressed);
    }
    if (gMousePressedHandlers[buttonIndex] != nil) {
        gMousePressedHandlers[buttonIndex](button, value, pressed);
    }
    if (gMouseTouchedHandlers[buttonIndex] != nil) {
        gMouseTouchedHandlers[buttonIndex](button, value, pressed, pressed);
    }
}

void BridgeSuppressActiveMouseButtonsForUI(const char *reason) {
    bool canReadPhysicalButtons = ResolveMouseFunctions();
    if (!canReadPhysicalButtons && !gMouseFunctionsUnavailableLogged) {
        BridgeLog("physical mouse button scan unavailable for bridge ui");
        gMouseFunctionsUnavailableLogged = true;
    }

    for (int button = 0; button < 3; button++) {
        bool trackedDown = gMouseButtonStates[button];
        bool physicallyDown = canReadPhysicalButtons && gCGEventSourceButtonState(1, button);
        if (!trackedDown && !physicallyDown) {
            continue;
        }

        gMouseButtonSuppressedByBridgeUI[button] = true;
        gMouseButtonStates[button] = false;
        BridgeLog("mouse button suppressed for bridge ui role=%s tracked=%d physical=%d reason=%s",
                  button == 0 ? "left" : button == 1 ? "right" : "middle",
                  trackedDown ? 1 : 0,
                  physicallyDown ? 1 : 0,
                  reason == NULL ? "<nil>" : reason);
        EmitMouseButtonInput(button, false, reason);
        BridgeHUDRefreshForMouseButtonIfNeeded(button);
    }
}

static bool ShouldSuppressMouseButtonInput(int buttonIndex, bool pressed, const char *source) {
    if (buttonIndex < 0 || buttonIndex >= 3) {
        return gBridgeMenuVisible || gBridgeHUDEditorActive;
    }

    if (gBridgeMenuVisible || gBridgeHUDEditorActive) {
        if (pressed) {
            gMouseButtonSuppressedByBridgeUI[buttonIndex] = true;
        } else {
            gMouseButtonSuppressedByBridgeUI[buttonIndex] = false;
        }
        BridgeTraceLog("%s suppressed by bridge ui role=%s pressed=%d menu=%d hudEditor=%d",
                       source == NULL ? "mouse button" : source,
                       buttonIndex == 0 ? "left" : buttonIndex == 1 ? "right" : "middle",
                       pressed ? 1 : 0,
                       gBridgeMenuVisible ? 1 : 0,
                       gBridgeHUDEditorActive ? 1 : 0);
        return true;
    }

    if (!gMouseButtonSuppressedByBridgeUI[buttonIndex]) {
        return false;
    }

    BridgeTraceLog("%s suppressed until physical release role=%s pressed=%d",
                   source == NULL ? "mouse button" : source,
                   buttonIndex == 0 ? "left" : buttonIndex == 1 ? "right" : "middle",
                   pressed ? 1 : 0);
    if (!pressed) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!gMouseButtonStates[buttonIndex]) {
                gMouseButtonSuppressedByBridgeUI[buttonIndex] = false;
            }
        });
    }
    return true;
}

void ReplacementSetMouseMovedHandler(id self, SEL _cmd, id block) {
    gMouseInput = self;
    UpdateMouseButtonReferences();
    UpdateMouseScrollReferences();
    InstallMouseButtonHooksForCurrentButtons();
    InstallScrollHooksForCurrentScroll();
    gMouseMovedHandler = block == nil ? nil : [block copy];
    BridgeLog("captured mouseMovedHandler input=%p scroll=%p xAxis=%p yAxis=%p block=%p",
              (__bridge void *)self,
              (__bridge void *)gScrollInput,
              (__bridge void *)gScrollXAxis,
              (__bridge void *)gScrollYAxis,
              (__bridge void *)block);
    StartSyntheticMousePollerIfNeeded();
    StartScrollEventTapIfNeeded();

    id replacement = nil;
    if (gMouseMovedHandler != nil) {
        void (^originalBlock)(id, float, float) = gMouseMovedHandler;
        replacement = [^void(id mouseInput, float deltaX, float deltaY) {
            gLastNativeMouseMoveUsec = NowUsec();
            bool shouldForwardMouseMove = RequestPointerLockIfNeeded();
            if (!shouldForwardMouseMove) {
                BridgeTraceLog("native mouseMoved suppressed by pointer gate dx=%.3f dy=%.3f menu=%d textInput=%d allowed=%d platform=%d",
                               deltaX,
                               deltaY,
                               gBridgeMenuVisible ? 1 : 0,
                               gTextInputActive ? 1 : 0,
                               gMouseLookAllowed ? 1 : 0,
                               CurrentPlatformPointerLocked() ? 1 : 0);
                return;
            }
            if (!gNativeMouseMovementLogged) {
                BridgeLog("native mouseMoved active dx=%.3f dy=%.3f input=%p",
                          deltaX,
                          deltaY,
                          (__bridge void *)mouseInput);
                gNativeMouseMovementLogged = true;
            }
            originalBlock(mouseInput, deltaX, deltaY);
        } copy];
    }

    IMP original = OriginalFor(self, _cmd);
    if (original != NULL) {
        ((void (*)(id, SEL, id))original)(self, _cmd, replacement);
    }
}

void ReplacementSetPressedChangedHandler(id self, SEL _cmd, id block) {
    void (^originalBlock)(id, float, BOOL) = block == nil ? nil : [block copy];
    int buttonIndex = MouseButtonIndex(self);
    if (buttonIndex >= 0) {
        gMousePressedHandlers[buttonIndex] = originalBlock;
        StartSyntheticMousePollerIfNeeded();
    }

    BridgeLog("captured pressedChangedHandler button=%p role=%s block=%p",
              (__bridge void *)self,
              MouseButtonRole(self),
              (__bridge void *)block);

    id replacement = nil;
    if (originalBlock != nil) {
        replacement = [^void(id buttonInput, float value, BOOL pressed) {
            int index = MouseButtonIndex(buttonInput);
            if (index >= 0) {
                gMouseButtonStates[index] = pressed;
                BridgeHUDRefreshForMouseButtonIfNeeded(index);
            }
            if (ShouldSuppressMouseButtonInput(index, pressed, "native buttonPressed")) {
                return;
            }
            BridgeTraceLog("native buttonChanged button=%p role=%s value=%.3f pressed=%d",
                           (__bridge void *)buttonInput,
                           MouseButtonRole(buttonInput),
                           value,
                           pressed ? 1 : 0);
            originalBlock(buttonInput, value, pressed);
        } copy];
    }

    IMP original = OriginalFor(self, _cmd);
    if (original != NULL) {
        ((void (*)(id, SEL, id))original)(self, _cmd, replacement);
    }
}

void ReplacementSetValueChangedHandler(id self, SEL _cmd, id block) {
    void (^originalBlock)(id, float, BOOL) = block == nil ? nil : [block copy];
    int buttonIndex = MouseButtonIndex(self);
    if (buttonIndex >= 0) {
        gMouseValueHandlers[buttonIndex] = originalBlock;
        StartSyntheticMousePollerIfNeeded();
    }

    BridgeLog("captured valueChangedHandler button=%p role=%s block=%p",
              (__bridge void *)self,
              MouseButtonRole(self),
              (__bridge void *)block);

    id replacement = nil;
    if (originalBlock != nil) {
        replacement = [^void(id buttonInput, float value, BOOL pressed) {
            int index = MouseButtonIndex(buttonInput);
            if (index >= 0) {
                gMouseButtonStates[index] = pressed;
                BridgeHUDRefreshForMouseButtonIfNeeded(index);
            }
            if (ShouldSuppressMouseButtonInput(index, pressed, "native buttonValue")) {
                return;
            }
            BridgeTraceLog("native buttonValueChanged button=%p role=%s value=%.3f pressed=%d",
                           (__bridge void *)buttonInput,
                           MouseButtonRole(buttonInput),
                           value,
                           pressed ? 1 : 0);
            originalBlock(buttonInput, value, pressed);
        } copy];
    }

    IMP original = OriginalFor(self, _cmd);
    if (original != NULL) {
        ((void (*)(id, SEL, id))original)(self, _cmd, replacement);
    }
}

void ReplacementSetTouchedChangedHandler(id self, SEL _cmd, id block) {
    void (^originalBlock)(id, float, BOOL, BOOL) = block == nil ? nil : [block copy];
    int buttonIndex = MouseButtonIndex(self);
    if (buttonIndex >= 0) {
        gMouseTouchedHandlers[buttonIndex] = originalBlock;
        StartSyntheticMousePollerIfNeeded();
    }

    BridgeLog("captured touchedChangedHandler button=%p role=%s block=%p",
              (__bridge void *)self,
              MouseButtonRole(self),
              (__bridge void *)block);

    id replacement = nil;
    if (originalBlock != nil) {
        replacement = [^void(id buttonInput, float value, BOOL pressed, BOOL touched) {
            int index = MouseButtonIndex(buttonInput);
            if (index >= 0) {
                gMouseButtonStates[index] = pressed;
                BridgeHUDRefreshForMouseButtonIfNeeded(index);
            }
            if (ShouldSuppressMouseButtonInput(index, pressed, "native buttonTouch")) {
                return;
            }
            BridgeTraceLog("native buttonTouchedChanged button=%p role=%s value=%.3f pressed=%d touched=%d",
                           (__bridge void *)buttonInput,
                           MouseButtonRole(buttonInput),
                           value,
                           pressed ? 1 : 0,
                           touched ? 1 : 0);
            originalBlock(buttonInput, value, pressed, touched);
        } copy];
    }

    IMP original = OriginalFor(self, _cmd);
    if (original != NULL) {
        ((void (*)(id, SEL, id))original)(self, _cmd, replacement);
    }
}

float ReplacementButtonValue(id self, SEL _cmd) {
    int buttonIndex = MouseButtonIndex(self);
    if (buttonIndex >= 0) {
        return gMouseButtonStates[buttonIndex] ? 1.0f : 0.0f;
    }

    IMP original = OriginalFor(self, _cmd);
    if (original != NULL) {
        return ((float (*)(id, SEL))original)(self, _cmd);
    }
    return 0.0f;
}

BOOL ReplacementButtonIsPressed(id self, SEL _cmd) {
    int buttonIndex = MouseButtonIndex(self);
    if (buttonIndex >= 0) {
        return gMouseButtonStates[buttonIndex] ? YES : NO;
    }

    IMP original = OriginalFor(self, _cmd);
    if (original != NULL) {
        return ((BOOL (*)(id, SEL))original)(self, _cmd);
    }
    return NO;
}

BOOL ReplacementButtonIsTouched(id self, SEL _cmd) {
    int buttonIndex = MouseButtonIndex(self);
    if (buttonIndex >= 0) {
        return gMouseButtonStates[buttonIndex] ? YES : NO;
    }

    IMP original = OriginalFor(self, _cmd);
    if (original != NULL) {
        return ((BOOL (*)(id, SEL))original)(self, _cmd);
    }
    return NO;
}

const char *ScrollAxisRole(id axisInput) {
    UpdateMouseScrollReferences();
    if (axisInput != nil && axisInput == gScrollXAxis) {
        return "scroll-x";
    }
    if (axisInput != nil && axisInput == gScrollYAxis) {
        return "scroll-y";
    }
    return "other-axis";
}

void ReplacementSetDirectionPadValueChangedHandler(id self, SEL _cmd, id block) {
    void (^originalBlock)(id, float, float) = block == nil ? nil : [block copy];
    UpdateMouseScrollReferences();
    if (self != nil && self == gScrollInput) {
        gScrollChangedHandler = originalBlock;
        StartScrollEventTapIfNeeded();
    }

    BridgeLog("captured dpad valueChangedHandler dpad=%p isScroll=%d block=%p",
              (__bridge void *)self,
              self != nil && self == gScrollInput ? 1 : 0,
              (__bridge void *)block);

    id replacement = nil;
    if (originalBlock != nil) {
        replacement = [^void(id dpadInput, float xValue, float yValue) {
            BridgeTraceLog("native dpadValueChanged dpad=%p isScroll=%d x=%.3f y=%.3f",
                           (__bridge void *)dpadInput,
                           dpadInput != nil && dpadInput == gScrollInput ? 1 : 0,
                           xValue,
                           yValue);
            originalBlock(dpadInput, xValue, yValue);
        } copy];
    }

    IMP original = OriginalFor(self, _cmd);
    if (original != NULL) {
        ((void (*)(id, SEL, id))original)(self, _cmd, replacement);
    }
}

void ReplacementSetAxisValueChangedHandler(id self, SEL _cmd, id block) {
    void (^originalBlock)(id, float) = block == nil ? nil : [block copy];
    UpdateMouseScrollReferences();
    if (self != nil && self == gScrollXAxis) {
        gScrollXAxisChangedHandler = originalBlock;
        StartScrollEventTapIfNeeded();
    } else if (self != nil && self == gScrollYAxis) {
        gScrollYAxisChangedHandler = originalBlock;
        StartScrollEventTapIfNeeded();
    }

    BridgeLog("captured axis valueChangedHandler axis=%p role=%s block=%p",
              (__bridge void *)self,
              ScrollAxisRole(self),
              (__bridge void *)block);

    id replacement = nil;
    if (originalBlock != nil) {
        replacement = [^void(id axisInput, float value) {
            BridgeTraceLog("native axisValueChanged axis=%p role=%s value=%.3f",
                           (__bridge void *)axisInput,
                           ScrollAxisRole(axisInput),
                           value);
            originalBlock(axisInput, value);
        } copy];
    }

    IMP original = OriginalFor(self, _cmd);
    if (original != NULL) {
        ((void (*)(id, SEL, id))original)(self, _cmd, replacement);
    }
}

float ReplacementAxisValue(id self, SEL _cmd) {
    UpdateMouseScrollReferences();
    if (self != nil && self == gScrollXAxis) {
        return gScrollXValue;
    }
    if (self != nil && self == gScrollYAxis) {
        return gScrollYValue;
    }

    IMP original = OriginalFor(self, _cmd);
    if (original != NULL) {
        return ((float (*)(id, SEL))original)(self, _cmd);
    }
    return 0.0f;
}
void HookMouseButtonClass(Class cls) {
    if (cls == Nil) {
        return;
    }

    HookMethodImplementation(cls, sel_registerName("setPressedChangedHandler:"), (IMP)ReplacementSetPressedChangedHandler);
    HookMethodImplementation(cls, sel_registerName("setValueChangedHandler:"), (IMP)ReplacementSetValueChangedHandler);
    HookMethodImplementation(cls, sel_registerName("setTouchedChangedHandler:"), (IMP)ReplacementSetTouchedChangedHandler);
    HookMethodImplementation(cls, sel_registerName("value"), (IMP)ReplacementButtonValue);
    HookMethodImplementation(cls, sel_registerName("isPressed"), (IMP)ReplacementButtonIsPressed);
    HookMethodImplementation(cls, sel_registerName("isTouched"), (IMP)ReplacementButtonIsTouched);
}

void HookDirectionPadClass(Class cls) {
    if (cls == Nil) {
        return;
    }

    HookMethodImplementation(cls, sel_registerName("setValueChangedHandler:"), (IMP)ReplacementSetDirectionPadValueChangedHandler);
}

void HookAxisClass(Class cls) {
    if (cls == Nil) {
        return;
    }

    HookMethodImplementation(cls, sel_registerName("setValueChangedHandler:"), (IMP)ReplacementSetAxisValueChangedHandler);
    HookMethodImplementation(cls, sel_registerName("value"), (IMP)ReplacementAxisValue);
}

void InstallMouseButtonHooksForCurrentButtons(void) {
    HookMouseButtonClass(objc_getClass("GCControllerButtonInput"));
    HookMouseButtonClass(objc_getClass("GCDeviceButtonInput"));

    for (int i = 0; i < 3; i++) {
        if (gMouseButtons[i] != nil) {
            HookMouseButtonClass(object_getClass(gMouseButtons[i]));
        }
    }
}

void InstallScrollHooksForCurrentScroll(void) {
    HookDirectionPadClass(objc_getClass("GCControllerDirectionPad"));
    HookDirectionPadClass(objc_getClass("GCDeviceCursor"));
    HookAxisClass(objc_getClass("GCControllerAxisInput"));

    if (gScrollInput != nil) {
        HookDirectionPadClass(object_getClass(gScrollInput));
    }
    if (gScrollXAxis != nil) {
        HookAxisClass(object_getClass(gScrollXAxis));
    }
    if (gScrollYAxis != nil) {
        HookAxisClass(object_getClass(gScrollYAxis));
    }
}
