#pragma once

#import "../BridgeTypes.h"

void ReplacementViewWillDisappear(id self, SEL _cmd, BOOL animated);
void ReplacementViewDidAppear(id self, SEL _cmd, BOOL animated);
BOOL ReplacementPrefersPointerLocked(id self, SEL _cmd);
void ReplacementSetNeedsUpdateOfPrefersPointerLocked(id self, SEL _cmd);
void ReplacementOnTextInputBegan(id self, SEL _cmd, id sender);
void ReplacementOnTextInputEnded(id self, SEL _cmd, id sender);
id ReplacementChildViewControllerForPointerLock(id self, SEL _cmd);
id ReplacementPointerRegionForRequest(id self, SEL _cmd, id interaction, id request, id defaultRegion);
bool ShouldSuppressTouchFallback(id self, id event);
void ReplacementTouchesBegan(id self, SEL _cmd, id touches, id event);
void ReplacementTouchesMoved(id self, SEL _cmd, id touches, id event);
void ReplacementTouchesEnded(id self, SEL _cmd, id touches, id event);
void ReplacementTouchesCancelled(id self, SEL _cmd, id touches, id event);
