#import "ControllerPointer.h"
#include <string.h>

typedef struct {
    AKLayerTrackpadEmit emit;
    void *_Nullable context;
} AKControllerPointerSink;

// Movement and scrolling pass through; the presses a tap or a hold would make do not. See the
// header for why a controller's touchpad does not tap to click.
static void AKControllerPointerMotionOnly(void *context, AKLayerTrackpadAction action, double x, double y,
                                          unsigned button) {
    AKControllerPointerSink *sink = context;
    if (action == AKLayerTrackpadDown || action == AKLayerTrackpadUp) return;
    sink->emit(sink->context, action, x, y, button);
}

void AKControllerPointerUpdate(AKControllerPointer *pointer, unsigned fingers, double x, double y,
                               double time, AKLayerTrackpadEmit emit, void *context) {
    if (!pointer || !emit) return;
    AKControllerPointerSink sink = { emit, context };
    AKLayerTrackpadUpdate(&pointer->pad, fingers, x, y, time, AKControllerPointerMotionOnly, &sink);
}

void AKControllerPointerClick(AKControllerPointer *pointer, bool pressed, AKLayerTrackpadEmit emit,
                              void *context) {
    if (!pointer || !emit || pressed == pointer->clicked) return;
    if (pressed) {
        // Decided once, at the press: the release has to name the button the press named, even
        // if a finger came or went in between.
        pointer->button = pointer->pad.fingers >= 2 ? 1 : 0;
        pointer->clicked = true;
        emit(context, AKLayerTrackpadDown, 0, 0, pointer->button);
    } else {
        pointer->clicked = false;
        emit(context, AKLayerTrackpadUp, 0, 0, pointer->button);
    }
}

void AKControllerPointerReset(AKControllerPointer *pointer, AKLayerTrackpadEmit emit, void *context) {
    if (!pointer) return;
    if (pointer->clicked && emit) emit(context, AKLayerTrackpadUp, 0, 0, pointer->button);
    memset(pointer, 0, sizeof *pointer);
}
