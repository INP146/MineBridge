#import "../BridgeInternal.h"

static bool gNativeKeyChangedMediatedLogged = false;

id ButtonForKeyCode(unsigned short keyCode) {
    if (gKeyboardInput == nil) {
        return nil;
    }

    SEL buttonForKeyCodeSel = sel_registerName("buttonForKeyCode:");
    if (!RespondsTo(gKeyboardInput, buttonForKeyCodeSel)) {
        return nil;
    }

    return ((id (*)(id, SEL, long))objc_msgSend)(gKeyboardInput, buttonForKeyCodeSel, (long)keyCode);
}

bool MacKeyCodeForHIDUsage(unsigned short hidUsage, unsigned short *macKeyCode) {
    switch (hidUsage) {
        case 0x04: *macKeyCode = 0; return true;   // A
        case 0x05: *macKeyCode = 11; return true;  // B
        case 0x06: *macKeyCode = 8; return true;   // C
        case 0x07: *macKeyCode = 2; return true;   // D
        case 0x08: *macKeyCode = 14; return true;  // E
        case 0x09: *macKeyCode = 3; return true;   // F
        case 0x0A: *macKeyCode = 5; return true;   // G
        case 0x0B: *macKeyCode = 4; return true;   // H
        case 0x0C: *macKeyCode = 34; return true;  // I
        case 0x0D: *macKeyCode = 38; return true;  // J
        case 0x0E: *macKeyCode = 40; return true;  // K
        case 0x0F: *macKeyCode = 37; return true;  // L
        case 0x10: *macKeyCode = 46; return true;  // M
        case 0x11: *macKeyCode = 45; return true;  // N
        case 0x12: *macKeyCode = 31; return true;  // O
        case 0x13: *macKeyCode = 35; return true;  // P
        case 0x14: *macKeyCode = 12; return true;  // Q
        case 0x15: *macKeyCode = 15; return true;  // R
        case 0x16: *macKeyCode = 1; return true;   // S
        case 0x17: *macKeyCode = 17; return true;  // T
        case 0x18: *macKeyCode = 32; return true;  // U
        case 0x19: *macKeyCode = 9; return true;   // V
        case 0x1A: *macKeyCode = 13; return true;  // W
        case 0x1B: *macKeyCode = 7; return true;   // X
        case 0x1C: *macKeyCode = 16; return true;  // Y
        case 0x1D: *macKeyCode = 6; return true;   // Z
        case 0x1E: *macKeyCode = 18; return true;  // 1
        case 0x1F: *macKeyCode = 19; return true;  // 2
        case 0x20: *macKeyCode = 20; return true;  // 3
        case 0x21: *macKeyCode = 21; return true;  // 4
        case 0x22: *macKeyCode = 23; return true;  // 5
        case 0x23: *macKeyCode = 22; return true;  // 6
        case 0x24: *macKeyCode = 26; return true;  // 7
        case 0x25: *macKeyCode = 28; return true;  // 8
        case 0x26: *macKeyCode = 25; return true;  // 9
        case 0x27: *macKeyCode = 29; return true;  // 0
        case 0x28: *macKeyCode = 36; return true;  // Return
        case 0x29: *macKeyCode = 53; return true;  // Escape
        case 0x2A: *macKeyCode = 51; return true;  // Backspace
        case 0x2B: *macKeyCode = 48; return true;  // Tab
        case 0x2C: *macKeyCode = 49; return true;  // Space
        case 0x2D: *macKeyCode = 27; return true;  // Minus
        case 0x2E: *macKeyCode = 24; return true;  // Equal
        case 0x2F: *macKeyCode = 33; return true;  // Left bracket
        case 0x30: *macKeyCode = 30; return true;  // Right bracket
        case 0x31: *macKeyCode = 42; return true;  // Backslash
        case 0x33: *macKeyCode = 41; return true;  // Semicolon
        case 0x34: *macKeyCode = 39; return true;  // Quote
        case 0x35: *macKeyCode = 50; return true;  // Grave
        case 0x36: *macKeyCode = 43; return true;  // Comma
        case 0x37: *macKeyCode = 47; return true;  // Period
        case 0x38: *macKeyCode = 44; return true;  // Slash
        case 0x39: *macKeyCode = 57; return true;  // Caps lock
        case 0x3A: *macKeyCode = 122; return true; // F1
        case 0x3B: *macKeyCode = 120; return true; // F2
        case 0x3C: *macKeyCode = 99; return true;  // F3
        case 0x3D: *macKeyCode = 118; return true; // F4
        case 0x3E: *macKeyCode = 96; return true;  // F5
        case 0x3F: *macKeyCode = 97; return true;  // F6
        case 0x40: *macKeyCode = 98; return true;  // F7
        case 0x41: *macKeyCode = 100; return true; // F8
        case 0x42: *macKeyCode = 101; return true; // F9
        case 0x43: *macKeyCode = 109; return true; // F10
        case 0x44: *macKeyCode = 103; return true; // F11
        case 0x45: *macKeyCode = 111; return true; // F12
        case 0x4F: *macKeyCode = 124; return true; // Right arrow
        case 0x50: *macKeyCode = 123; return true; // Left arrow
        case 0x51: *macKeyCode = 125; return true; // Down arrow
        case 0x52: *macKeyCode = 126; return true; // Up arrow
        case 0xE0: *macKeyCode = 59; return true;  // Left control
        case 0xE1: *macKeyCode = 56; return true;  // Left shift
        case 0xE2: *macKeyCode = 58; return true;  // Left option
        case 0xE3: *macKeyCode = 55; return true;  // Left command
        case 0xE4: *macKeyCode = 62; return true;  // Right control
        case 0xE5: *macKeyCode = 60; return true;  // Right shift
        case 0xE6: *macKeyCode = 61; return true;  // Right option
        case 0xE7: *macKeyCode = 54; return true;  // Right command
        default: return false;
    }
}

bool IsFunctionKey(unsigned short keyCode) {
    return keyCode >= 0x3A && keyCode <= 0x45;
}

bool IsGameplayRearmKey(unsigned short keyCode) {
    switch (keyCode) {
        case 0x04: // A
        case 0x07: // D
        case 0x16: // S
        case 0x1A: // W
        case 0x2C: // Space
        case 0xE0: // Left control
        case 0xE1: // Left shift
        case 0xE4: // Right control
        case 0xE5: // Right shift
            return true;
        default:
            return false;
    }
}

void AddActiveKeyCode(unsigned short keyCode) {
    if (gActiveKeyCount >= (unsigned int)(sizeof(gActiveKeyCodes) / sizeof(gActiveKeyCodes[0]))) {
        BridgeLog("active key list full keyCode=%u", keyCode);
        return;
    }

    gActiveKeyCodes[gActiveKeyCount++] = keyCode;
}

void RemoveActiveKeyCode(unsigned short keyCode) {
    for (unsigned int i = 0; i < gActiveKeyCount; i++) {
        if (gActiveKeyCodes[i] != keyCode) {
            continue;
        }

        gActiveKeyCodes[i] = gActiveKeyCodes[gActiveKeyCount - 1];
        gActiveKeyCount--;
        return;
    }
}

bool SendKeyCode(unsigned short keyCode, BOOL pressed) {
    if (gKeyboardInput == nil || gKeyChangedHandler == nil) {
        BridgeLog("send skipped keyCode=%u pressed=%d input=%p handler=%p",
                  keyCode,
                  pressed ? 1 : 0,
                  (__bridge void *)gKeyboardInput,
                  (__bridge void *)gKeyChangedHandler);
        return false;
    }

    id button = ButtonForKeyCode(keyCode);
    BridgeTraceLog("emit keyCode=%u pressed=%d button=%p", keyCode, pressed ? 1 : 0, (__bridge void *)button);
    gKeyChangedHandler(gKeyboardInput, button, keyCode, pressed);
    return true;
}

void SuppressKeyCodeUntilRelease(unsigned short keyCode, bool fromMenu) {
    if (gPressedKeys[keyCode]) {
        gSuppressedKeys[keyCode] = true;
        if (fromMenu) {
            gMenuSuppressedKeys[keyCode] = true;
        }
        return;
    }

    gPressedKeys[keyCode] = true;
    gSuppressedKeys[keyCode] = true;
    gMenuSuppressedKeys[keyCode] = fromMenu;
    AddActiveKeyCode(keyCode);
    StartKeyPollerIfNeeded();
}

void ReleaseKeyCode(unsigned short keyCode, const char *reason) {
    if (!gPressedKeys[keyCode]) {
        BridgeTraceLog("skip key up for inactive keyCode=%u reason=%s", keyCode, reason);
        return;
    }

    BridgeHUDEditorHandleKeyUp(keyCode);

    bool suppressed = gSuppressedKeys[keyCode];
    gPressedKeys[keyCode] = false;
    gSuppressedKeys[keyCode] = false;
    gMenuSuppressedKeys[keyCode] = false;
    RemoveActiveKeyCode(keyCode);
    BridgeLog("release keyCode=%u reason=%s", keyCode, reason);
    if (!suppressed) {
        SendKeyCode(keyCode, NO);
    }
    if (keyCode == gBridgeSprintKeyCode) {
        BridgeHUDRefresh();
    }
}

bool BridgeSprintCanApplyToGame(const char *reason) {
    return gBridgeSprintMode == BridgeSprintModeToggle &&
           gBridgeSprintToggleDesired &&
           !gBridgeSprintToggleHeldInGame &&
           RefreshMouseLookGateFromNative(gLastController, reason == NULL ? "sprint-apply" : reason) &&
           !gBridgeMenuVisible &&
           !gBridgeHUDEditorActive &&
           !gTextInputActive;
}

void BridgeSuppressKeyForUI(unsigned short keyCode, const char *reason, bool fromPhysicalScan) {
    if (gSuppressedKeys[keyCode]) {
        gMenuSuppressedKeys[keyCode] = true;
        return;
    }

    bool wasTracked = gPressedKeys[keyCode];
    if (!wasTracked) {
        gPressedKeys[keyCode] = true;
        AddActiveKeyCode(keyCode);
        StartKeyPollerIfNeeded();
    }

    gSuppressedKeys[keyCode] = true;
    gMenuSuppressedKeys[keyCode] = true;
    BridgeLog("%s key suppressed for bridge ui keyCode=%u tracked=%d reason=%s",
              fromPhysicalScan ? "physical" : "active",
              keyCode,
              wasTracked ? 1 : 0,
              reason == NULL ? "<nil>" : reason);
    SendKeyCode(keyCode, NO);
}

void BridgeSuppressPhysicallyDownKeysForUI(const char *reason) {
    if (!ResolveKeyStateFunction()) {
        if (!gKeyStateUnavailableLogged) {
            BridgeLog("physical key scan unavailable for bridge ui");
            gKeyStateUnavailableLogged = true;
        }
        return;
    }

    for (unsigned int rawKeyCode = 0; rawKeyCode <= UINT16_MAX; rawKeyCode++) {
        unsigned short keyCode = (unsigned short)rawKeyCode;
        unsigned short macKeyCode = 0;
        if (!MacKeyCodeForHIDUsage(keyCode, &macKeyCode)) {
            continue;
        }
        if (!gCGEventSourceKeyState(1, macKeyCode)) {
            continue;
        }
        BridgeSuppressKeyForUI(keyCode, reason, true);
    }
}

void BridgeSuppressActiveGameKeysForUI(const char *reason) {
    BridgeInvalidateSprintGameLatch(reason);

    unsigned short snapshot[256];
    unsigned int count = gActiveKeyCount;
    if (count > (unsigned int)(sizeof(snapshot) / sizeof(snapshot[0]))) {
        count = (unsigned int)(sizeof(snapshot) / sizeof(snapshot[0]));
    }
    memcpy(snapshot, gActiveKeyCodes, count * sizeof(snapshot[0]));

    for (unsigned int i = 0; i < count; i++) {
        unsigned short keyCode = snapshot[i];
        if (!gPressedKeys[keyCode] || gSuppressedKeys[keyCode]) {
            continue;
        }

        BridgeSuppressKeyForUI(keyCode, reason, false);
    }
    BridgeSuppressPhysicallyDownKeysForUI(reason);
}

void BridgeInvalidateSprintGameLatch(const char *reason) {
    if (!gBridgeSprintToggleHeldInGame) {
        return;
    }

    gBridgeSprintToggleHeldInGame = false;
    BridgeLog("sprint game latch invalidated keyCode=%u desired=%d reason=%s",
              gBridgeSprintKeyCode,
              gBridgeSprintToggleDesired ? 1 : 0,
              reason == NULL ? "<nil>" : reason);
    SendKeyCode(gBridgeSprintKeyCode, NO);
    BridgeHUDRefresh();
}

void BridgeClearSprintToggleState(const char *reason) {
    gBridgeSprintToggleDesired = false;
    BridgeInvalidateSprintGameLatch(reason);
    BridgeHUDRefresh();
}

void BridgeApplySprintToggleIfNeeded(const char *reason) {
    if (!BridgeSprintCanApplyToGame(reason)) {
        return;
    }

    BridgeLog("sprint game latch applied keyCode=%u reason=%s",
              gBridgeSprintKeyCode,
              reason == NULL ? "<nil>" : reason);
    if (!SendKeyCode(gBridgeSprintKeyCode, YES)) {
        return;
    }
    gBridgeSprintToggleHeldInGame = true;
    BridgeHUDRefresh();
}

bool BridgeHandleSprintTogglePress(unsigned short keyCode) {
    if (gBridgeSprintMode != BridgeSprintModeToggle || keyCode != gBridgeSprintKeyCode) {
        return false;
    }

    gSuppressOriginalPressesBegan = true;
    SuppressKeyCodeUntilRelease(keyCode, false);
    if (gBridgeSprintToggleDesired) {
        BridgeClearSprintToggleState("sprint-toggle-off");
    } else {
        gBridgeSprintToggleDesired = true;
        BridgeLog("sprint toggle desired keyCode=%u", keyCode);
        BridgeApplySprintToggleIfNeeded("sprint-toggle-on");
        BridgeHUDRefresh();
    }
    return true;
}

void PollPhysicalKeys(void) {
    if (gActiveKeyCount == 0) {
        return;
    }

    if (!ResolveKeyStateFunction()) {
        if (!gKeyStateUnavailableLogged) {
            BridgeLog("physical key polling unavailable");
            gKeyStateUnavailableLogged = true;
        }
        return;
    }

    unsigned short snapshot[256];
    unsigned int count = gActiveKeyCount;
    if (count > (unsigned int)(sizeof(snapshot) / sizeof(snapshot[0]))) {
        count = (unsigned int)(sizeof(snapshot) / sizeof(snapshot[0]));
    }
    memcpy(snapshot, gActiveKeyCodes, count * sizeof(snapshot[0]));

    for (unsigned int i = 0; i < count; i++) {
        unsigned short keyCode = snapshot[i];
        if (!gPressedKeys[keyCode]) {
            continue;
        }

        unsigned short macKeyCode = 0;
        if (!MacKeyCodeForHIDUsage(keyCode, &macKeyCode)) {
            if (!gMissingMacKeyLogged[keyCode]) {
                BridgeLog("no mac key mapping keyCode=%u", keyCode);
                gMissingMacKeyLogged[keyCode] = true;
            }
            continue;
        }

        bool physicallyDown = gCGEventSourceKeyState(1, macKeyCode);
        if (!physicallyDown) {
            BridgeLog("physical release keyCode=%u macKeyCode=%u", keyCode, macKeyCode);
            ReleaseKeyCode(keyCode, "physical");
        }
    }
}

void StartKeyPollerIfNeeded(void) {
    if (gPollTimer != nil) {
        return;
    }

    gPollTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(gPollTimer, dispatch_time(DISPATCH_TIME_NOW, 0), 10 * NSEC_PER_MSEC, 2 * NSEC_PER_MSEC);
    dispatch_source_set_event_handler(gPollTimer, ^{
        PollPhysicalKeys();
    });
    dispatch_resume(gPollTimer);
    BridgeLog("started physical key poller");
}
void PressKeyCode(unsigned short keyCode) {
    if (gPressedKeys[keyCode]) {
        if (gSuppressedKeys[keyCode]) {
            gSuppressOriginalPressesBegan = true;
        }
        BridgeTraceLog("skip duplicate key down keyCode=%u", keyCode);
        return;
    }

    if (gBridgeHUDEditorActive) {
        gSuppressOriginalPressesBegan = true;
        SuppressKeyCodeUntilRelease(keyCode, false);
        BridgeHUDEditorHandleKeyDown(keyCode);
        return;
    }

    if (gBridgeMenuVisible) {
        gSuppressOriginalPressesBegan = true;
        SuppressKeyCodeUntilRelease(keyCode, true);
        if (BridgeMenuHandleCapturedKey(keyCode)) {
            return;
        }
        if (keyCode == 0x29) {
            HideBridgeMenu("escape");
            return;
        }
        if (IsBridgeMenuChordKey(keyCode)) {
            ToggleBridgeMenuFromHotkey();
        } else {
            BridgeTraceLog("bridge menu consumed keyCode=%u", keyCode);
        }
        return;
    }

    if (BridgeHandleSprintTogglePress(keyCode)) {
        return;
    }

    if (keyCode == kBridgeMenuKeyM) {
        gSuppressOriginalPressesBegan = true;
        SuppressKeyCodeUntilRelease(keyCode, false);
        ToggleBridgeMenuFromHotkey();
        return;
    }

    if (keyCode == 0x08 || keyCode == 0x29) {
        BridgeInvalidateSprintGameLatch("game-ui-toggle");
        if (gPointerLockWanted || CurrentPlatformPointerLocked()) {
            BridgeLog("clearing pointer lock for UI toggle keyCode=%u inhibit=1", keyCode);
            gPointerLockInhibited = true;
            gPointerLockReleaseKeyCode = keyCode;
            ClearPointerLockIfNeeded();
        } else if (gPointerLockInhibited) {
            BridgeLog("UI toggle keyCode=%u while inhibited; mouse-look gate decides rearm", keyCode);
        } else {
            BridgeLog("UI toggle keyCode=%u without active pointer lock", keyCode);
        }
    } else if (gPointerLockInhibited && IsGameplayRearmKey(keyCode)) {
        BridgeLog("gameplay keyCode=%u while inhibited; mouse-look gate decides rearm", keyCode);
    }

    gPressedKeys[keyCode] = true;
    AddActiveKeyCode(keyCode);
    StartKeyPollerIfNeeded();
    SendKeyCode(keyCode, YES);
    if (keyCode == gBridgeSprintKeyCode) {
        BridgeHUDRefresh();
    }

    if (IsFunctionKey(keyCode)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 250 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
            if (gPressedKeys[keyCode]) {
                BridgeLog("fallback release function keyCode=%u", keyCode);
                ReleaseKeyCode(keyCode, "function-fallback");
            }
        });
    }
}

void ReleaseAllKeys(void) {
    BridgeClearSprintToggleState("release-all");

    if (gKeyChangedHandler == nil) {
        memset(gPressedKeys, 0, sizeof(gPressedKeys));
        memset(gSuppressedKeys, 0, sizeof(gSuppressedKeys));
        memset(gMenuSuppressedKeys, 0, sizeof(gMenuSuppressedKeys));
        gActiveKeyCount = 0;
        return;
    }

    while (gActiveKeyCount > 0) {
        unsigned short keyCode = gActiveKeyCodes[gActiveKeyCount - 1];
        ReleaseKeyCode(keyCode, "release-all");
    }
}

bool PressSetContainsSuppressedKey(id presses) {
    id allObjects = ObjectValue(presses, "allObjects");
    unsigned long count = ULongValue(allObjects, "count");
    for (unsigned long i = 0; i < count; i++) {
        id press = ((id (*)(id, SEL, unsigned long))objc_msgSend)(allObjects, @selector(objectAtIndex:), i);
        id key = ObjectValue(press, "key");
        unsigned long rawKeyCode = ULongValue(key, "keyCode");
        if (rawKeyCode == 0 || rawKeyCode > UINT16_MAX) {
            continue;
        }
        if (gSuppressedKeys[(unsigned short)rawKeyCode]) {
            return true;
        }
    }
    return false;
}

void EmitPressSet(id controller, id presses, BOOL pressed) {
    if (!IsTargetController(controller)) {
        return;
    }

    EnsureMouseConnected(controller);
    EnsureKeyboardConnected(controller);
    if (gKeyChangedHandler == nil) {
        BridgeLog("keyChangedHandler unavailable");
        return;
    }

    id allObjects = ObjectValue(presses, "allObjects");
    unsigned long count = ULongValue(allObjects, "count");
    for (unsigned long i = 0; i < count; i++) {
        id press = ((id (*)(id, SEL, unsigned long))objc_msgSend)(allObjects, @selector(objectAtIndex:), i);
        id key = ObjectValue(press, "key");
        unsigned long rawKeyCode = ULongValue(key, "keyCode");
        if (rawKeyCode == 0 || rawKeyCode > UINT16_MAX) {
            continue;
        }

        unsigned short keyCode = (unsigned short)rawKeyCode;
        if (pressed) {
            PressKeyCode(keyCode);
        } else {
            ReleaseKeyCode(keyCode, "pressesEnded");
        }
    }
}

void ReplacementPressesBegan(id self, SEL _cmd, id presses, id event) {
    /*
     * PlayCover can route pressesCancelled: synchronously from Minecraft's
     * original pressesBegan: path. Emit key-down first so cancellation cannot
     * be processed as a release before the key was marked pressed.
     */
    gSuppressOriginalPressesBegan = false;
    EmitPressSet(self, presses, YES);

    IMP original = OriginalFor(self, _cmd);
    if (original != NULL && !gSuppressOriginalPressesBegan) {
        ((void (*)(id, SEL, id, id))original)(self, _cmd, presses, event);
    } else if (gSuppressOriginalPressesBegan) {
        BridgeTraceLog("suppressed original pressesBegan while bridge menu handled key input");
    }
    gSuppressOriginalPressesBegan = false;
}

void ReplacementPressesEnded(id self, SEL _cmd, id presses, id event) {
    IMP original = OriginalFor(self, _cmd);
    bool suppressOriginal = IsTargetController(self) && PressSetContainsSuppressedKey(presses);
    if (original != NULL && !suppressOriginal) {
        ((void (*)(id, SEL, id, id))original)(self, _cmd, presses, event);
    } else if (suppressOriginal) {
        BridgeTraceLog("suppressed original pressesEnded for bridge menu key input");
    }
    EmitPressSet(self, presses, NO);
}

void ReplacementPressesCancelled(id self, SEL _cmd, id presses, id event) {
    IMP original = OriginalFor(self, _cmd);
    bool suppressOriginal = IsTargetController(self) && PressSetContainsSuppressedKey(presses);
    if (original != NULL && !suppressOriginal) {
        ((void (*)(id, SEL, id, id))original)(self, _cmd, presses, event);
    } else if (suppressOriginal) {
        BridgeTraceLog("suppressed original pressesCancelled for bridge menu key input");
    }
    if (IsTargetController(self)) {
        BridgeLog("ignored pressesCancelled");
    }
}

void ReplacementSetKeyChangedHandler(id self, SEL _cmd, id block) {
    gKeyboardInput = self;
    void (^originalBlock)(id keyboardInput, id key, unsigned short keyCode, BOOL pressed) = block == nil ? nil : [block copy];
    gKeyChangedHandler = originalBlock;
    BridgeLog("captured keyChangedHandler input=%p block=%p", (__bridge void *)self, (__bridge void *)block);

    id replacement = nil;
    if (originalBlock != nil) {
        replacement = [^void(id keyboardInput, id key, unsigned short keyCode, BOOL pressed) {
            if (keyCode == 0 || keyCode > UINT16_MAX) {
                originalBlock(keyboardInput, key, keyCode, pressed);
                return;
            }

            gKeyboardInput = keyboardInput;
            if (!gNativeKeyChangedMediatedLogged) {
                BridgeLog("native keyChanged mediated input=%p keyCode=%u pressed=%d menu=%d hudEditor=%d",
                          (__bridge void *)keyboardInput,
                          keyCode,
                          pressed ? 1 : 0,
                          gBridgeMenuVisible ? 1 : 0,
                          gBridgeHUDEditorActive ? 1 : 0);
                gNativeKeyChangedMediatedLogged = true;
            }
            if (gBridgeMenuVisible || gBridgeHUDEditorActive || gSuppressedKeys[keyCode]) {
                BridgeLog("native keyChanged routed through bridge ui keyCode=%u pressed=%d menu=%d hudEditor=%d suppressed=%d",
                          keyCode,
                          pressed ? 1 : 0,
                          gBridgeMenuVisible ? 1 : 0,
                          gBridgeHUDEditorActive ? 1 : 0,
                          gSuppressedKeys[keyCode] ? 1 : 0);
            }

            if (pressed) {
                PressKeyCode(keyCode);
            } else {
                ReleaseKeyCode(keyCode, "native-keyChanged");
            }
        } copy];
    }

    IMP original = OriginalFor(self, _cmd);
    if (original != NULL) {
        ((void (*)(id, SEL, id))original)(self, _cmd, replacement);
    }
}
