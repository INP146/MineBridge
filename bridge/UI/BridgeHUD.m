#import "../BridgeInternal.h"

static const char *kBridgeHUDSprintBase64 = "iVBORw0KGgoAAAANSUhEUgAAABYAAAAWCAYAAADEtGw7AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAADOSURBVEhLvZXtDYMgEIa5pkMwlt3CMRyDGeyPuk3jBhBTV6C9E1r50KicfX54xyU8eYNBwVorAMAKRj5OAKy4qOsaSzFKKaoXfHBJEe+ixHOxlNJ1+9Bau25KTYk9R6VIvDcQc3J1NaFpGtf9+txsiU2Jc5LD4ngjrnOzJVYTl8hPe3n/T1wiRTYdRU6wJkWCK11y8xB/rZMrzUkgnn9I9hLvTb5uHHyPQmtDAw7a9k6VElfVTRgz0KCUvn+KcXxNibvuQUMOUIqc9DO18AZc1WQdjvTPDgAAAABJRU5ErkJggq5CYIIY9LrovOfskvxtnd8aY0jyr65+cLRujrL+fJOPAaJMN46HP07L/I9c3n9ESitLhsbMMowoH/3cozJTep8My+2KiwA8gRAju39mJaqaAEeXWxfxIbJZCwbFGkMgYDWx692ANTNbFaEbegDqusY5t5Rc2yvHCLx/nlERinw1OT3GyxoDMRmWr+w0pjpOimoCGftl0CmX/eBQEYzowsBjm873/ZmqqubYiCxTv1kLyNz4Mbw+htmcKGzvMo6fcVI1mdK2LSFAvrJzL2Pgv1Pq7TgxaWEkpuHSkvyi4nw+471Py+E6UwnUYUTZrJOTY7CNKLkJ+BhQETbrq7WVZdR1fZvDfnBzHi9OXme0yIvbVXOZ5bZtbwHHOR5dve4ZQNd3vP+I028AJKKaoDKA7XbL4+Pj999t46qqcM5N6+54PHJ/f0/XdYQQZsCu6zgcDpNTY9CtTSY55xabelwmRVHw+vq6eKj87ZfU/8fHSrLxG7/VAAAAAElFTkSuQmCC";
static const char *kBridgeHUDSprintDisabledBase64 = "iVBORw0KGgoAAAANSUhEUgAAABYAAAAWCAYAAADEtGw7AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAADgSURBVEhLvZXRCYMwEIZj6QZZRl/sDNkh4EwFd3ACC/UlaxTfI60LWO40JcaLBBP7gZ4c5vMnITGbpokVRXFnCVFKVVme5ygVQmAzlqZpsF7glkoKGBeKbTjnhy6XlZh6IRR37CZxKq5L3VDX9fLEmJQSK9XzEZTYFhqono1X7CYCEdXzsZs4Rn7a4u2K3TSQlupReMUxUiBoKijBnhTAQ8js75idB2itscJB9J/FM188gjt2NRWp+E2F1gM2UtC2D6yYuCxvbBje2Iil719sHD9z4q57YjMFIAVO+pmq6guVF2FFm6El4gAAAABJRU5ErkJggkjyr65+cLRujrL+fJOPAaJMN46HP07L/I9c3n9ESitLhsbMMowoH/3cozJTep8My+2KiwA8gRAju39mJaqaAEeXWxfxIbJZCwbFGkMgYDWx692ANTNbFaEbegDqusY5t5Rc2yvHCLx/nlERinw1OT3GyxoDMRmWr+w0pjpOimoCGftl0CmX/eBQEYzowsBjm873/ZmqqubYiCxTv1kLyNz4Mbw+htmcKGzvMo6fcVI1mdK2LSFAvrJzL2Pgv1Pq7TgxaWEkpuHSkvyi4nw+471Py+E6UwnUYUTZrJOTY7CNKLkJ+BhQETbrq7WVZdR1fZvDfnBzHi9OXme0yIvbVXOZ5bZtbwHHOR5dve4ZQNd3vP+I028AJKKaoDKA7XbL4+Pj999t46qqcM5N6+54PHJ/f0/XdYQQZsCu6zgcDpNTY9CtTSY55xabelwmRVHw+vq6eKj87ZfU/8fHSrLxG7/VAAAAAElFTkSuQmCC";
static const char *kBridgeHUDSprintPressedBase64 = "iVBORw0KGgoAAAANSUhEUgAAABYAAAAWCAYAAADEtGw7AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAADOSURBVEhLtZXbDcMgDEVx1WFYIVIHyQR8pBsxAd2jUlZgG1q7EPEwKClwPmJiKUdXRAZwzokZkBgAhtq/TgCs+GKMwdLNuq5Ub/gYJUWCixLHYmutX11DSulXv9SUOPCvFMm/TcQjuftaoJTyKyG01lS5Xo1TiWNhgOvFVMV5IhRxvRrNxD3yaT+vKc7TYFqux1EV90iRU1vBCVpSJBnpnslDwlgXIz2SRBwfJFfJvy1OtxEcW2HMixoj2LYn1eMGWZYHlm72/U110p3n4APUi1xBJ/2pfQAAAABJRU5ErkJggmCCAAAAAElFTkSuQmCCnd8aY0jyr65+cLRujrL+fJOPAaJMN46HP07L/I9c3n9ESitLhsbMMowoH/3cozJTep8My+2KiwA8gRAju39mJaqaAEeXWxfxIbJZCwbFGkMgYDWx692ANTNbFaEbegDqusY5t5Rc2yvHCLx/nlERinw1OT3GyxoDMRmWr+w0pjpOimoCGftl0CmX/eBQEYzowsBjm873/ZmqqubYiCxTv1kLyNz4Mbw+htmcKGzvMo6fcVI1mdK2LSFAvrJzL2Pgv1Pq7TgxaWEkpuHSkvyi4nw+471Py+E6UwnUYUTZrJOTY7CNKLkJ+BhQETbrq7WVZdR1fZvDfnBzHi9OXme0yIvbVXOZ5bZtbwHHOR5dve4ZQNd3vP+I028AJKKaoDKA7XbL4+Pj999t46qqcM5N6+54PHJ/f0/XdYQQZsCu6zgcDpNTY9CtTSY55xabelwmRVHw+vq6eKj87ZfU/8fHSrLxG7/VAAAAAElFTkSuQmCC";

typedef enum {
    BridgeHUDSprintStateDisabled = 0,
    BridgeHUDSprintStatePressed = 1,
    BridgeHUDSprintStateSprint = 2,
} BridgeHUDSprintState;

static id gBridgeHUDLayerView = nil;
static id gBridgeHUDSprintImageView = nil;
static BridgeHUDSprintState gBridgeHUDLastSprintState = -1;
static id gBridgeHUDSprintImage = nil;
static id gBridgeHUDSprintDisabledImage = nil;
static id gBridgeHUDSprintPressedImage = nil;
static id gBridgeHUDEditorHintView = nil;
static id gBridgeHUDEditorHintLabel = nil;
static dispatch_source_t gBridgeHUDEditorRepeatTimer = nil;
static unsigned short gBridgeHUDEditorRepeatKeyCode = 0;
static bool gBridgeHUDParameterPromptActive = false;
static bool gBridgeHUDEditorReturnToMenuOnEnd = false;
static bool gBridgeHUDEditorRestoreMouseLookOnEnd = false;

static void BridgeHUDEditorStopRepeat(bool persist);

static id BridgeHUDImageFromBase64(const char *base64) {
    id string = BridgeString(base64);
    Class dataClass = objc_getClass("NSData");
    Class imageClass = objc_getClass("UIImage");
    if (string == nil || dataClass == Nil || imageClass == Nil) {
        return nil;
    }

    id data = ((id (*)(id, SEL))objc_msgSend)((id)dataClass, sel_registerName("alloc"));
    if (data == nil) {
        return nil;
    }
    data = ((id (*)(id, SEL, id, unsigned long))objc_msgSend)(data,
                                                              sel_registerName("initWithBase64EncodedString:options:"),
                                                              string,
                                                              1UL);
    if (data == nil) {
        return nil;
    }

    SEL imageSel = sel_registerName("imageWithData:");
    if (!RespondsTo((id)imageClass, imageSel)) {
        return nil;
    }
    return ((id (*)(id, SEL, id))objc_msgSend)((id)imageClass, imageSel, data);
}

static id BridgeHUDImageForSprintState(BridgeHUDSprintState state) {
    if (gBridgeHUDSprintImage == nil) {
        gBridgeHUDSprintImage = BridgeHUDImageFromBase64(kBridgeHUDSprintBase64);
    }
    if (gBridgeHUDSprintDisabledImage == nil) {
        gBridgeHUDSprintDisabledImage = BridgeHUDImageFromBase64(kBridgeHUDSprintDisabledBase64);
    }
    if (gBridgeHUDSprintPressedImage == nil) {
        gBridgeHUDSprintPressedImage = BridgeHUDImageFromBase64(kBridgeHUDSprintPressedBase64);
    }

    switch (state) {
        case BridgeHUDSprintStateDisabled: return gBridgeHUDSprintDisabledImage;
        case BridgeHUDSprintStatePressed: return gBridgeHUDSprintPressedImage;
        case BridgeHUDSprintStateSprint:
        default: return gBridgeHUDSprintImage;
    }
}

static BridgeHUDSprintState BridgeHUDCurrentSprintState(void) {
    if (gBridgeSprintMode == BridgeSprintModeToggle) {
        return gBridgeSprintToggleDesired ? BridgeHUDSprintStatePressed : BridgeHUDSprintStateDisabled;
    }
    return gPressedKeys[gBridgeSprintKeyCode] ? BridgeHUDSprintStatePressed : BridgeHUDSprintStateSprint;
}

static bool BridgeHUDEditorKeyIsRepeatable(unsigned short keyCode) {
    switch (keyCode) {
        case 0x4F:
        case 0x50:
        case 0x51:
        case 0x52:
        case 0x2E:
        case 0x2D:
        case 0x37:
        case 0x36:
            return true;
        default:
            return false;
    }
}

static void BridgeHUDEditorClampSprintLayout(void) {
    if (gBridgeHUDSprintSize < 18.0) {
        gBridgeHUDSprintSize = 18.0;
    }
    if (gBridgeHUDSprintSize > 120.0) {
        gBridgeHUDSprintSize = 120.0;
    }
    if (gBridgeHUDSprintAlpha < 0.15) {
        gBridgeHUDSprintAlpha = 0.15;
    }
    if (gBridgeHUDSprintAlpha > 1.0) {
        gBridgeHUDSprintAlpha = 1.0;
    }

    id window = KeyWindow();
    if (window != nil && RespondsTo(window, sel_registerName("bounds"))) {
        BridgeCGRect bounds = ((BridgeCGRect (*)(id, SEL))objc_msgSend)(window, sel_registerName("bounds"));
        if (gBridgeHUDSprintSize > bounds.size.width) {
            gBridgeHUDSprintSize = bounds.size.width;
        }
        if (gBridgeHUDSprintSize > bounds.size.height) {
            gBridgeHUDSprintSize = bounds.size.height;
        }
        if (gBridgeHUDSprintX > bounds.size.width - gBridgeHUDSprintSize) {
            gBridgeHUDSprintX = bounds.size.width - gBridgeHUDSprintSize;
        }
        if (gBridgeHUDSprintY > bounds.size.height - gBridgeHUDSprintSize) {
            gBridgeHUDSprintY = bounds.size.height - gBridgeHUDSprintSize;
        }
    }

    if (gBridgeHUDSprintX < 0.0) {
        gBridgeHUDSprintX = 0.0;
    }
    if (gBridgeHUDSprintY < 0.0) {
        gBridgeHUDSprintY = 0.0;
    }
}

static void BridgeHUDEditorPersistSprintLayout(void) {
    BridgeHUDEditorClampSprintLayout();
    BridgeSettingsSaveHUDSprintLayout(gBridgeHUDSprintX,
                                      gBridgeHUDSprintY,
                                      gBridgeHUDSprintSize,
                                      gBridgeHUDSprintAlpha);
}

static void BridgeHUDEditorRemoveHint(void) {
    if (gBridgeHUDEditorHintView != nil && RespondsTo(gBridgeHUDEditorHintView, sel_registerName("removeFromSuperview"))) {
        ((void (*)(id, SEL))objc_msgSend)(gBridgeHUDEditorHintView, sel_registerName("removeFromSuperview"));
    }
    gBridgeHUDEditorHintView = nil;
    gBridgeHUDEditorHintLabel = nil;
}

static NSString *BridgeHUDEditorHintText(void) {
    if (gBridgeHUDSelectedElement == BridgeHUDElementSprintStatus) {
        return [NSString stringWithFormat:@"HUD 设置\n已选：疾跑显示\n位置：x %.0f  y %.0f    大小：%.0f    透明：%.0f%%\n方向键移动，长按连续调整\n双击元素直接输入参数\n-/= 大小，,/. 透明，R 重置，Esc 完成",
                gBridgeHUDSprintX,
                gBridgeHUDSprintY,
                gBridgeHUDSprintSize,
                gBridgeHUDSprintAlpha * 100.0];
    }

    return @"HUD 设置\n点击 HUD 元素选中后调整\n双击元素直接输入参数\n方向键移动，长按连续调整\n-/= 大小，,/. 透明，R 重置，Esc 完成";
}

static void BridgeHUDEditorUpdateHint(void) {
    if (!gBridgeHUDEditorActive) {
        BridgeHUDEditorRemoveHint();
        return;
    }

    id window = KeyWindow();
    if (window == nil || !RespondsTo(window, sel_registerName("bounds"))) {
        BridgeHUDEditorRemoveHint();
        return;
    }

    BridgeCGRect bounds = ((BridgeCGRect (*)(id, SEL))objc_msgSend)(window, sel_registerName("bounds"));
    double hintWidth = bounds.size.width - 32.0;
    if (hintWidth > 420.0) {
        hintWidth = 420.0;
    }
    if (hintWidth < 220.0) {
        hintWidth = bounds.size.width > 24.0 ? bounds.size.width - 24.0 : bounds.size.width;
    }

    double hintHeight = gBridgeHUDSelectedElement == BridgeHUDElementSprintStatus ? 136.0 : 112.0;
    double hintX = 16.0;
    double hintY = bounds.size.height - hintHeight - 18.0;
    if (hintY < 12.0) {
        hintY = 12.0;
    }
    BridgeCGRect hintFrame = { { hintX, hintY }, { hintWidth, hintHeight } };

    if (gBridgeHUDEditorHintView == nil) {
        gBridgeHUDEditorHintView = BridgeViewWithFrame(hintFrame);
        if (gBridgeHUDEditorHintView == nil) {
            return;
        }

        id backgroundColor = BridgeColorWithWhiteAlpha(0.0, 0.58);
        if (backgroundColor != nil) {
            ((void (*)(id, SEL, id))objc_msgSend)(gBridgeHUDEditorHintView, sel_registerName("setBackgroundColor:"), backgroundColor);
        }
        ((void (*)(id, SEL, BOOL))objc_msgSend)(gBridgeHUDEditorHintView, sel_registerName("setUserInteractionEnabled:"), NO);
        ((void (*)(id, SEL, unsigned long))objc_msgSend)(gBridgeHUDEditorHintView, sel_registerName("setAutoresizingMask:"), 10UL);

        id hintLayer = ObjectValue(gBridgeHUDEditorHintView, "layer");
        if (hintLayer != nil) {
            ((void (*)(id, SEL, double))objc_msgSend)(hintLayer, sel_registerName("setCornerRadius:"), 12.0);
            ((void (*)(id, SEL, BOOL))objc_msgSend)(hintLayer, sel_registerName("setMasksToBounds:"), YES);
        }

        BridgeCGRect labelFrame = { { 12.0, 10.0 }, { hintWidth - 24.0, hintHeight - 20.0 } };
        gBridgeHUDEditorHintLabel = BridgeLabelWithFrame(labelFrame,
                                                         "",
                                                         12.0,
                                                         false,
                                                         BridgeColorWithWhiteAlpha(1.0, 0.94),
                                                         0,
                                                         0);
        if (gBridgeHUDEditorHintLabel != nil) {
            ((void (*)(id, SEL, id))objc_msgSend)(gBridgeHUDEditorHintView, sel_registerName("addSubview:"), gBridgeHUDEditorHintLabel);
        }
        ((void (*)(id, SEL, id))objc_msgSend)(window, sel_registerName("addSubview:"), gBridgeHUDEditorHintView);
    } else {
        id superview = ObjectValue(gBridgeHUDEditorHintView, "superview");
        if (superview != window) {
            BridgeHUDEditorRemoveHint();
            BridgeHUDEditorUpdateHint();
            return;
        }
        ((void (*)(id, SEL, BridgeCGRect))objc_msgSend)(gBridgeHUDEditorHintView, sel_registerName("setFrame:"), hintFrame);
    }

    if (gBridgeHUDEditorHintLabel != nil) {
        BridgeCGRect labelFrame = { { 12.0, 10.0 }, { hintWidth - 24.0, hintHeight - 20.0 } };
        ((void (*)(id, SEL, BridgeCGRect))objc_msgSend)(gBridgeHUDEditorHintLabel, sel_registerName("setFrame:"), labelFrame);
        ((void (*)(id, SEL, id))objc_msgSend)(gBridgeHUDEditorHintLabel, sel_registerName("setText:"), BridgeHUDEditorHintText());
    }
    if (RespondsTo(window, sel_registerName("bringSubviewToFront:"))) {
        ((void (*)(id, SEL, id))objc_msgSend)(window, sel_registerName("bringSubviewToFront:"), gBridgeHUDEditorHintView);
    }
}

static void BridgeHUDRefreshSelectionChrome(void) {
    if (gBridgeHUDLayerView == nil) {
        return;
    }

    ((void (*)(id, SEL, BOOL))objc_msgSend)(gBridgeHUDLayerView,
                                            sel_registerName("setUserInteractionEnabled:"),
                                            gBridgeHUDEditorActive ? YES : NO);

    id layer = ObjectValue(gBridgeHUDLayerView, "layer");
    if (layer == nil) {
        return;
    }

    if (!gBridgeHUDEditorActive) {
        ((void (*)(id, SEL, double))objc_msgSend)(layer, sel_registerName("setBorderWidth:"), 0.0);
        return;
    }

    bool selected = gBridgeHUDSelectedElement == BridgeHUDElementSprintStatus;
    id borderColor = selected ? BridgeColorWithRedGreenBlueAlpha(0.21, 0.64, 1.0, 1.0)
                              : BridgeColorWithWhiteAlpha(1.0, 0.34);
    void *cgColor = borderColor == nil ? NULL : PointerValue(borderColor, "CGColor");
    if (cgColor != NULL) {
        ((void (*)(id, SEL, void *))objc_msgSend)(layer, sel_registerName("setBorderColor:"), cgColor);
    }
    ((void (*)(id, SEL, double))objc_msgSend)(layer, sel_registerName("setBorderWidth:"), selected ? 2.0 : 1.0);
    ((void (*)(id, SEL, double))objc_msgSend)(layer, sel_registerName("setCornerRadius:"), gBridgeHUDSprintSize * 0.18);
}

static double BridgeHUDTextFieldDoubleValue(id textField, double fallback) {
    id text = ObjectValue(textField, "text");
    if (text == nil || ULongValue(text, "length") == 0 || !RespondsTo(text, sel_registerName("doubleValue"))) {
        return fallback;
    }
    return ((double (*)(id, SEL))objc_msgSend)(text, sel_registerName("doubleValue"));
}

static id BridgeHUDTopViewController(void) {
    id controller = KeyWindowRootViewController();
    while (controller != nil) {
        id presented = ObjectValue(controller, "presentedViewController");
        if (presented == nil) {
            break;
        }
        controller = presented;
    }
    return controller;
}

static void BridgeHUDConfigureTextField(id textField, NSString *placeholder, NSString *text) {
    if (textField == nil) {
        return;
    }
    if (placeholder != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(textField, sel_registerName("setPlaceholder:"), placeholder);
    }
    if (text != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(textField, sel_registerName("setText:"), text);
    }
    if (RespondsTo(textField, sel_registerName("setKeyboardType:"))) {
        ((void (*)(id, SEL, long))objc_msgSend)(textField, sel_registerName("setKeyboardType:"), 8L);
    }
    if (RespondsTo(textField, sel_registerName("setClearButtonMode:"))) {
        ((void (*)(id, SEL, long))objc_msgSend)(textField, sel_registerName("setClearButtonMode:"), 1L);
    }
}

static void BridgeHUDEditorShowSprintParameterPrompt(void) {
    if (!gBridgeHUDEditorActive || gBridgeHUDParameterPromptActive) {
        return;
    }

    Class alertClass = objc_getClass("UIAlertController");
    Class actionClass = objc_getClass("UIAlertAction");
    if (alertClass == Nil || actionClass == Nil) {
        BridgeLog("hud editor parameter prompt unavailable alert=%p action=%p", alertClass, actionClass);
        return;
    }

    id presenter = BridgeHUDTopViewController();
    if (presenter == nil || !RespondsTo(presenter, sel_registerName("presentViewController:animated:completion:"))) {
        BridgeLog("hud editor parameter prompt skipped presenter=%p", (__bridge void *)presenter);
        return;
    }

    gBridgeHUDParameterPromptActive = true;
    gBridgeHUDSelectedElement = BridgeHUDElementSprintStatus;
    BridgeHUDRefreshSelectionChrome();
    BridgeHUDEditorUpdateHint();

    id alert = ((id (*)(id, SEL, id, id, long))objc_msgSend)((id)alertClass,
                                                              sel_registerName("alertControllerWithTitle:message:preferredStyle:"),
                                                              @"疾跑显示",
                                                              @"输入 HUD 参数。透明度可填 50 或 0.5。",
                                                              1L);
    if (alert == nil) {
        gBridgeHUDParameterPromptActive = false;
        return;
    }

    __block id xField = nil;
    __block id yField = nil;
    __block id sizeField = nil;
    __block id alphaField = nil;

    void (^xConfig)(id) = ^(id textField) {
        xField = textField;
        BridgeHUDConfigureTextField(textField, @"x", [NSString stringWithFormat:@"%.0f", gBridgeHUDSprintX]);
    };
    void (^yConfig)(id) = ^(id textField) {
        yField = textField;
        BridgeHUDConfigureTextField(textField, @"y", [NSString stringWithFormat:@"%.0f", gBridgeHUDSprintY]);
    };
    void (^sizeConfig)(id) = ^(id textField) {
        sizeField = textField;
        BridgeHUDConfigureTextField(textField, @"大小", [NSString stringWithFormat:@"%.0f", gBridgeHUDSprintSize]);
    };
    void (^alphaConfig)(id) = ^(id textField) {
        alphaField = textField;
        BridgeHUDConfigureTextField(textField, @"透明度 0-100 或 0-1", [NSString stringWithFormat:@"%.0f", gBridgeHUDSprintAlpha * 100.0]);
    };

    SEL addTextFieldSel = sel_registerName("addTextFieldWithConfigurationHandler:");
    if (RespondsTo(alert, addTextFieldSel)) {
        ((void (*)(id, SEL, id))objc_msgSend)(alert, addTextFieldSel, xConfig);
        ((void (*)(id, SEL, id))objc_msgSend)(alert, addTextFieldSel, yConfig);
        ((void (*)(id, SEL, id))objc_msgSend)(alert, addTextFieldSel, sizeConfig);
        ((void (*)(id, SEL, id))objc_msgSend)(alert, addTextFieldSel, alphaConfig);
    }

    id cancelAction = ((id (*)(id, SEL, id, long, id))objc_msgSend)((id)actionClass,
                                                                    sel_registerName("actionWithTitle:style:handler:"),
                                                                    @"取消",
                                                                    1L,
                                                                    ^(id action) {
                                                                        (void)action;
                                                                        gBridgeHUDParameterPromptActive = false;
                                                                        BridgeHUDEditorUpdateHint();
                                                                    });
    id saveAction = ((id (*)(id, SEL, id, long, id))objc_msgSend)((id)actionClass,
                                                                  sel_registerName("actionWithTitle:style:handler:"),
                                                                  @"保存",
                                                                  0L,
                                                                  ^(id action) {
                                                                      (void)action;
                                                                      double x = BridgeHUDTextFieldDoubleValue(xField, gBridgeHUDSprintX);
                                                                      double y = BridgeHUDTextFieldDoubleValue(yField, gBridgeHUDSprintY);
                                                                      double size = BridgeHUDTextFieldDoubleValue(sizeField, gBridgeHUDSprintSize);
                                                                      double alpha = BridgeHUDTextFieldDoubleValue(alphaField, gBridgeHUDSprintAlpha * 100.0);
                                                                      if (alpha > 1.0) {
                                                                          alpha *= 0.01;
                                                                      }

                                                                      gBridgeHUDSprintX = x;
                                                                      gBridgeHUDSprintY = y;
                                                                      gBridgeHUDSprintSize = size;
                                                                      gBridgeHUDSprintAlpha = alpha;
                                                                      BridgeHUDEditorPersistSprintLayout();
                                                                      BridgeHUDRefresh();
                                                                      gBridgeHUDParameterPromptActive = false;
                                                                      BridgeHUDEditorUpdateHint();
                                                                      BridgeLog("hud editor parameter prompt saved sprintStatus");
                                                                  });

    SEL addActionSel = sel_registerName("addAction:");
    if (RespondsTo(alert, addActionSel)) {
        if (cancelAction != nil) {
            ((void (*)(id, SEL, id))objc_msgSend)(alert, addActionSel, cancelAction);
        }
        if (saveAction != nil) {
            ((void (*)(id, SEL, id))objc_msgSend)(alert, addActionSel, saveAction);
        }
    }

    ((void (*)(id, SEL, id, BOOL, id))objc_msgSend)(presenter,
                                                    sel_registerName("presentViewController:animated:completion:"),
                                                    alert,
                                                    YES,
                                                    nil);
}

static id BridgeHUDActionTarget(void);

void BridgeHUDSprintTapped(id self, SEL _cmd, id sender) {
    (void)self;
    (void)_cmd;
    (void)sender;
    if (!gBridgeHUDEditorActive) {
        return;
    }
    gBridgeHUDSelectedElement = BridgeHUDElementSprintStatus;
    BridgeHUDRefreshSelectionChrome();
    BridgeHUDEditorUpdateHint();
    BridgeLog("hud editor selected element=sprintStatus");
}

void BridgeHUDSprintDoubleTapped(id self, SEL _cmd, id sender) {
    (void)self;
    (void)_cmd;
    (void)sender;
    if (!gBridgeHUDEditorActive) {
        return;
    }
    BridgeHUDEditorStopRepeat(true);
    gBridgeHUDSelectedElement = BridgeHUDElementSprintStatus;
    BridgeHUDEditorShowSprintParameterPrompt();
}

static id BridgeHUDActionTarget(void) {
    static id target = nil;
    if (target != nil) {
        return target;
    }

    Class cls = objc_getClass("BridgeHUDActionTarget");
    if (cls == Nil) {
        Class baseClass = objc_getClass("NSObject");
        cls = objc_allocateClassPair(baseClass, "BridgeHUDActionTarget", 0);
        if (cls != Nil) {
            class_addMethod(cls, sel_registerName("bridgeHUDSprintTapped:"), (IMP)BridgeHUDSprintTapped, "v@:@");
            class_addMethod(cls, sel_registerName("bridgeHUDSprintDoubleTapped:"), (IMP)BridgeHUDSprintDoubleTapped, "v@:@");
            objc_registerClassPair(cls);
        }
    }

    if (cls != Nil) {
        target = ((id (*)(id, SEL))objc_msgSend)((id)cls, sel_registerName("new"));
    }
    return target;
}

static void BridgeHUDInstallTapRecognizer(id view) {
    if (view == nil) {
        return;
    }

    Class tapClass = objc_getClass("UITapGestureRecognizer");
    id target = BridgeHUDActionTarget();
    if (tapClass == Nil || target == nil || !RespondsTo(view, sel_registerName("addGestureRecognizer:"))) {
        return;
    }

    id doubleTap = ((id (*)(id, SEL))objc_msgSend)((id)tapClass, sel_registerName("alloc"));
    if (doubleTap == nil) {
        return;
    }
    doubleTap = ((id (*)(id, SEL, id, SEL))objc_msgSend)(doubleTap,
                                                         sel_registerName("initWithTarget:action:"),
                                                         target,
                                                         sel_registerName("bridgeHUDSprintDoubleTapped:"));
    if (doubleTap != nil && RespondsTo(doubleTap, sel_registerName("setNumberOfTapsRequired:"))) {
        ((void (*)(id, SEL, unsigned long))objc_msgSend)(doubleTap, sel_registerName("setNumberOfTapsRequired:"), 2UL);
        ((void (*)(id, SEL, id))objc_msgSend)(view, sel_registerName("addGestureRecognizer:"), doubleTap);
    }

    id tap = ((id (*)(id, SEL))objc_msgSend)((id)tapClass, sel_registerName("alloc"));
    if (tap != nil) {
        tap = ((id (*)(id, SEL, id, SEL))objc_msgSend)(tap,
                                                       sel_registerName("initWithTarget:action:"),
                                                       target,
                                                       sel_registerName("bridgeHUDSprintTapped:"));
    }
    if (tap != nil) {
        if (doubleTap != nil && RespondsTo(tap, sel_registerName("requireGestureRecognizerToFail:"))) {
            ((void (*)(id, SEL, id))objc_msgSend)(tap, sel_registerName("requireGestureRecognizerToFail:"), doubleTap);
        }
        ((void (*)(id, SEL, id))objc_msgSend)(view, sel_registerName("addGestureRecognizer:"), tap);
    }
}

static void BridgeHUDEditorApplyKey(unsigned short keyCode, bool repeat) {
    if (gBridgeHUDSelectedElement != BridgeHUDElementSprintStatus) {
        BridgeHUDEditorUpdateHint();
        return;
    }

    double moveStep = repeat ? 4.0 : 2.0;
    double sizeStep = repeat ? 3.0 : 2.0;
    double alphaStep = repeat ? 0.03 : 0.05;
    switch (keyCode) {
        case 0x4F:
            gBridgeHUDSprintX += moveStep;
            break;
        case 0x50:
            gBridgeHUDSprintX -= moveStep;
            break;
        case 0x51:
            gBridgeHUDSprintY += moveStep;
            break;
        case 0x52:
            gBridgeHUDSprintY -= moveStep;
            break;
        case 0x2E:
            gBridgeHUDSprintSize += sizeStep;
            break;
        case 0x2D:
            gBridgeHUDSprintSize -= sizeStep;
            break;
        case 0x37:
            gBridgeHUDSprintAlpha += alphaStep;
            break;
        case 0x36:
            gBridgeHUDSprintAlpha -= alphaStep;
            break;
        default:
            return;
    }

    BridgeHUDEditorClampSprintLayout();
    BridgeHUDRefresh();
    BridgeHUDEditorUpdateHint();
}

static void BridgeHUDEditorStopRepeat(bool persist) {
    if (gBridgeHUDEditorRepeatTimer != nil) {
        dispatch_source_cancel(gBridgeHUDEditorRepeatTimer);
        gBridgeHUDEditorRepeatTimer = nil;
    }
    gBridgeHUDEditorRepeatKeyCode = 0;
    if (persist && gBridgeHUDSelectedElement == BridgeHUDElementSprintStatus) {
        BridgeHUDEditorPersistSprintLayout();
    }
}

static void BridgeHUDEditorStartRepeat(unsigned short keyCode) {
    BridgeHUDEditorStopRepeat(false);
    if (!BridgeHUDEditorKeyIsRepeatable(keyCode) || gBridgeHUDSelectedElement == BridgeHUDElementNone) {
        return;
    }

    gBridgeHUDEditorRepeatKeyCode = keyCode;
    gBridgeHUDEditorRepeatTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    if (gBridgeHUDEditorRepeatTimer == nil) {
        return;
    }
    dispatch_source_set_timer(gBridgeHUDEditorRepeatTimer,
                              dispatch_time(DISPATCH_TIME_NOW, 180 * NSEC_PER_MSEC),
                              35 * NSEC_PER_MSEC,
                              4 * NSEC_PER_MSEC);
    dispatch_source_set_event_handler(gBridgeHUDEditorRepeatTimer, ^{
        if (!gBridgeHUDEditorActive || gBridgeHUDEditorRepeatKeyCode == 0) {
            BridgeHUDEditorStopRepeat(true);
            return;
        }
        BridgeHUDEditorApplyKey(gBridgeHUDEditorRepeatKeyCode, true);
    });
    dispatch_resume(gBridgeHUDEditorRepeatTimer);
}

void BridgeHUDEditorBegin(bool returnToMenuOnEnd, bool restoreMouseLookOnEnd) {
    gBridgeHUDEditorActive = true;
    gBridgeHUDSelectedElement = BridgeHUDElementNone;
    gBridgeHUDEditorReturnToMenuOnEnd = returnToMenuOnEnd;
    gBridgeHUDEditorRestoreMouseLookOnEnd = restoreMouseLookOnEnd;

    BridgeSuppressActiveGameKeysForUI("hud-editor-begin");
    BridgeSuppressActiveMouseButtonsForUI("hud-editor-begin");

    if (!gBridgeHUDEnabled) {
        BridgeSettingsSaveHUDEnabled(true);
    }
    if (!gBridgeHUDSprintStatusEnabled) {
        BridgeSettingsSaveHUDSprintStatusEnabled(true);
    }

    gPointerLockInhibited = true;
    gPointerLockReleaseKeyCode = 0;
    gPointerLockRearmAllowedByToggle = false;
    gPointerLockRearmAllowedByMouseClick = false;
    gPointerLockWanted = false;
    if (CurrentPlatformPointerLocked() || gPointerCaptureActive) {
        ClearPointerLockIfNeeded();
    }
    SetPointerCaptureActive(false, "hud-editor-begin");
    SetNeedsPointerLockUpdateForVisibleChain();
    ReconcilePointerCapture(gLastController, "hud-editor-begin");

    BridgeHUDRefresh();
    BridgeHUDEditorUpdateHint();
    BridgeLog("hud editor shown returnToMenu=%d restoreMouseLook=%d",
              returnToMenuOnEnd ? 1 : 0,
              restoreMouseLookOnEnd ? 1 : 0);
}

void BridgeHUDEditorEnd(const char *reason) {
    if (!gBridgeHUDEditorActive) {
        return;
    }

    BridgeHUDEditorStopRepeat(true);
    gBridgeHUDEditorActive = false;
    gBridgeHUDSelectedElement = BridgeHUDElementNone;
    BridgeHUDEditorRemoveHint();

    bool returnToMenu = gBridgeHUDEditorReturnToMenuOnEnd;
    bool restoreMouseLook = gBridgeHUDEditorRestoreMouseLookOnEnd;
    gBridgeHUDEditorReturnToMenuOnEnd = false;
    gBridgeHUDEditorRestoreMouseLookOnEnd = false;
    gPointerLockInhibited = false;
    gPointerLockReleaseKeyCode = 0;
    gPointerLockRearmAllowedByToggle = false;
    gPointerLockRearmAllowedByMouseClick = false;
    if (returnToMenu) {
        ShowBridgeMenu("hud-editor-end");
        if (gBridgeMenuVisible) {
            gBridgeMenuRestoreMouseLookOnHide = restoreMouseLook;
        } else if (restoreMouseLook && !gTextInputActive) {
            UpdateMouseLookAllowed(true, "hud-editor-hidden-restore");
            if (!CurrentPlatformPointerLocked()) {
                SetPlatformPointerLocked(true, "hud-editor-hidden-restore");
            }
        }
    } else if (restoreMouseLook && !gTextInputActive) {
        UpdateMouseLookAllowed(true, "hud-editor-hidden-restore");
        if (!CurrentPlatformPointerLocked()) {
            SetPlatformPointerLocked(true, "hud-editor-hidden-restore");
        }
    }
    SetNeedsPointerLockUpdateForVisibleChain();
    ReconcilePointerCapture(gLastController, "hud-editor-end");
    BridgeHUDRefresh();
    BridgeLog("hud editor hidden reason=%s returnToMenu=%d restoreMouseLook=%d",
              reason == NULL ? "<nil>" : reason,
              returnToMenu ? 1 : 0,
              restoreMouseLook ? 1 : 0);
}

bool BridgeHUDEditorHandleKeyDown(unsigned short keyCode) {
    if (!gBridgeHUDEditorActive) {
        return false;
    }

    if (keyCode == 0x29) {
        BridgeHUDEditorEnd("escape");
        return true;
    }
    if (keyCode == kBridgeMenuKeyM) {
        BridgeHUDEditorUpdateHint();
        return true;
    }
    if (keyCode == 0x15) {
        if (gBridgeHUDSelectedElement == BridgeHUDElementSprintStatus) {
            BridgeSettingsResetHUDSprintLayout();
            BridgeHUDRefresh();
        }
        BridgeHUDEditorUpdateHint();
        return true;
    }

    if (BridgeHUDEditorKeyIsRepeatable(keyCode)) {
        BridgeHUDEditorApplyKey(keyCode, false);
        BridgeHUDEditorPersistSprintLayout();
        BridgeHUDEditorStartRepeat(keyCode);
    }
    return true;
}

void BridgeHUDEditorHandleKeyUp(unsigned short keyCode) {
    if (gBridgeHUDEditorRepeatKeyCode == keyCode) {
        BridgeHUDEditorStopRepeat(true);
    }
}

static void BridgeHUDRemove(void) {
    if (gBridgeHUDLayerView != nil && RespondsTo(gBridgeHUDLayerView, sel_registerName("removeFromSuperview"))) {
        ((void (*)(id, SEL))objc_msgSend)(gBridgeHUDLayerView, sel_registerName("removeFromSuperview"));
    }
    gBridgeHUDLayerView = nil;
    gBridgeHUDSprintImageView = nil;
    gBridgeHUDLastSprintState = -1;
}

static bool BridgeHUDEnsure(id window) {
    if (window == nil) {
        return false;
    }

    id superview = ObjectValue(gBridgeHUDLayerView, "superview");
    if (gBridgeHUDLayerView != nil && superview != nil && superview != window) {
        BridgeHUDRemove();
    }
    if (gBridgeHUDLayerView != nil && gBridgeHUDSprintImageView != nil) {
        BridgeCGRect hudFrame = { { gBridgeHUDSprintX, gBridgeHUDSprintY }, { gBridgeHUDSprintSize, gBridgeHUDSprintSize } };
        ((void (*)(id, SEL, BridgeCGRect))objc_msgSend)(gBridgeHUDLayerView, sel_registerName("setFrame:"), hudFrame);
        ((void (*)(id, SEL, double))objc_msgSend)(gBridgeHUDLayerView, sel_registerName("setAlpha:"), gBridgeHUDSprintAlpha);
        double inset = gBridgeHUDSprintSize * 0.1333333333;
        BridgeCGRect imageFrame = { { inset, inset }, { gBridgeHUDSprintSize - inset * 2.0, gBridgeHUDSprintSize - inset * 2.0 } };
        ((void (*)(id, SEL, BridgeCGRect))objc_msgSend)(gBridgeHUDSprintImageView, sel_registerName("setFrame:"), imageFrame);
        BridgeHUDRefreshSelectionChrome();
        return true;
    }

    BridgeCGRect hudFrame = { { gBridgeHUDSprintX, gBridgeHUDSprintY }, { gBridgeHUDSprintSize, gBridgeHUDSprintSize } };
    id layer = BridgeViewWithFrame(hudFrame);
    Class imageViewClass = objc_getClass("UIImageView");
    if (layer == nil || imageViewClass == Nil) {
        return false;
    }

    ((void (*)(id, SEL, BOOL))objc_msgSend)(layer,
                                            sel_registerName("setUserInteractionEnabled:"),
                                            gBridgeHUDEditorActive ? YES : NO);
    ((void (*)(id, SEL, unsigned long))objc_msgSend)(layer, sel_registerName("setAutoresizingMask:"), 36UL);
    ((void (*)(id, SEL, double))objc_msgSend)(layer, sel_registerName("setAlpha:"), gBridgeHUDSprintAlpha);

    double inset = gBridgeHUDSprintSize * 0.1333333333;
    BridgeCGRect imageFrame = { { inset, inset }, { gBridgeHUDSprintSize - inset * 2.0, gBridgeHUDSprintSize - inset * 2.0 } };
    id imageView = ((id (*)(id, SEL))objc_msgSend)((id)imageViewClass, sel_registerName("alloc"));
    if (imageView == nil) {
        return false;
    }
    imageView = ((id (*)(id, SEL, BridgeCGRect))objc_msgSend)(imageView, sel_registerName("initWithFrame:"), imageFrame);
    if (imageView == nil) {
        return false;
    }
    ((void (*)(id, SEL, long))objc_msgSend)(imageView, sel_registerName("setContentMode:"), 1L);
    ((void (*)(id, SEL, id))objc_msgSend)(layer, sel_registerName("addSubview:"), imageView);
    BridgeHUDInstallTapRecognizer(layer);
    ((void (*)(id, SEL, id))objc_msgSend)(window, sel_registerName("addSubview:"), layer);

    gBridgeHUDLayerView = layer;
    gBridgeHUDSprintImageView = imageView;
    BridgeHUDRefreshSelectionChrome();
    return true;
}

void BridgeHUDRefresh(void) {
    if (!gBridgeHUDEnabled || !gBridgeHUDSprintStatusEnabled || (gBridgeMenuVisible && !gBridgeHUDEditorActive)) {
        if (!gBridgeHUDEditorActive) {
            BridgeHUDEditorRemoveHint();
        }
        BridgeHUDRemove();
        return;
    }

    id window = KeyWindow();
    if (!BridgeHUDEnsure(window)) {
        return;
    }
    if (RespondsTo(window, sel_registerName("bringSubviewToFront:"))) {
        ((void (*)(id, SEL, id))objc_msgSend)(window, sel_registerName("bringSubviewToFront:"), gBridgeHUDLayerView);
    }

    BridgeHUDSprintState state = BridgeHUDCurrentSprintState();
    id image = BridgeHUDImageForSprintState(state);
    if (image == nil) {
        BridgeHUDRemove();
        BridgeLog("hud sprint image unavailable state=%d", (int)state);
        return;
    }
    if (state != gBridgeHUDLastSprintState) {
        ((void (*)(id, SEL, id))objc_msgSend)(gBridgeHUDSprintImageView, sel_registerName("setImage:"), image);
        gBridgeHUDLastSprintState = state;
    }
    BridgeHUDRefreshSelectionChrome();
    BridgeHUDEditorUpdateHint();
}
