#pragma once
#include <stdbool.h>

// The layer's trackpad state machine: the platform's TouchTrackpad.h/.c as they were at Tolkara
// 00a8501, kept here with their names prefixed (AKLayerTrackpad...) so that both can be in the
// same library. Tolkara edc3628 changed the platform's machine - a one-finger hold right-clicks
// instead of starting a left drag, a double tap and hold drags with the right button, motion is
// scaled by a speed-dependent gain and eased in - and the layer's controls (the toolbar
// trackpad, the direct camera in TouchCameraGesture.m and the controller touchpad pointer in
// ControllerPointer.m) were tuned and measured on devices against the old rules. Adopting the
// new rules is a product decision of its own, to be made with a device run; until then the
// layer keeps the rules it shipped with.
//
// Direct finger input only. Coordinates/deltas are UIKit points (y down).
// The state machine does not inspect a guest or generate input on its own.
typedef enum { AKLayerTrackpadMove, AKLayerTrackpadScroll, AKLayerTrackpadDown, AKLayerTrackpadUp } AKLayerTrackpadAction;
typedef void (*AKLayerTrackpadEmit)(void *context, AKLayerTrackpadAction action, double x, double y, unsigned button);
typedef struct {
    unsigned fingers, peak;
    double x, y, started, travelled, scrollX, scrollY;
    bool blocked, lifting, dragging;
    unsigned button;
} AKLayerTrackpad;

void AKLayerTrackpadUpdate(AKLayerTrackpad *pad, unsigned fingers, double x, double y, double time,
                          AKLayerTrackpadEmit emit, void *context);
void AKLayerTrackpadHold(AKLayerTrackpad *pad, double time, AKLayerTrackpadEmit emit, void *context);
// Suppress the remainder of a cancelled gesture until every finger is lifted.
void AKLayerTrackpadCancel(AKLayerTrackpad *pad, AKLayerTrackpadEmit emit, void *context);
