#import "../BridgeInternal.h"

id KeyboardHandlerForController(id controller) {
    id handler = ObjectValue(controller, "keyboardAndMouseHandler");
    if (handler != nil) {
        return handler;
    }

    Ivar ivar = class_getInstanceVariable(object_getClass(controller), "_keyboardAndMouseHandler");
    if (ivar == NULL) {
        Class superClass = class_getSuperclass(object_getClass(controller));
        while (superClass != Nil && ivar == NULL) {
            ivar = class_getInstanceVariable(superClass, "_keyboardAndMouseHandler");
            superClass = class_getSuperclass(superClass);
        }
    }

    if (ivar == NULL) {
        return nil;
    }

    void **slot = (void **)((char *)(__bridge void *)controller + ivar_getOffset(ivar));
    return slot == NULL || *slot == NULL ? nil : (__bridge id)(*slot);
}

void EnsureKeyboardConnected(id controller) {
    if (gTriedKeyboardConnect || !IsTargetController(controller)) {
        return;
    }

    id handler = KeyboardHandlerForController(controller);
    Class keyboardClass = objc_getClass("GCKeyboard");
    SEL coalescedKeyboardSel = sel_registerName("coalescedKeyboard");
    if (handler == nil || keyboardClass == Nil || !RespondsTo((id)keyboardClass, coalescedKeyboardSel)) {
        BridgeLog("keyboard connect skipped handler=%p GCKeyboard=%p", (__bridge void *)handler, keyboardClass);
        return;
    }
    gTriedKeyboardConnect = true;

    id keyboard = ((id (*)(id, SEL))objc_msgSend)((id)keyboardClass, coalescedKeyboardSel);
    id keyboardInput = ObjectValue(keyboard, "keyboardInput");
    if (gKeyboardInput == nil) {
        gKeyboardInput = keyboardInput;
    }

    SEL onConnectKeyboardSel = sel_registerName("onConnectKeyboard:");
    if (keyboard != nil && RespondsTo(handler, onConnectKeyboardSel)) {
        BridgeLog("connecting GCKeyboard keyboard=%p input=%p handler=%p",
                  (__bridge void *)keyboard,
                  (__bridge void *)keyboardInput,
                  (__bridge void *)handler);
        ((void (*)(id, SEL, id))objc_msgSend)(handler, onConnectKeyboardSel, keyboard);
    }
}

void UpdateMouseButtonReferences(void) {
    if (gMouseInput == nil) {
        memset(gMouseButtons, 0, sizeof(gMouseButtons));
        return;
    }

    gMouseButtons[0] = ObjectValue(gMouseInput, "leftButton");
    gMouseButtons[1] = ObjectValue(gMouseInput, "rightButton");
    gMouseButtons[2] = ObjectValue(gMouseInput, "middleButton");
}

void UpdateMouseScrollReferences(void) {
    if (gMouseInput == nil) {
        gScrollInput = nil;
        gScrollXAxis = nil;
        gScrollYAxis = nil;
        return;
    }

    gScrollInput = ObjectValue(gMouseInput, "scroll");
    gScrollXAxis = ObjectValue(gScrollInput, "xAxis");
    gScrollYAxis = ObjectValue(gScrollInput, "yAxis");
}

id FirstAvailableMouse(Class mouseClass) {
    if (mouseClass == Nil) {
        return nil;
    }

    id currentMouse = ObjectValue((id)mouseClass, "current");
    id mice = ObjectValue((id)mouseClass, "mice");
    unsigned long mouseCount = ULongValue(mice, "count");
    id firstMouse = nil;
    if (mouseCount > 0 && RespondsTo(mice, @selector(objectAtIndex:))) {
        firstMouse = ((id (*)(id, SEL, unsigned long))objc_msgSend)(mice, @selector(objectAtIndex:), 0);
    }

    id selectedMouse = currentMouse != nil ? currentMouse : firstMouse;
    BridgeLog("mouse lookup current=%p mice=%p count=%lu selected=%p",
              (__bridge void *)currentMouse,
              (__bridge void *)mice,
              mouseCount,
              (__bridge void *)selectedMouse);
    return selectedMouse;
}
void StartMouseRetryTimerIfNeeded(id controller) {
    if (gMouseRetryTimer != nil || gMouseConnected || !IsTargetController(controller)) {
        return;
    }

    gLastController = controller;
    gMouseRetryTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(gMouseRetryTimer, dispatch_time(DISPATCH_TIME_NOW, 250 * NSEC_PER_MSEC), 1000 * NSEC_PER_MSEC, 20 * NSEC_PER_MSEC);
    dispatch_source_set_event_handler(gMouseRetryTimer, ^{
        if (gMouseConnected) {
            dispatch_source_cancel(gMouseRetryTimer);
            gMouseRetryTimer = nil;
            return;
        }
        EnsureMouseConnected(gLastController);
    });
    dispatch_resume(gMouseRetryTimer);
    BridgeLog("started mouse retry timer");
}

void EnsureMouseConnected(id controller) {
    if (gMouseConnected || !IsTargetController(controller)) {
        return;
    }
    gLastController = controller;
    gMouseConnectAttempts++;

    id handler = KeyboardHandlerForController(controller);
    Class mouseClass = objc_getClass("GCMouse");
    if (handler == nil || mouseClass == Nil) {
        BridgeLog("mouse connect skipped attempt=%u handler=%p GCMouse=%p", gMouseConnectAttempts, (__bridge void *)handler, mouseClass);
        StartMouseRetryTimerIfNeeded(controller);
        return;
    }

    id mouse = FirstAvailableMouse(mouseClass);
    id mouseInput = ObjectValue(mouse, "mouseInput");
    if (gMouseInput == nil) {
        gMouseInput = mouseInput;
        UpdateMouseButtonReferences();
        UpdateMouseScrollReferences();
    }
    InstallMouseButtonHooksForCurrentButtons();
    InstallScrollHooksForCurrentScroll();
    StartSyntheticMousePollerIfNeeded();
    StartScrollEventTapIfNeeded();

    BridgeLog("connecting GCMouse mouse=%p input=%p left=%p(%s) right=%p(%s) middle=%p(%s) scroll=%p(%s) xAxis=%p yAxis=%p handler=%p",
              (__bridge void *)mouse,
              (__bridge void *)mouseInput,
              (__bridge void *)gMouseButtons[0],
              gMouseButtons[0] == nil ? "<nil>" : class_getName(object_getClass(gMouseButtons[0])),
              (__bridge void *)gMouseButtons[1],
              gMouseButtons[1] == nil ? "<nil>" : class_getName(object_getClass(gMouseButtons[1])),
              (__bridge void *)gMouseButtons[2],
              gMouseButtons[2] == nil ? "<nil>" : class_getName(object_getClass(gMouseButtons[2])),
              (__bridge void *)gScrollInput,
              gScrollInput == nil ? "<nil>" : class_getName(object_getClass(gScrollInput)),
              (__bridge void *)gScrollXAxis,
              (__bridge void *)gScrollYAxis,
              (__bridge void *)handler);

    SEL onConnectMouseSel = sel_registerName("onConnectMouse:");
    if (mouse != nil && RespondsTo(handler, onConnectMouseSel)) {
        ((void (*)(id, SEL, id))objc_msgSend)(handler, onConnectMouseSel, mouse);
        gMouseConnected = true;
    } else {
        BridgeLog("mouse connect unavailable attempt=%u mouse=%p handlerResponds=%d",
                  gMouseConnectAttempts,
                  (__bridge void *)mouse,
                  RespondsTo(handler, onConnectMouseSel) ? 1 : 0);
        StartMouseRetryTimerIfNeeded(controller);
    }
}

id TargetControllerInControllerTree(id controller, unsigned int depth) {
    if (controller == nil || depth > 8) {
        return nil;
    }
    if (IsTargetController(controller)) {
        return controller;
    }

    const char *singleChildSelectors[] = {
        "visibleViewController",
        "topViewController",
        "selectedViewController",
        "presentedViewController",
    };
    for (unsigned int i = 0; i < sizeof(singleChildSelectors) / sizeof(singleChildSelectors[0]); i++) {
        id child = ObjectValue(controller, singleChildSelectors[i]);
        id target = TargetControllerInControllerTree(child, depth + 1);
        if (target != nil) {
            return target;
        }
    }

    id children = ObjectValue(controller, "childViewControllers");
    unsigned long count = ULongValue(children, "count");
    if (count > 32) {
        count = 32;
    }
    if (children != nil && RespondsTo(children, @selector(objectAtIndex:))) {
        for (unsigned long i = 0; i < count; i++) {
            id child = ((id (*)(id, SEL, unsigned long))objc_msgSend)(children, @selector(objectAtIndex:), i);
            id target = TargetControllerInControllerTree(child, depth + 1);
            if (target != nil) {
                return target;
            }
        }
    }

    return nil;
}

id DiscoverTargetController(void) {
    id keyRoot = KeyWindowRootViewController();
    id target = TargetControllerInControllerTree(keyRoot, 0);
    if (target != nil) {
        return target;
    }
    return IsTargetController(gLastController) ? gLastController : nil;
}

void TryConnectDiscoveredController(const char *reason) {
    id target = DiscoverTargetController();
    if (target == nil) {
        if (gControllerDiscoveryAttempts <= 5 || gControllerDiscoveryAttempts % 20 == 0) {
            BridgeLog("controller discovery no target reason=%s attempt=%u keyRoot=%p class=%s",
                      reason == NULL ? "<nil>" : reason,
                      gControllerDiscoveryAttempts,
                      (__bridge void *)KeyWindowRootViewController(),
                      ClassName(KeyWindowRootViewController()));
        }
        return;
    }

    if (gLastController != target) {
        BridgeLog("controller discovery target reason=%s attempt=%u controller=%p class=%s keyRoot=%p",
                  reason == NULL ? "<nil>" : reason,
                  gControllerDiscoveryAttempts,
                  (__bridge void *)target,
                  ClassName(target),
                  (__bridge void *)KeyWindowRootViewController());
    }

    gLastController = target;
    EnsureMouseConnected(target);
    EnsureKeyboardConnected(target);
    if (gPointerLockWanted || CurrentPlatformPointerLocked()) {
        SetNeedsPointerLockUpdate(target);
    }
}

void StartControllerDiscoveryTimerIfNeeded(void) {
    if (gControllerDiscoveryTimer != nil) {
        return;
    }

    gControllerDiscoveryTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(gControllerDiscoveryTimer,
                              dispatch_time(DISPATCH_TIME_NOW, 50 * NSEC_PER_MSEC),
                              250 * NSEC_PER_MSEC,
                              20 * NSEC_PER_MSEC);
    dispatch_source_set_event_handler(gControllerDiscoveryTimer, ^{
        gControllerDiscoveryAttempts++;
        TryConnectDiscoveredController("timer");
        if (gMouseConnected && gKeyboardInput != nil) {
            dispatch_source_cancel(gControllerDiscoveryTimer);
            gControllerDiscoveryTimer = nil;
            BridgeLog("controller discovery completed attempts=%u controller=%p mouseInput=%p keyboardInput=%p",
                      gControllerDiscoveryAttempts,
                      (__bridge void *)gLastController,
                      (__bridge void *)gMouseInput,
                      (__bridge void *)gKeyboardInput);
        }
    });
    dispatch_resume(gControllerDiscoveryTimer);
    BridgeLog("started controller discovery timer");
}
