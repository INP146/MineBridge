#import "BridgeInternal.h"

__attribute__((constructor))
static void BridgeInit(void) {
    BridgeSettingsLoad();

    Class controllerClass = objc_getClass(kControllerClassName);
    Class keyboardInputClass = objc_getClass("GCKeyboardInput");
    Class mouseInputClass = objc_getClass("GCMouseInput");
    Class buttonInputClass = objc_getClass("GCControllerButtonInput");
    Class deviceButtonInputClass = objc_getClass("GCDeviceButtonInput");
    Class directionPadClass = objc_getClass("GCControllerDirectionPad");
    Class deviceCursorClass = objc_getClass("GCDeviceCursor");
    Class axisInputClass = objc_getClass("GCControllerAxisInput");
    Class viewControllerClass = objc_getClass("UIViewController");
    Class keyboardMouseHandlerClass = objc_getClass("KeyboardAndMouseHandler_apple");
    if (controllerClass == Nil || keyboardInputClass == Nil) {
        BridgeLog("init skipped controller=%p GCKeyboardInput=%p", controllerClass, keyboardInputClass);
        return;
    }

    if (!InstallMarker(controllerClass)) {
        BridgeLog("already installed");
        return;
    }

    HookInstanceMethod(controllerClass, sel_registerName("pressesBegan:withEvent:"), (IMP)ReplacementPressesBegan);
    HookInstanceMethod(controllerClass, sel_registerName("pressesEnded:withEvent:"), (IMP)ReplacementPressesEnded);
    HookInstanceMethod(controllerClass, sel_registerName("pressesCancelled:withEvent:"), (IMP)ReplacementPressesCancelled);
    HookInstanceMethod(controllerClass, sel_registerName("viewWillDisappear:"), (IMP)ReplacementViewWillDisappear);
    HookInstanceMethod(controllerClass, sel_registerName("viewDidAppear:"), (IMP)ReplacementViewDidAppear);
    AddOrHookInstanceMethod(controllerClass,
                            sel_registerName("pointerInteraction:regionForRequest:defaultRegion:"),
                            (IMP)ReplacementPointerRegionForRequest,
                            "@40@0:8@16@24@32");
    HookMethodImplementation(viewControllerClass, sel_registerName("prefersPointerLocked"), (IMP)ReplacementPrefersPointerLocked);
    HookMethodImplementation(viewControllerClass, sel_registerName("setNeedsUpdateOfPrefersPointerLocked"), (IMP)ReplacementSetNeedsUpdateOfPrefersPointerLocked);
    HookInstanceMethod(controllerClass, sel_registerName("prefersPointerLocked"), (IMP)ReplacementPrefersPointerLocked);
    HookInstanceMethod(controllerClass, sel_registerName("touchesBegan:withEvent:"), (IMP)ReplacementTouchesBegan);
    HookInstanceMethod(controllerClass, sel_registerName("touchesMoved:withEvent:"), (IMP)ReplacementTouchesMoved);
    HookInstanceMethod(controllerClass, sel_registerName("touchesEnded:withEvent:"), (IMP)ReplacementTouchesEnded);
    HookInstanceMethod(controllerClass, sel_registerName("touchesCancelled:withEvent:"), (IMP)ReplacementTouchesCancelled);
    HookMethodImplementation(keyboardInputClass, sel_registerName("setKeyChangedHandler:"), (IMP)ReplacementSetKeyChangedHandler);
    HookMethodImplementation(mouseInputClass, sel_registerName("setMouseMovedHandler:"), (IMP)ReplacementSetMouseMovedHandler);
    HookInstanceMethod(keyboardMouseHandlerClass, sel_registerName("onTextInputBegan:"), (IMP)ReplacementOnTextInputBegan);
    HookInstanceMethod(keyboardMouseHandlerClass, sel_registerName("onTextInputEnded:"), (IMP)ReplacementOnTextInputEnded);
    HookMouseButtonClass(buttonInputClass);
    HookMouseButtonClass(deviceButtonInputClass);
    HookDirectionPadClass(directionPadClass);
    HookDirectionPadClass(deviceCursorClass);
    HookAxisClass(axisInputClass);
    StartControllerDiscoveryTimerIfNeeded();

    BridgeLog("installed project=MineBridge version=%s game=%s plugin=%s pointerOffset=0x%zx pid=%d hooks=%d",
              kBridgeVersion,
              kTargetGameVersion,
              kPluginVersion,
              kAppPlatformPointerLockedOffset,
              getpid(),
              gHookCount);
    dispatch_async(dispatch_get_main_queue(), ^{
        ShowBridgeLoadedToast();
        BridgeHUDRefresh();
    });
}

__attribute__((destructor))
static void BridgeShutdown(void) {
    ReleaseAllKeys();
}
