#include <clight/public.h>

/**
 * Modified to not set brightness to 100% and toggle gamma correction
 **/

/**
 * Small example custom module for Clight.
 *
 * It just hooks on LID state updates and:
 * -> when lid opens, run a capture and calibration
 **/

/*
 * Rename to: lidopen.c
 *
 * Build with: gcc -shared -fPIC lidopen.c -o lidopen -Wno-unused
 *
 * Place lidopen in: $HOME/.local/share/clight/modules.d/ OR, globally, in /usr/share/clight/modules.d/
 */

CLIGHT_MODULE("LIDOPEN");

DECLARE_MSG(capture_req, CAPTURE_REQ);

static void init(void) {
    capture_req.capture.reset_timer = true; // reset clight internal BACKLIGHT timer

    /* Subscribe to inhibit state */
    M_SUB(LID_UPD);
}

static void receive(const msg_t *msg, const void *userdata) {
    switch (MSG_TYPE()) {
    case LID_UPD: {
        lid_upd *up = (lid_upd *)MSG_DATA();
        if (up->new == OPEN) {
            INFO("Doing a quick backlight calibration\n");
            M_PUB(&capture_req); // ask for a quick calibration
        }
        break;
    }
    default:
        break;
    }
}
