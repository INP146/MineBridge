#import "../BridgeInternal.h"

void ReplacementViewWillDisappear(id self, SEL _cmd, BOOL animated) {
    HideBridgeMenu("view-will-disappear");
    ReleaseAllKeys();
    ClearPointerLockIfNeeded();

    IMP original = OriginalFor(self, _cmd);
    if (original != NULL) {
        ((void (*)(id, SEL, BOOL))original)(self, _cmd, animated);
    }
}

void ReplacementViewDidAppear(id self, SEL _cmd, BOOL animated) {
    IMP original = OriginalFor(self, _cmd);
    if (original != NULL) {
        ((void (*)(id, SEL, BOOL))original)(self, _cmd, animated);
    }

    gLastController = self;
    EnsureMouseConnected(self);
    EnsureKeyboardConnected(self);
    BridgeHUDRefresh();
}

BOOL ReplacementPrefersPointerLocked(id self, SEL _cmd) {
    if (PointerLockSourceController(self) == nil) {
        IMP original = OriginalFor(self, _cmd);
        if (original != NULL) {
            return ((BOOL (*)(id, SEL))original)(self, _cmd);
        }
        return NO;
    }

    RefreshMouseLookGateFromNative(self, "native-prefersPointerLocked");

    if (ShouldPreferPointerLocked(self)) {
        ReconcilePointerCapture(self, "prefersPointerLocked");
        if (!gPointerLockReturnLogged) {
            BridgeLog("prefersPointerLocked returning YES controller=%p class=%s capture=%d inhibited=%d textInput=%d",
                      (__bridge void *)self,
                      ClassName(self),
                      gPointerCaptureActive ? 1 : 0,
                      gPointerLockInhibited ? 1 : 0,
                      gTextInputActive ? 1 : 0);
            gPointerLockReturnLogged = true;
        }
        return YES;
    }

    ReconcilePointerCapture(self, "prefersPointerLocked-no");
    return NO;
}

void ReplacementSetNeedsUpdateOfPrefersPointerLocked(id self, SEL _cmd) {
    IMP original = OriginalFor(self, _cmd);
    if (original != NULL) {
        ((void (*)(id, SEL))original)(self, _cmd);
    }

    if (PointerLockSourceController(self) != nil) {
        ReconcilePointerCapture(self, "setNeedsUpdateOfPrefersPointerLocked");
    }
}

void ReplacementOnTextInputBegan(id self, SEL _cmd, id sender) {
    IMP original = OriginalFor(self, _cmd);
    if (original != NULL) {
        ((void (*)(id, SEL, id))original)(self, _cmd, sender);
    }

    gTextInputActive = true;
    gPointerLockInhibited = true;
    BridgeInvalidateSprintGameLatch("text-input-began");
    BridgeLog("text input began handler=%p sender=%p releasing pointer lock",
              (__bridge void *)self,
              (__bridge void *)sender);
    ClearPointerLockIfNeeded();
    ReconcilePointerCapture(gLastController, "text-input-began");
}

void ReplacementOnTextInputEnded(id self, SEL _cmd, id sender) {
    IMP original = OriginalFor(self, _cmd);
    if (original != NULL) {
        ((void (*)(id, SEL, id))original)(self, _cmd, sender);
    }

    gTextInputActive = false;
    gPointerLockInhibited = false;
    BridgeLog("text input ended handler=%p sender=%p",
              (__bridge void *)self,
              (__bridge void *)sender);
    SetNeedsPointerLockUpdateForVisibleChain();
    ReconcilePointerCapture(gLastController, "text-input-ended");
}

id ReplacementChildViewControllerForPointerLock(id self, SEL _cmd) {
    if (ShouldPreferPointerLocked(self)) {
        return nil;
    }

    IMP original = OriginalFor(self, _cmd);
    if (original != NULL) {
        return ((id (*)(id, SEL))original)(self, _cmd);
    }
    return nil;
}

id ReplacementPointerRegionForRequest(id self, SEL _cmd, id interaction, id request, id defaultRegion) {
    IMP original = OriginalFor(self, _cmd);
    id region = nil;
    if (original != NULL) {
        region = ((id (*)(id, SEL, id, id, id))original)(self, _cmd, interaction, request, defaultRegion);
    }

    if (!gPointerLockWanted || !IsTargetController(self)) {
        return region;
    }

    if (region == nil) {
        if (!gPointerRegionNilLogged) {
            BridgeLog("pointer region nil respected controller=%p interaction=%p request=%p default=%p original=%p",
                      (__bridge void *)self,
                      (__bridge void *)interaction,
                      (__bridge void *)request,
                      (__bridge void *)defaultRegion,
                      (void *)original);
            gPointerRegionNilLogged = true;
        }
        return nil;
    }

    if (!gPointerRegionLogged) {
        BridgeLog("pointer region native controller=%p interaction=%p request=%p region=%p default=%p original=%p",
                  (__bridge void *)self,
                  (__bridge void *)interaction,
                  (__bridge void *)request,
                  (__bridge void *)region,
                  (__bridge void *)defaultRegion,
                  (void *)original);
        gPointerRegionLogged = true;
    }

    return region;
}

bool ShouldSuppressTouchFallback(id self, id event) {
    if (!IsTargetController(self) || gMouseInput == nil) {
        return false;
    }

    unsigned long type = ULongValue(event, "type");
    return type == 0;
}

void ReplacementTouchesBegan(id self, SEL _cmd, id touches, id event) {
    if (ShouldSuppressTouchFallback(self, event)) {
        if (!gTouchSuppressionLogged) {
            BridgeLog("suppressing UIKit touch fallback for mouse input selector=%s wanted=%d platform=%d inhibited=%d eventType=%lu",
                      sel_getName(_cmd),
                      gPointerLockWanted ? 1 : 0,
                      CurrentPlatformPointerLocked() ? 1 : 0,
                      gPointerLockInhibited ? 1 : 0,
                      ULongValue(event, "type"));
            gTouchSuppressionLogged = true;
        }
        return;
    }

    IMP original = OriginalFor(self, _cmd);
    if (original != NULL) {
        ((void (*)(id, SEL, id, id))original)(self, _cmd, touches, event);
    }
}

void ReplacementTouchesMoved(id self, SEL _cmd, id touches, id event) {
    if (ShouldSuppressTouchFallback(self, event)) {
        return;
    }

    IMP original = OriginalFor(self, _cmd);
    if (original != NULL) {
        ((void (*)(id, SEL, id, id))original)(self, _cmd, touches, event);
    }
}

void ReplacementTouchesEnded(id self, SEL _cmd, id touches, id event) {
    if (ShouldSuppressTouchFallback(self, event)) {
        return;
    }

    IMP original = OriginalFor(self, _cmd);
    if (original != NULL) {
        ((void (*)(id, SEL, id, id))original)(self, _cmd, touches, event);
    }
}

void ReplacementTouchesCancelled(id self, SEL _cmd, id touches, id event) {
    if (ShouldSuppressTouchFallback(self, event)) {
        return;
    }

    IMP original = OriginalFor(self, _cmd);
    if (original != NULL) {
        ((void (*)(id, SEL, id, id))original)(self, _cmd, touches, event);
    }
}
