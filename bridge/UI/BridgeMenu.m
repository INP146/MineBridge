#import "../BridgeInternal.h"

static id gBridgeMenuDisplayTabButton = nil;
static id gBridgeMenuSprintTabButton = nil;
static id gBridgeMenuDisplayContentView = nil;
static id gBridgeMenuSprintContentView = nil;
static bool gBridgeMenuSprintTabActive = false;

id BridgeColorWithWhiteAlpha(double white, double alpha) {
    Class colorClass = objc_getClass("UIColor");
    SEL colorSel = sel_registerName("colorWithWhite:alpha:");
    if (colorClass == Nil || !RespondsTo((id)colorClass, colorSel)) {
        return nil;
    }
    return ((id (*)(id, SEL, double, double))objc_msgSend)((id)colorClass, colorSel, white, alpha);
}

id BridgeColorWithRedGreenBlueAlpha(double red, double green, double blue, double alpha) {
    Class colorClass = objc_getClass("UIColor");
    SEL colorSel = sel_registerName("colorWithRed:green:blue:alpha:");
    if (colorClass == Nil || !RespondsTo((id)colorClass, colorSel)) {
        return nil;
    }
    return ((id (*)(id, SEL, double, double, double, double))objc_msgSend)((id)colorClass, colorSel, red, green, blue, alpha);
}

id BridgeString(const char *text) {
    Class stringClass = objc_getClass("NSString");
    SEL stringSel = sel_registerName("stringWithUTF8String:");
    if (text == NULL || stringClass == Nil || !RespondsTo((id)stringClass, stringSel)) {
        return nil;
    }
    return ((id (*)(id, SEL, const char *))objc_msgSend)((id)stringClass, stringSel, text);
}

id BridgeFont(double size, bool bold) {
    Class fontClass = objc_getClass("UIFont");
    SEL fontSel = sel_registerName(bold ? "boldSystemFontOfSize:" : "systemFontOfSize:");
    if (fontClass == Nil || !RespondsTo((id)fontClass, fontSel)) {
        return nil;
    }
    return ((id (*)(id, SEL, double))objc_msgSend)((id)fontClass, fontSel, size);
}

id BridgeViewWithFrame(BridgeCGRect frame) {
    Class viewClass = objc_getClass("UIView");
    if (viewClass == Nil) {
        return nil;
    }

    id view = ((id (*)(id, SEL))objc_msgSend)((id)viewClass, sel_registerName("alloc"));
    if (view == nil) {
        return nil;
    }
    return ((id (*)(id, SEL, BridgeCGRect))objc_msgSend)(view, sel_registerName("initWithFrame:"), frame);
}

id BridgeLabelWithFrame(BridgeCGRect frame,
                               const char *text,
                               double fontSize,
                               bool bold,
                               id textColor,
                               long alignment,
                               long lines) {
    Class labelClass = objc_getClass("UILabel");
    if (labelClass == Nil) {
        return nil;
    }

    id label = ((id (*)(id, SEL))objc_msgSend)((id)labelClass, sel_registerName("alloc"));
    if (label == nil) {
        return nil;
    }
    label = ((id (*)(id, SEL, BridgeCGRect))objc_msgSend)(label, sel_registerName("initWithFrame:"), frame);
    if (label == nil) {
        return nil;
    }

    id string = BridgeString(text);
    id font = BridgeFont(fontSize, bold);
    if (string != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(label, sel_registerName("setText:"), string);
    }
    if (font != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(label, sel_registerName("setFont:"), font);
    }
    if (textColor != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(label, sel_registerName("setTextColor:"), textColor);
    }
    ((void (*)(id, SEL, long))objc_msgSend)(label, sel_registerName("setTextAlignment:"), alignment);
    ((void (*)(id, SEL, long))objc_msgSend)(label, sel_registerName("setNumberOfLines:"), lines);
    return label;
}

void BridgeSetButtonTitle(id button, const char *title) {
    if (button == nil) {
        return;
    }

    id string = BridgeString(title);
    if (string != nil) {
        ((void (*)(id, SEL, id, unsigned long))objc_msgSend)(button, sel_registerName("setTitle:forState:"), string, 0UL);
    }
}

void BridgeSetViewHidden(id view, BOOL hidden) {
    if (view != nil && RespondsTo(view, sel_registerName("setHidden:"))) {
        ((void (*)(id, SEL, BOOL))objc_msgSend)(view, sel_registerName("setHidden:"), hidden);
    }
}

void BridgeSetButtonBackground(id button, id backgroundColor) {
    if (button != nil && backgroundColor != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(button, sel_registerName("setBackgroundColor:"), backgroundColor);
    }
}

id BridgeButtonWithFrame(BridgeCGRect frame, const char *title, id textColor, id backgroundColor) {
    Class buttonClass = objc_getClass("UIButton");
    SEL buttonSel = sel_registerName("buttonWithType:");
    if (buttonClass == Nil || !RespondsTo((id)buttonClass, buttonSel)) {
        return nil;
    }

    id button = ((id (*)(id, SEL, long))objc_msgSend)((id)buttonClass, buttonSel, 1L);
    if (button == nil) {
        return nil;
    }

    ((void (*)(id, SEL, BridgeCGRect))objc_msgSend)(button, sel_registerName("setFrame:"), frame);
    BridgeSetButtonTitle(button, title);
    if (textColor != nil) {
        ((void (*)(id, SEL, id, unsigned long))objc_msgSend)(button, sel_registerName("setTitleColor:forState:"), textColor, 0UL);
    }
    if (backgroundColor != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(button, sel_registerName("setBackgroundColor:"), backgroundColor);
    }

    id titleLabel = ObjectValue(button, "titleLabel");
    id font = BridgeFont(14.0, true);
    if (titleLabel != nil && font != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(titleLabel, sel_registerName("setFont:"), font);
    }

    id layer = ObjectValue(button, "layer");
    if (layer != nil) {
        ((void (*)(id, SEL, double))objc_msgSend)(layer, sel_registerName("setCornerRadius:"), 9.0);
        ((void (*)(id, SEL, BOOL))objc_msgSend)(layer, sel_registerName("setMasksToBounds:"), YES);
    }

    return button;
}

void BridgeRefreshMenuTabs(void) {
    BridgeSetViewHidden(gBridgeMenuDisplayContentView, gBridgeMenuSprintTabActive ? YES : NO);
    BridgeSetViewHidden(gBridgeMenuSprintContentView, gBridgeMenuSprintTabActive ? NO : YES);
    BridgeSetButtonBackground(gBridgeMenuDisplayTabButton,
                              gBridgeMenuSprintTabActive ? BridgeColorWithWhiteAlpha(1.0, 0.08) : BridgeColorWithRedGreenBlueAlpha(0.21, 0.64, 1.0, 0.34));
    BridgeSetButtonBackground(gBridgeMenuSprintTabButton,
                              gBridgeMenuSprintTabActive ? BridgeColorWithRedGreenBlueAlpha(0.21, 0.64, 1.0, 0.34) : BridgeColorWithWhiteAlpha(1.0, 0.08));
}

void BridgeRefreshSprintMenuButtons(void) {
    if (gBridgeHUDToggleButton != nil) {
        BridgeSetButtonTitle(gBridgeHUDToggleButton, gBridgeHUDEnabled ? "开启" : "关闭");
    }
    if (gBridgeHUDSprintStatusButton != nil) {
        BridgeSetButtonTitle(gBridgeHUDSprintStatusButton, gBridgeHUDSprintStatusEnabled ? "开启" : "关闭");
    }
    if (gBridgeHUDSettingsButton != nil) {
        BridgeSetButtonTitle(gBridgeHUDSettingsButton, "设置");
    }
    if (gBridgeSprintModeButton != nil) {
        BridgeSetButtonTitle(gBridgeSprintModeButton,
                             gBridgeSprintMode == BridgeSprintModeToggle ? "切换模式" : "原生模式");
    }
    if (gBridgeSprintKeyButton != nil) {
        BridgeSetButtonTitle(gBridgeSprintKeyButton,
                             gBridgeMenuCapturingSprintKey ? "> <" : BridgeKeyName(gBridgeSprintKeyCode));
    }
    BridgeRefreshMenuTabs();
}

void BridgeMenuHUDTapped(id self, SEL _cmd, id sender) {
    BridgeSettingsSaveHUDEnabled(!gBridgeHUDEnabled);
    BridgeRefreshSprintMenuButtons();
    BridgeHUDRefresh();
}

void BridgeMenuHUDSprintStatusTapped(id self, SEL _cmd, id sender) {
    BridgeSettingsSaveHUDSprintStatusEnabled(!gBridgeHUDSprintStatusEnabled);
    BridgeRefreshSprintMenuButtons();
    BridgeHUDRefresh();
}

void BridgeMenuHUDSettingsTapped(id self, SEL _cmd, id sender) {
    (void)self;
    (void)_cmd;
    (void)sender;
    bool restoreMouseLook = gBridgeMenuRestoreMouseLookOnHide;
    gBridgeMenuRestoreMouseLookOnHide = false;
    gBridgeMenuCapturingSprintKey = false;
    HideBridgeMenu("hud-editor");
    BridgeHUDEditorBegin(true, restoreMouseLook);
}

void BridgeMenuSprintModeTapped(id self, SEL _cmd, id sender) {
    BridgeSprintMode nextMode = gBridgeSprintMode == BridgeSprintModeToggle ? BridgeSprintModeNative : BridgeSprintModeToggle;
    if (nextMode == BridgeSprintModeNative) {
        BridgeClearSprintToggleState("sprint-mode-native");
    }
    BridgeSettingsSaveSprintMode(nextMode);
    BridgeRefreshSprintMenuButtons();
    BridgeHUDRefresh();
}

void BridgeMenuSprintKeyTapped(id self, SEL _cmd, id sender) {
    gBridgeMenuCapturingSprintKey = true;
    BridgeRefreshSprintMenuButtons();
}

void BridgeMenuDisplayTabTapped(id self, SEL _cmd, id sender) {
    gBridgeMenuSprintTabActive = false;
    gBridgeMenuCapturingSprintKey = false;
    BridgeRefreshSprintMenuButtons();
}

void BridgeMenuSprintTabTapped(id self, SEL _cmd, id sender) {
    gBridgeMenuSprintTabActive = true;
    BridgeRefreshSprintMenuButtons();
}

id BridgeMenuActionTarget(void) {
    static id target = nil;
    if (target != nil) {
        return target;
    }

    Class cls = objc_getClass("BridgeMenuActionTarget");
    if (cls == Nil) {
        Class baseClass = objc_getClass("NSObject");
        cls = objc_allocateClassPair(baseClass, "BridgeMenuActionTarget", 0);
        if (cls != Nil) {
            class_addMethod(cls, sel_registerName("bridgeHUDTapped:"), (IMP)BridgeMenuHUDTapped, "v@:@");
            class_addMethod(cls, sel_registerName("bridgeHUDSprintStatusTapped:"), (IMP)BridgeMenuHUDSprintStatusTapped, "v@:@");
            class_addMethod(cls, sel_registerName("bridgeHUDSettingsTapped:"), (IMP)BridgeMenuHUDSettingsTapped, "v@:@");
            class_addMethod(cls, sel_registerName("bridgeSprintModeTapped:"), (IMP)BridgeMenuSprintModeTapped, "v@:@");
            class_addMethod(cls, sel_registerName("bridgeSprintKeyTapped:"), (IMP)BridgeMenuSprintKeyTapped, "v@:@");
            class_addMethod(cls, sel_registerName("bridgeDisplayTabTapped:"), (IMP)BridgeMenuDisplayTabTapped, "v@:@");
            class_addMethod(cls, sel_registerName("bridgeSprintTabTapped:"), (IMP)BridgeMenuSprintTabTapped, "v@:@");
            objc_registerClassPair(cls);
        }
    }

    if (cls != Nil) {
        target = ((id (*)(id, SEL))objc_msgSend)((id)cls, sel_registerName("new"));
    }
    return target;
}

void BridgeAttachButtonAction(id button, SEL action) {
    id target = BridgeMenuActionTarget();
    if (button == nil || target == nil) {
        return;
    }

    ((void (*)(id, SEL, id, SEL, unsigned long))objc_msgSend)(button,
                                                              sel_registerName("addTarget:action:forControlEvents:"),
                                                              target,
                                                              action,
                                                              64UL);
}

bool BridgeMenuHandleCapturedKey(unsigned short keyCode) {
    if (!gBridgeMenuCapturingSprintKey) {
        return false;
    }

    if (keyCode == 0x29) {
        gBridgeMenuCapturingSprintKey = false;
        BridgeRefreshSprintMenuButtons();
        return true;
    }

    if (keyCode == kBridgeMenuKeyM) {
        if (gBridgeSprintKeyButton != nil) {
            BridgeSetButtonTitle(gBridgeSprintKeyButton, "保留键");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 650 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
                if (gBridgeMenuCapturingSprintKey) {
                    BridgeRefreshSprintMenuButtons();
                }
            });
        }
        return true;
    }

    BridgeInvalidateSprintGameLatch("sprint-key-changed");
    BridgeSettingsSaveSprintKeyCode(keyCode);
    gBridgeMenuCapturingSprintKey = false;
    BridgeRefreshSprintMenuButtons();
    BridgeHUDRefresh();
    return true;
}

void BridgeAnimate(double duration, void (^animations)(void), void (^completion)(BOOL finished)) {
    Class viewClass = objc_getClass("UIView");
    SEL animateSel = sel_registerName("animateWithDuration:animations:completion:");
    if (viewClass != Nil && RespondsTo((id)viewClass, animateSel)) {
        ((void (*)(id, SEL, double, id, id))objc_msgSend)((id)viewClass, animateSel, duration, animations, completion);
        return;
    }

    if (animations != nil) {
        animations();
    }
    if (completion != nil) {
        completion(YES);
    }
}

void ShowBridgeMenu(const char *reason) {
    if (gBridgeMenuVisible) {
        return;
    }

    id window = KeyWindow();
    if (window == nil || !RespondsTo(window, sel_registerName("bounds"))) {
        BridgeLog("bridge menu show failed reason=%s window=%p",
                  reason == NULL ? "<nil>" : reason,
                  (__bridge void *)window);
        return;
    }

    BridgeCGRect bounds = ((BridgeCGRect (*)(id, SEL))objc_msgSend)(window, sel_registerName("bounds"));
    if (bounds.size.width <= 0.0 || bounds.size.height <= 0.0) {
        BridgeLog("bridge menu show failed invalid bounds reason=%s width=%.1f height=%.1f",
                  reason == NULL ? "<nil>" : reason,
                  bounds.size.width,
                  bounds.size.height);
        return;
    }

    BridgeCGRect overlayFrame = { { 0.0, 0.0 }, { bounds.size.width, bounds.size.height } };
    id overlay = BridgeViewWithFrame(overlayFrame);
    if (overlay == nil) {
        BridgeLog("bridge menu show failed overlay allocation reason=%s",
                  reason == NULL ? "<nil>" : reason);
        return;
    }

    double panelWidth = bounds.size.width - 56.0;
    if (panelWidth > 620.0) {
        panelWidth = 620.0;
    }
    if (panelWidth < 220.0) {
        panelWidth = bounds.size.width > 32.0 ? bounds.size.width - 32.0 : bounds.size.width;
    }

    double panelHeight = bounds.size.height - 80.0;
    if (panelHeight > 430.0) {
        panelHeight = 430.0;
    }
    if (panelHeight < 160.0) {
        panelHeight = bounds.size.height > 32.0 ? bounds.size.height - 32.0 : bounds.size.height;
    }

    BridgeCGRect panelFrame = {
        { (bounds.size.width - panelWidth) * 0.5, (bounds.size.height - panelHeight) * 0.5 },
        { panelWidth, panelHeight }
    };
    BridgeCGRect initialPanelFrame = panelFrame;
    initialPanelFrame.origin.y += 14.0;
    id panel = BridgeViewWithFrame(initialPanelFrame);
    if (panel == nil) {
        BridgeLog("bridge menu show failed panel allocation reason=%s",
                  reason == NULL ? "<nil>" : reason);
        return;
    }

    id overlayColor = BridgeColorWithWhiteAlpha(0.0, 0.42);
    id panelColor = BridgeColorWithRedGreenBlueAlpha(0.06, 0.07, 0.08, 0.94);
    id borderColor = BridgeColorWithRedGreenBlueAlpha(0.30, 0.72, 1.0, 0.36);
    id accentColor = BridgeColorWithRedGreenBlueAlpha(0.21, 0.64, 1.0, 1.0);
    id titleColor = BridgeColorWithWhiteAlpha(1.0, 0.96);
    id secondaryColor = BridgeColorWithWhiteAlpha(1.0, 0.62);
    id mutedColor = BridgeColorWithWhiteAlpha(1.0, 0.34);
    id wellColor = BridgeColorWithWhiteAlpha(1.0, 0.07);
    if (overlayColor != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(overlay, sel_registerName("setBackgroundColor:"), overlayColor);
    }
    if (panelColor != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(panel, sel_registerName("setBackgroundColor:"), panelColor);
    }

    ((void (*)(id, SEL, BOOL))objc_msgSend)(overlay, sel_registerName("setUserInteractionEnabled:"), YES);
    ((void (*)(id, SEL, unsigned long))objc_msgSend)(overlay, sel_registerName("setAutoresizingMask:"), 18UL);
    ((void (*)(id, SEL, unsigned long))objc_msgSend)(panel, sel_registerName("setAutoresizingMask:"), 45UL);

    id layer = ObjectValue(panel, "layer");
    if (layer != nil) {
        ((void (*)(id, SEL, double))objc_msgSend)(layer, sel_registerName("setCornerRadius:"), 22.0);
        ((void (*)(id, SEL, BOOL))objc_msgSend)(layer, sel_registerName("setMasksToBounds:"), YES);
        if (borderColor != nil) {
            void *cgColor = PointerValue(borderColor, "CGColor");
            if (cgColor != NULL) {
                ((void (*)(id, SEL, void *))objc_msgSend)(layer, sel_registerName("setBorderColor:"), cgColor);
                ((void (*)(id, SEL, double))objc_msgSend)(layer, sel_registerName("setBorderWidth:"), 1.0);
            }
        }
    }

    BridgeCGRect accentFrame = { { 0.0, 0.0 }, { 6.0, panelHeight } };
    id accent = BridgeViewWithFrame(accentFrame);
    if (accent != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(accent, sel_registerName("setBackgroundColor:"), accentColor);
        ((void (*)(id, SEL, id))objc_msgSend)(panel, sel_registerName("addSubview:"), accent);
    }

    BridgeCGRect titleFrame = { { 30.0, 26.0 }, { panelWidth - 60.0, 34.0 } };
    id title = BridgeLabelWithFrame(titleFrame, "MineBridge", 26.0, true, titleColor, 0, 1);
    if (title != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(panel, sel_registerName("addSubview:"), title);
    }

    BridgeCGRect subtitleFrame = { { 31.0, 62.0 }, { panelWidth - 62.0, 24.0 } };
    id subtitle = BridgeLabelWithFrame(subtitleFrame, "Press M or Esc to close", 13.0, false, secondaryColor, 0, 1);
    if (subtitle != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(panel, sel_registerName("addSubview:"), subtitle);
    }

    double tabX = 30.0;
    double tabY = 100.0;
    double tabGap = 10.0;
    double tabWidth = (panelWidth - tabX * 2.0 - tabGap) * 0.5;
    if (tabWidth < 88.0) {
        tabWidth = 88.0;
    }
    BridgeCGRect displayTabFrame = { { tabX, tabY }, { tabWidth, 36.0 } };
    gBridgeMenuDisplayTabButton = BridgeButtonWithFrame(displayTabFrame, "HUD", titleColor, BridgeColorWithWhiteAlpha(1.0, 0.08));
    if (gBridgeMenuDisplayTabButton != nil) {
        BridgeAttachButtonAction(gBridgeMenuDisplayTabButton, sel_registerName("bridgeDisplayTabTapped:"));
        ((void (*)(id, SEL, id))objc_msgSend)(panel, sel_registerName("addSubview:"), gBridgeMenuDisplayTabButton);
    }

    BridgeCGRect sprintTabFrame = { { tabX + tabWidth + tabGap, tabY }, { tabWidth, 36.0 } };
    gBridgeMenuSprintTabButton = BridgeButtonWithFrame(sprintTabFrame, "拓展功能", titleColor, BridgeColorWithWhiteAlpha(1.0, 0.08));
    if (gBridgeMenuSprintTabButton != nil) {
        BridgeAttachButtonAction(gBridgeMenuSprintTabButton, sel_registerName("bridgeSprintTabTapped:"));
        ((void (*)(id, SEL, id))objc_msgSend)(panel, sel_registerName("addSubview:"), gBridgeMenuSprintTabButton);
    }

    BridgeCGRect wellFrame = { { 26.0, 152.0 }, { panelWidth - 52.0, panelHeight - 184.0 } };
    id well = BridgeViewWithFrame(wellFrame);
    if (well != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(well, sel_registerName("setBackgroundColor:"), wellColor);
        id wellLayer = ObjectValue(well, "layer");
        if (wellLayer != nil) {
            ((void (*)(id, SEL, double))objc_msgSend)(wellLayer, sel_registerName("setCornerRadius:"), 14.0);
            ((void (*)(id, SEL, BOOL))objc_msgSend)(wellLayer, sel_registerName("setMasksToBounds:"), YES);
        }
        ((void (*)(id, SEL, id))objc_msgSend)(panel, sel_registerName("addSubview:"), well);
    }

    gBridgeMenuDisplayContentView = BridgeViewWithFrame(wellFrame);
    if (gBridgeMenuDisplayContentView != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(panel, sel_registerName("addSubview:"), gBridgeMenuDisplayContentView);
    }
    gBridgeMenuSprintContentView = BridgeViewWithFrame(wellFrame);
    if (gBridgeMenuSprintContentView != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(panel, sel_registerName("addSubview:"), gBridgeMenuSprintContentView);
    }

    double contentX = 18.0;
    double contentY = 16.0;
    double contentWidth = wellFrame.size.width;
    double buttonWidth = contentWidth < 280.0 ? 92.0 : (panelWidth < 360.0 ? 118.0 : 136.0);
    double labelWidth = contentWidth - contentX * 2.0 - buttonWidth - 16.0;
    if (labelWidth < 92.0) {
        labelWidth = 92.0;
    }

    BridgeCGRect displayTitleFrame = { { contentX, contentY }, { contentWidth - contentX * 2.0, 22.0 } };
    id displayTitle = BridgeLabelWithFrame(displayTitleFrame, "HUD", 13.0, true, mutedColor, 0, 1);
    if (displayTitle != nil && gBridgeMenuDisplayContentView != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(gBridgeMenuDisplayContentView, sel_registerName("addSubview:"), displayTitle);
    }

    BridgeCGRect hudLabelFrame = { { contentX, contentY + 36.0 }, { labelWidth, 24.0 } };
    id hudLabel = BridgeLabelWithFrame(hudLabelFrame, "HUD", 15.0, true, titleColor, 0, 1);
    if (hudLabel != nil && gBridgeMenuDisplayContentView != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(gBridgeMenuDisplayContentView, sel_registerName("addSubview:"), hudLabel);
    }

    BridgeCGRect hudHintFrame = { { contentX, contentY + 59.0 }, { contentWidth - contentX * 2.0, 20.0 } };
    id hudHint = BridgeLabelWithFrame(hudHintFrame, "插件状态图标层", 12.0, false, secondaryColor, 0, 1);
    if (hudHint != nil && gBridgeMenuDisplayContentView != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(gBridgeMenuDisplayContentView, sel_registerName("addSubview:"), hudHint);
    }

    BridgeCGRect hudButtonFrame = {
        { contentWidth - contentX - buttonWidth, contentY + 32.0 },
        { buttonWidth, 34.0 }
    };
    gBridgeHUDToggleButton = BridgeButtonWithFrame(hudButtonFrame, "", titleColor, BridgeColorWithWhiteAlpha(1.0, 0.12));
    if (gBridgeHUDToggleButton != nil && gBridgeMenuDisplayContentView != nil) {
        BridgeAttachButtonAction(gBridgeHUDToggleButton, sel_registerName("bridgeHUDTapped:"));
        ((void (*)(id, SEL, id))objc_msgSend)(gBridgeMenuDisplayContentView, sel_registerName("addSubview:"), gBridgeHUDToggleButton);
    }

    BridgeCGRect hudSprintLabelFrame = { { contentX, contentY + 92.0 }, { labelWidth, 24.0 } };
    id hudSprintLabel = BridgeLabelWithFrame(hudSprintLabelFrame, "疾跑显示", 15.0, true, titleColor, 0, 1);
    if (hudSprintLabel != nil && gBridgeMenuDisplayContentView != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(gBridgeMenuDisplayContentView, sel_registerName("addSubview:"), hudSprintLabel);
    }

    BridgeCGRect hudSprintHintFrame = { { contentX, contentY + 115.0 }, { contentWidth - contentX * 2.0, 20.0 } };
    id hudSprintHint = BridgeLabelWithFrame(hudSprintHintFrame, "用图标显示当前疾跑语义", 12.0, false, secondaryColor, 0, 1);
    if (hudSprintHint != nil && gBridgeMenuDisplayContentView != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(gBridgeMenuDisplayContentView, sel_registerName("addSubview:"), hudSprintHint);
    }

    BridgeCGRect hudSprintButtonFrame = {
        { contentWidth - contentX - buttonWidth, contentY + 88.0 },
        { buttonWidth, 34.0 }
    };
    gBridgeHUDSprintStatusButton = BridgeButtonWithFrame(hudSprintButtonFrame, "", titleColor, BridgeColorWithWhiteAlpha(1.0, 0.12));
    if (gBridgeHUDSprintStatusButton != nil && gBridgeMenuDisplayContentView != nil) {
        BridgeAttachButtonAction(gBridgeHUDSprintStatusButton, sel_registerName("bridgeHUDSprintStatusTapped:"));
        ((void (*)(id, SEL, id))objc_msgSend)(gBridgeMenuDisplayContentView, sel_registerName("addSubview:"), gBridgeHUDSprintStatusButton);
    }

    BridgeCGRect hudSettingsLabelFrame = { { contentX, contentY + 136.0 }, { labelWidth, 24.0 } };
    id hudSettingsLabel = BridgeLabelWithFrame(hudSettingsLabelFrame, "HUD设置", 15.0, true, titleColor, 0, 1);
    if (hudSettingsLabel != nil && gBridgeMenuDisplayContentView != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(gBridgeMenuDisplayContentView, sel_registerName("addSubview:"), hudSettingsLabel);
    }

    BridgeCGRect hudSettingsHintFrame = { { contentX, contentY + 159.0 }, { contentWidth - contentX * 2.0, 20.0 } };
    id hudSettingsHint = BridgeLabelWithFrame(hudSettingsHintFrame, "点击设置后隐藏菜单，在 HUD 中点击元素选中并调整", 12.0, false, secondaryColor, 0, 1);
    if (hudSettingsHint != nil && gBridgeMenuDisplayContentView != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(gBridgeMenuDisplayContentView, sel_registerName("addSubview:"), hudSettingsHint);
    }

    BridgeCGRect hudSettingsButtonFrame = {
        { contentWidth - contentX - buttonWidth, contentY + 132.0 },
        { buttonWidth, 34.0 }
    };
    gBridgeHUDSettingsButton = BridgeButtonWithFrame(hudSettingsButtonFrame, "", titleColor, BridgeColorWithRedGreenBlueAlpha(0.21, 0.64, 1.0, 0.32));
    if (gBridgeHUDSettingsButton != nil && gBridgeMenuDisplayContentView != nil) {
        BridgeAttachButtonAction(gBridgeHUDSettingsButton, sel_registerName("bridgeHUDSettingsTapped:"));
        ((void (*)(id, SEL, id))objc_msgSend)(gBridgeMenuDisplayContentView, sel_registerName("addSubview:"), gBridgeHUDSettingsButton);
    }

    BridgeCGRect sprintTitleFrame = { { contentX, contentY }, { contentWidth - contentX * 2.0, 22.0 } };
    id sprintTitle = BridgeLabelWithFrame(sprintTitleFrame, "拓展功能", 13.0, true, mutedColor, 0, 1);
    if (sprintTitle != nil && gBridgeMenuSprintContentView != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(gBridgeMenuSprintContentView, sel_registerName("addSubview:"), sprintTitle);
    }

    BridgeCGRect sprintModeLabelFrame = { { contentX, contentY + 36.0 }, { labelWidth, 24.0 } };
    id sprintModeLabel = BridgeLabelWithFrame(sprintModeLabelFrame, "疾跑模式", 15.0, true, titleColor, 0, 1);
    if (sprintModeLabel != nil && gBridgeMenuSprintContentView != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(gBridgeMenuSprintContentView, sel_registerName("addSubview:"), sprintModeLabel);
    }

    BridgeCGRect sprintModeHintFrame = { { contentX, contentY + 59.0 }, { contentWidth - contentX * 2.0, 20.0 } };
    id sprintModeHint = BridgeLabelWithFrame(sprintModeHintFrame, "原生不处理；切换模式保持疾跑意愿", 12.0, false, secondaryColor, 0, 1);
    if (sprintModeHint != nil && gBridgeMenuSprintContentView != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(gBridgeMenuSprintContentView, sel_registerName("addSubview:"), sprintModeHint);
    }

    BridgeCGRect sprintModeButtonFrame = {
        { contentWidth - contentX - buttonWidth, contentY + 32.0 },
        { buttonWidth, 34.0 }
    };
    gBridgeSprintModeButton = BridgeButtonWithFrame(sprintModeButtonFrame, "", titleColor, BridgeColorWithWhiteAlpha(1.0, 0.12));
    if (gBridgeSprintModeButton != nil && gBridgeMenuSprintContentView != nil) {
        BridgeAttachButtonAction(gBridgeSprintModeButton, sel_registerName("bridgeSprintModeTapped:"));
        ((void (*)(id, SEL, id))objc_msgSend)(gBridgeMenuSprintContentView, sel_registerName("addSubview:"), gBridgeSprintModeButton);
    }

    BridgeCGRect sprintKeyLabelFrame = { { contentX, contentY + 92.0 }, { labelWidth, 24.0 } };
    id sprintKeyLabel = BridgeLabelWithFrame(sprintKeyLabelFrame, "游戏疾跑键", 15.0, true, titleColor, 0, 1);
    if (sprintKeyLabel != nil && gBridgeMenuSprintContentView != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(gBridgeMenuSprintContentView, sel_registerName("addSubview:"), sprintKeyLabel);
    }

    BridgeCGRect sprintKeyHintFrame = { { contentX, contentY + 115.0 }, { contentWidth - contentX * 2.0, 20.0 } };
    id sprintKeyHint = BridgeLabelWithFrame(sprintKeyHintFrame, "点右侧按键后，按一次键盘上的目标键", 12.0, false, secondaryColor, 0, 1);
    if (sprintKeyHint != nil && gBridgeMenuSprintContentView != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(gBridgeMenuSprintContentView, sel_registerName("addSubview:"), sprintKeyHint);
    }

    BridgeCGRect sprintKeyButtonFrame = {
        { contentWidth - contentX - buttonWidth, contentY + 88.0 },
        { buttonWidth, 34.0 }
    };
    gBridgeSprintKeyButton = BridgeButtonWithFrame(sprintKeyButtonFrame, "", titleColor, BridgeColorWithRedGreenBlueAlpha(0.21, 0.64, 1.0, 0.32));
    if (gBridgeSprintKeyButton != nil && gBridgeMenuSprintContentView != nil) {
        BridgeAttachButtonAction(gBridgeSprintKeyButton, sel_registerName("bridgeSprintKeyTapped:"));
        ((void (*)(id, SEL, id))objc_msgSend)(gBridgeMenuSprintContentView, sel_registerName("addSubview:"), gBridgeSprintKeyButton);
    }
    BridgeRefreshSprintMenuButtons();

    ((void (*)(id, SEL, double))objc_msgSend)(overlay, sel_registerName("setAlpha:"), 0.0);
    ((void (*)(id, SEL, double))objc_msgSend)(panel, sel_registerName("setAlpha:"), 0.0);
    ((void (*)(id, SEL, id))objc_msgSend)(overlay, sel_registerName("addSubview:"), panel);
    ((void (*)(id, SEL, id))objc_msgSend)(window, sel_registerName("addSubview:"), overlay);

    gBridgeMenuRestoreMouseLookOnHide = CurrentPlatformPointerLocked() || gPointerLockWanted || gPointerCaptureActive;
    gBridgeMenuOverlayView = overlay;
    gBridgeMenuVisible = true;
    BridgeHUDRefresh();
    BridgeSuppressActiveGameKeysForUI("bridge-menu-show");
    BridgeSuppressActiveMouseButtonsForUI("bridge-menu-show");
    gPointerLockInhibited = true;
    gPointerLockReleaseKeyCode = 0;
    gPointerLockRearmAllowedByToggle = false;
    gPointerLockRearmAllowedByMouseClick = false;
    gPointerLockWanted = false;
    SetPointerCaptureActive(false, "bridge-menu-show");
    SetNeedsPointerLockUpdateForVisibleChain();
    ReconcilePointerCapture(gLastController, "bridge-menu-show");
    BridgeAnimate(0.18, ^{
        ((void (*)(id, SEL, double))objc_msgSend)(overlay, sel_registerName("setAlpha:"), 1.0);
        ((void (*)(id, SEL, double))objc_msgSend)(panel, sel_registerName("setAlpha:"), 1.0);
        ((void (*)(id, SEL, BridgeCGRect))objc_msgSend)(panel, sel_registerName("setFrame:"), panelFrame);
    }, nil);
    BridgeLog("bridge menu shown reason=%s window=%p overlay=%p panel=%p",
              reason == NULL ? "<nil>" : reason,
              (__bridge void *)window,
              (__bridge void *)overlay,
              (__bridge void *)panel);
}

void HideBridgeMenu(const char *reason) {
    if (!gBridgeMenuVisible && gBridgeMenuOverlayView == nil) {
        return;
    }

    id overlay = gBridgeMenuOverlayView;
    gBridgeMenuOverlayView = nil;
    gBridgeHUDToggleButton = nil;
    gBridgeHUDSprintStatusButton = nil;
    gBridgeHUDSettingsButton = nil;
    gBridgeSprintModeButton = nil;
    gBridgeSprintKeyButton = nil;
    gBridgeMenuDisplayTabButton = nil;
    gBridgeMenuSprintTabButton = nil;
    gBridgeMenuDisplayContentView = nil;
    gBridgeMenuSprintContentView = nil;
    gBridgeMenuVisible = false;
    bool restoreMouseLook = gBridgeMenuRestoreMouseLookOnHide;
    gBridgeMenuRestoreMouseLookOnHide = false;
    gBridgeMenuCapturingSprintKey = false;
    gBridgeHUDEditorActive = false;
    if (overlay != nil && RespondsTo(overlay, sel_registerName("removeFromSuperview"))) {
        BridgeAnimate(0.14, ^{
            ((void (*)(id, SEL, double))objc_msgSend)(overlay, sel_registerName("setAlpha:"), 0.0);
        }, ^(BOOL finished) {
            ((void (*)(id, SEL))objc_msgSend)(overlay, sel_registerName("removeFromSuperview"));
        });
    }

    gPointerLockInhibited = false;
    gPointerLockReleaseKeyCode = 0;
    gPointerLockRearmAllowedByToggle = false;
    gPointerLockRearmAllowedByMouseClick = false;
    if (restoreMouseLook && !gTextInputActive) {
        UpdateMouseLookAllowed(true, "bridge-menu-hidden-restore");
        if (!CurrentPlatformPointerLocked()) {
            SetPlatformPointerLocked(true, "bridge-menu-hidden-restore");
        }
    }
    BridgeLog("bridge menu hidden reason=%s overlay=%p restoreMouseLook=%d",
              reason == NULL ? "<nil>" : reason,
              (__bridge void *)overlay,
              restoreMouseLook ? 1 : 0);
    BridgeHUDRefresh();
}

void ShowBridgeLoadedToast(void) {
    id window = KeyWindow();
    if (window == nil || !RespondsTo(window, sel_registerName("bounds"))) {
        BridgeLog("bridge loaded toast skipped window=%p", (__bridge void *)window);
        return;
    }

    BridgeCGRect bounds = ((BridgeCGRect (*)(id, SEL))objc_msgSend)(window, sel_registerName("bounds"));
    double toastWidth = 208.0;
    double toastHeight = 44.0;
    double margin = 18.0;
    if (bounds.size.width < toastWidth + margin * 2.0) {
        toastWidth = bounds.size.width - margin * 2.0;
    }
    if (toastWidth < 150.0) {
        toastWidth = bounds.size.width > 24.0 ? bounds.size.width - 24.0 : bounds.size.width;
        margin = 12.0;
    }

    BridgeCGRect visibleToastFrame = {
        { bounds.size.width - toastWidth - margin, 22.0 },
        { toastWidth, toastHeight }
    };
    BridgeCGRect hiddenToastFrame = visibleToastFrame;
    hiddenToastFrame.origin.x = bounds.size.width + margin;
    id toast = BridgeViewWithFrame(hiddenToastFrame);
    if (toast == nil) {
        return;
    }

    id toastColor = BridgeColorWithRedGreenBlueAlpha(0.06, 0.08, 0.09, 0.92);
    id borderColor = BridgeColorWithRedGreenBlueAlpha(0.30, 0.72, 1.0, 0.36);
    id accentColor = BridgeColorWithRedGreenBlueAlpha(0.21, 0.64, 1.0, 1.0);
    id textColor = BridgeColorWithWhiteAlpha(1.0, 0.95);
    if (toastColor != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(toast, sel_registerName("setBackgroundColor:"), toastColor);
    }

    ((void (*)(id, SEL, BOOL))objc_msgSend)(toast, sel_registerName("setUserInteractionEnabled:"), NO);
    ((void (*)(id, SEL, unsigned long))objc_msgSend)(toast, sel_registerName("setAutoresizingMask:"), 33UL);
    id layer = ObjectValue(toast, "layer");
    if (layer != nil) {
        ((void (*)(id, SEL, double))objc_msgSend)(layer, sel_registerName("setCornerRadius:"), 12.0);
        ((void (*)(id, SEL, BOOL))objc_msgSend)(layer, sel_registerName("setMasksToBounds:"), YES);
        if (borderColor != nil) {
            void *cgColor = PointerValue(borderColor, "CGColor");
            if (cgColor != NULL) {
                ((void (*)(id, SEL, void *))objc_msgSend)(layer, sel_registerName("setBorderColor:"), cgColor);
                ((void (*)(id, SEL, double))objc_msgSend)(layer, sel_registerName("setBorderWidth:"), 1.0);
            }
        }
    }

    BridgeCGRect accentFrame = { { 0.0, 0.0 }, { 6.0, toastHeight } };
    id accent = BridgeViewWithFrame(accentFrame);
    if (accent != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(accent, sel_registerName("setBackgroundColor:"), accentColor);
        ((void (*)(id, SEL, id))objc_msgSend)(toast, sel_registerName("addSubview:"), accent);
    }

    BridgeCGRect labelFrame = { { 22.0, 0.0 }, { toastWidth - 34.0, toastHeight } };
    id label = BridgeLabelWithFrame(labelFrame, "MineBridge loaded", 14.0, true, textColor, 0, 1);
    if (label != nil) {
        ((void (*)(id, SEL, id))objc_msgSend)(toast, sel_registerName("addSubview:"), label);
    }

    ((void (*)(id, SEL, id))objc_msgSend)(window, sel_registerName("addSubview:"), toast);
    BridgeAnimate(0.24, ^{
        ((void (*)(id, SEL, BridgeCGRect))objc_msgSend)(toast, sel_registerName("setFrame:"), visibleToastFrame);
    }, nil);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 8000 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^{
        BridgeAnimate(0.24, ^{
            ((void (*)(id, SEL, BridgeCGRect))objc_msgSend)(toast, sel_registerName("setFrame:"), hiddenToastFrame);
        }, ^(BOOL finished) {
            if (RespondsTo(toast, sel_registerName("removeFromSuperview"))) {
                ((void (*)(id, SEL))objc_msgSend)(toast, sel_registerName("removeFromSuperview"));
            }
        });
    });
}

bool IsBridgeMenuChordKey(unsigned short keyCode) {
    return keyCode == kBridgeMenuKeyM;
}

void ToggleBridgeMenuFromHotkey(void) {
    if (gBridgeHUDEditorActive) {
        BridgeLog("bridge menu hotkey ignored while hud editor active");
        return;
    }

    if (gBridgeMenuVisible) {
        HideBridgeMenu("hotkey");
    } else {
        ShowBridgeMenu("hotkey");
    }
}
