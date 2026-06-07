#import "../BridgeInternal.h"

static NSString *BridgeSettingsSprintModeKey(void) {
    return @"minebridge.sprint.mode";
}

static NSString *BridgeSettingsSprintKeyCodeKey(void) {
    return @"minebridge.sprint.keyCode";
}

static NSString *BridgeSettingsHUDEnabledKey(void) {
    return @"minebridge.hud.enabled";
}

static NSString *BridgeSettingsHUDSprintStatusEnabledKey(void) {
    return @"minebridge.hud.sprintStatus.enabled";
}

static NSString *BridgeSettingsHUDSprintXKey(void) {
    return @"minebridge.hud.sprintStatus.x";
}

static NSString *BridgeSettingsHUDSprintYKey(void) {
    return @"minebridge.hud.sprintStatus.y";
}

static NSString *BridgeSettingsHUDSprintSizeKey(void) {
    return @"minebridge.hud.sprintStatus.size";
}

static NSString *BridgeSettingsHUDSprintAlphaKey(void) {
    return @"minebridge.hud.sprintStatus.alpha";
}

static double BridgeClampDouble(double value, double minValue, double maxValue) {
    if (value < minValue) {
        return minValue;
    }
    if (value > maxValue) {
        return maxValue;
    }
    return value;
}

void BridgeSettingsLoad(void) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *modeKey = BridgeSettingsSprintModeKey();
    NSString *keyCodeKey = BridgeSettingsSprintKeyCodeKey();
    NSString *hudEnabledKey = BridgeSettingsHUDEnabledKey();
    NSString *hudSprintStatusKey = BridgeSettingsHUDSprintStatusEnabledKey();
    NSString *hudSprintXKey = BridgeSettingsHUDSprintXKey();
    NSString *hudSprintYKey = BridgeSettingsHUDSprintYKey();
    NSString *hudSprintSizeKey = BridgeSettingsHUDSprintSizeKey();
    NSString *hudSprintAlphaKey = BridgeSettingsHUDSprintAlphaKey();

    if ([defaults objectForKey:modeKey] != nil) {
        NSInteger mode = [defaults integerForKey:modeKey];
        gBridgeSprintMode = mode == BridgeSprintModeToggle ? BridgeSprintModeToggle : BridgeSprintModeNative;
    }

    if ([defaults objectForKey:keyCodeKey] != nil) {
        NSInteger keyCode = [defaults integerForKey:keyCodeKey];
        if (keyCode > 0 && keyCode <= UINT16_MAX) {
            gBridgeSprintKeyCode = (unsigned short)keyCode;
        }
    }

    if ([defaults objectForKey:hudEnabledKey] != nil) {
        gBridgeHUDEnabled = [defaults boolForKey:hudEnabledKey];
    }

    if ([defaults objectForKey:hudSprintStatusKey] != nil) {
        gBridgeHUDSprintStatusEnabled = [defaults boolForKey:hudSprintStatusKey];
    }

    if ([defaults objectForKey:hudSprintXKey] != nil) {
        gBridgeHUDSprintX = BridgeClampDouble([defaults doubleForKey:hudSprintXKey], 0.0, 4096.0);
    }
    if ([defaults objectForKey:hudSprintYKey] != nil) {
        gBridgeHUDSprintY = BridgeClampDouble([defaults doubleForKey:hudSprintYKey], 0.0, 4096.0);
    }
    if ([defaults objectForKey:hudSprintSizeKey] != nil) {
        gBridgeHUDSprintSize = BridgeClampDouble([defaults doubleForKey:hudSprintSizeKey], 18.0, 120.0);
    }
    if ([defaults objectForKey:hudSprintAlphaKey] != nil) {
        gBridgeHUDSprintAlpha = BridgeClampDouble([defaults doubleForKey:hudSprintAlphaKey], 0.15, 1.0);
    }

    BridgeLog("settings loaded sprintMode=%d sprintKey=%u hud=%d hudSprint=%d hudSprintLayout=(%.1f,%.1f %.1f %.2f)",
              (int)gBridgeSprintMode,
              gBridgeSprintKeyCode,
              gBridgeHUDEnabled ? 1 : 0,
              gBridgeHUDSprintStatusEnabled ? 1 : 0,
              gBridgeHUDSprintX,
              gBridgeHUDSprintY,
              gBridgeHUDSprintSize,
              gBridgeHUDSprintAlpha);
}

void BridgeSettingsSaveHUDEnabled(bool enabled) {
    gBridgeHUDEnabled = enabled;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:enabled forKey:BridgeSettingsHUDEnabledKey()];
    [defaults synchronize];
    BridgeLog("settings saved hud=%d", enabled ? 1 : 0);
}

void BridgeSettingsSaveHUDSprintStatusEnabled(bool enabled) {
    gBridgeHUDSprintStatusEnabled = enabled;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:enabled forKey:BridgeSettingsHUDSprintStatusEnabledKey()];
    [defaults synchronize];
    BridgeLog("settings saved hudSprint=%d", enabled ? 1 : 0);
}

void BridgeSettingsSaveHUDSprintLayout(double x, double y, double size, double alpha) {
    gBridgeHUDSprintX = BridgeClampDouble(x, 0.0, 4096.0);
    gBridgeHUDSprintY = BridgeClampDouble(y, 0.0, 4096.0);
    gBridgeHUDSprintSize = BridgeClampDouble(size, 18.0, 120.0);
    gBridgeHUDSprintAlpha = BridgeClampDouble(alpha, 0.15, 1.0);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setDouble:gBridgeHUDSprintX forKey:BridgeSettingsHUDSprintXKey()];
    [defaults setDouble:gBridgeHUDSprintY forKey:BridgeSettingsHUDSprintYKey()];
    [defaults setDouble:gBridgeHUDSprintSize forKey:BridgeSettingsHUDSprintSizeKey()];
    [defaults setDouble:gBridgeHUDSprintAlpha forKey:BridgeSettingsHUDSprintAlphaKey()];
    [defaults synchronize];
    BridgeLog("settings saved hudSprintLayout=(%.1f,%.1f %.1f %.2f)",
              gBridgeHUDSprintX,
              gBridgeHUDSprintY,
              gBridgeHUDSprintSize,
              gBridgeHUDSprintAlpha);
}

void BridgeSettingsResetHUDSprintLayout(void) {
    BridgeSettingsSaveHUDSprintLayout(1620.0, 160.0, 90.0, 0.50);
}

void BridgeSettingsSaveSprintMode(BridgeSprintMode mode) {
    gBridgeSprintMode = mode == BridgeSprintModeToggle ? BridgeSprintModeToggle : BridgeSprintModeNative;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:(NSInteger)gBridgeSprintMode forKey:BridgeSettingsSprintModeKey()];
    [defaults synchronize];
    BridgeLog("settings saved sprintMode=%d", (int)gBridgeSprintMode);
}

void BridgeSettingsSaveSprintKeyCode(unsigned short keyCode) {
    if (keyCode == 0) {
        return;
    }

    gBridgeSprintKeyCode = keyCode;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:(NSInteger)keyCode forKey:BridgeSettingsSprintKeyCodeKey()];
    [defaults synchronize];
    BridgeLog("settings saved sprintKey=%u", keyCode);
}

const char *BridgeKeyName(unsigned short keyCode) {
    switch (keyCode) {
        case 0x04: return "A";
        case 0x05: return "B";
        case 0x06: return "C";
        case 0x07: return "D";
        case 0x08: return "E";
        case 0x09: return "F";
        case 0x0A: return "G";
        case 0x0B: return "H";
        case 0x0C: return "I";
        case 0x0D: return "J";
        case 0x0E: return "K";
        case 0x0F: return "L";
        case 0x10: return "M";
        case 0x11: return "N";
        case 0x12: return "O";
        case 0x13: return "P";
        case 0x14: return "Q";
        case 0x15: return "R";
        case 0x16: return "S";
        case 0x17: return "T";
        case 0x18: return "U";
        case 0x19: return "V";
        case 0x1A: return "W";
        case 0x1B: return "X";
        case 0x1C: return "Y";
        case 0x1D: return "Z";
        case 0x1E: return "1";
        case 0x1F: return "2";
        case 0x20: return "3";
        case 0x21: return "4";
        case 0x22: return "5";
        case 0x23: return "6";
        case 0x24: return "7";
        case 0x25: return "8";
        case 0x26: return "9";
        case 0x27: return "0";
        case 0x28: return "Return";
        case 0x29: return "Esc";
        case 0x2A: return "Backspace";
        case 0x2B: return "Tab";
        case 0x2C: return "Space";
        case 0x2D: return "-";
        case 0x2E: return "=";
        case 0x2F: return "[";
        case 0x30: return "]";
        case 0x31: return "\\";
        case 0x33: return ";";
        case 0x34: return "'";
        case 0x35: return "`";
        case 0x36: return ",";
        case 0x37: return ".";
        case 0x38: return "/";
        case 0x39: return "Caps";
        case 0x3A: return "F1";
        case 0x3B: return "F2";
        case 0x3C: return "F3";
        case 0x3D: return "F4";
        case 0x3E: return "F5";
        case 0x3F: return "F6";
        case 0x40: return "F7";
        case 0x41: return "F8";
        case 0x42: return "F9";
        case 0x43: return "F10";
        case 0x44: return "F11";
        case 0x45: return "F12";
        case 0x4F: return "Right";
        case 0x50: return "Left";
        case 0x51: return "Down";
        case 0x52: return "Up";
        case 0xE0: return "CTRL";
        case 0xE1: return "Shift";
        case 0xE2: return "Option";
        case 0xE3: return "Command";
        case 0xE4: return "R CTRL";
        case 0xE5: return "R Shift";
        case 0xE6: return "R Option";
        case 0xE7: return "R Command";
        default: return "Unknown";
    }
}
