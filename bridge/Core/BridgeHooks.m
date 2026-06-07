#import "../BridgeInternal.h"

bool HookInstanceMethod(Class cls, SEL sel, IMP replacement) {
    if (cls == Nil || sel == NULL || replacement == NULL || gHookCount >= (int)(sizeof(gHooks) / sizeof(gHooks[0]))) {
        return false;
    }
    if (HookAlreadyInstalled(cls, sel) || class_getMethodImplementation(cls, sel) == replacement) {
        return true;
    }

    Method method = class_getInstanceMethod(cls, sel);
    if (method == NULL) {
        return false;
    }

    IMP original = class_getMethodImplementation(cls, sel);
    const char *types = method_getTypeEncoding(method);
    if (!class_addMethod(cls, sel, replacement, types)) {
        original = method_setImplementation(method, replacement);
    }

    gHooks[gHookCount++] = (HookEntry){ cls, sel, original };
    return true;
}

bool AddOrHookInstanceMethod(Class cls, SEL sel, IMP replacement, const char *types) {
    if (cls == Nil || sel == NULL || replacement == NULL || types == NULL || gHookCount >= (int)(sizeof(gHooks) / sizeof(gHooks[0]))) {
        return false;
    }
    if (HookAlreadyInstalled(cls, sel) || class_getMethodImplementation(cls, sel) == replacement) {
        return true;
    }

    Method method = class_getInstanceMethod(cls, sel);
    IMP original = method == NULL ? NULL : class_getMethodImplementation(cls, sel);
    if (method == NULL) {
        if (!class_addMethod(cls, sel, replacement, types)) {
            return false;
        }
        BridgeLog("added method %s %s", class_getName(cls), sel_getName(sel));
    } else if (!class_addMethod(cls, sel, replacement, method_getTypeEncoding(method))) {
        original = method_setImplementation(method, replacement);
        BridgeLog("hooked method %s %s", class_getName(cls), sel_getName(sel));
    }

    gHooks[gHookCount++] = (HookEntry){ cls, sel, original };
    return true;
}

bool HookMethodImplementation(Class cls, SEL sel, IMP replacement) {
    if (cls == Nil || sel == NULL || replacement == NULL || gHookCount >= (int)(sizeof(gHooks) / sizeof(gHooks[0]))) {
        return false;
    }
    if (HookAlreadyInstalled(cls, sel) || class_getMethodImplementation(cls, sel) == replacement) {
        return true;
    }

    Method method = class_getInstanceMethod(cls, sel);
    if (method == NULL) {
        return false;
    }

    IMP original = method_setImplementation(method, replacement);
    gHooks[gHookCount++] = (HookEntry){ cls, sel, original };
    BridgeLog("hooked method %s %s", class_getName(cls), sel_getName(sel));
    return true;
}

bool InstallMarker(Class cls) {
    const char *existingMarkers[] = {
        "mcKeyboardBridgeInstalled",
        "mcKeyboardBridgeInstalledV1",
        "mcKeyboardBridgeInstalledV2",
        "mcKeyboardBridgeInstalledV3",
        "mcKeyboardBridgeInstalledV4",
        "mcKeyboardBridgeInstalledV5",
        "mcKeyboardBridgeInstalledV6",
        "mcKeyboardBridgeInstalledV7",
        "mcKeyboardBridgeInstalledV8",
        "mcKeyboardBridgeInstalledV9",
        "mcKeyboardBridgeInstalledV10",
        "mcKeyboardBridgeInstalledV11",
        "mcKeyboardBridgeInstalledV12",
        "mcKeyboardBridgeInstalledV13",
        "mcKeyboardBridgeInstalledV14",
        "mcKeyboardBridgeInstalledV15",
        "mcKeyboardBridgeInstalledV16",
        "mcKeyboardBridgeInstalledV17",
        "mcKeyboardBridgeInstalledV18",
        "mcKeyboardBridgeInstalledV19",
        "mcKeyboardBridgeInstalledV20",
        "mcKeyboardBridgeInstalledV21",
        "mcKeyboardBridgeInstalledV22",
        "mcKeyboardBridgeInstalledV23",
        "mcKeyboardBridgeInstalledV24",
        "mcKeyboardBridgeInstalledV25",
        "mcKeyboardBridgeInstalledV26",
        "mcKeyboardBridgeInstalledV27",
        "mcKeyboardBridgeInstalledV28",
        "mcKeyboardBridgeInstalledV29",
        "mcKeyboardBridgeInstalledV30",
        "mcKeyboardBridgeInstalledV31",
        "mcKeyboardBridgeInstalledV32",
        "mcKeyboardBridgeInstalledV33",
        "mcKeyboardBridgeInstalledProductionV1",
        "mineBridgeInstalledProductionV1",
    };
    for (unsigned long i = 0; i < sizeof(existingMarkers) / sizeof(existingMarkers[0]); i++) {
        if (class_getInstanceMethod(cls, sel_registerName(existingMarkers[i])) != NULL) {
            BridgeLog("existing bridge marker=%s", existingMarkers[i]);
            return false;
        }
    }

    SEL marker = sel_registerName("mineBridgeInstalledProductionV1");
    IMP markerImp = imp_implementationWithBlock(^void(id self) {});
    return class_addMethod(cls, marker, markerImp, "v16@0:8");
}
