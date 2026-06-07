#pragma once

#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>
#import <objc/runtime.h>
#import <stdarg.h>
#import <stdbool.h>
#import <stddef.h>
#import <stdint.h>

#ifndef MC_KEYBOARD_BRIDGE_VERBOSE
#define MC_KEYBOARD_BRIDGE_VERBOSE 0
#endif

typedef bool (*CGEventSourceKeyStateFn)(int stateID, unsigned short keyCode);
typedef void (*CGGetLastMouseDeltaFn)(int32_t *deltaX, int32_t *deltaY);
typedef uint32_t (*CGEventSourceCounterForEventTypeFn)(int stateID, uint32_t eventType);
typedef bool (*CGEventSourceButtonStateFn)(int stateID, int button);
typedef void *CGEventTapProxyOpaque;
typedef void *CGEventRefOpaque;
typedef CGEventRefOpaque (*CGEventTapCallbackFn)(CGEventTapProxyOpaque proxy, uint32_t type, CGEventRefOpaque event, void *refcon);
typedef CFMachPortRef (*CGEventTapCreateFn)(uint32_t tap, uint32_t place, uint32_t options, uint64_t eventsOfInterest, CGEventTapCallbackFn callback, void *refcon);
typedef int64_t (*CGEventGetIntegerValueFieldFn)(CGEventRefOpaque event, int32_t field);
typedef void (*CGEventTapEnableFn)(CFMachPortRef tap, bool enable);

typedef struct {
    double x;
    double y;
} BridgeCGPoint;

typedef struct {
    double width;
    double height;
} BridgeCGSize;

typedef struct {
    BridgeCGPoint origin;
    BridgeCGSize size;
} BridgeCGRect;

typedef int32_t (*CGAssociateMouseAndMouseCursorPositionFn)(int connected);
typedef int32_t (*CGDisplayHideCursorFn)(uint32_t display);
typedef int32_t (*CGDisplayShowCursorFn)(uint32_t display);
typedef int32_t (*CGWarpMouseCursorPositionFn)(BridgeCGPoint point);
typedef uint32_t (*CGMainDisplayIDFn)(void);
typedef BridgeCGRect (*CGDisplayBoundsFn)(uint32_t display);

typedef struct {
    Class cls;
    SEL sel;
    IMP original;
} HookEntry;

typedef enum {
    BridgeHUDElementNone = 0,
    BridgeHUDElementSprintStatus = 1,
} BridgeHUDElement;
