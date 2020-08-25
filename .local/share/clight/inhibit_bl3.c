#include <clight/public.h>

/**
 * Modified to not set brightness to 100% and toggle gamma correction
 **/

/**
 * Small example custom module for Clight.
 *
 * It just hooks on INHIBIT state updates and:
 * -> when entering INHIBIT state (eg: start watching a movie), disables automatic calibration, switch off kbd backlight, pause night color
 * -> when leaving INHIBIT state, triggers a new backlight calibration and re-enables automatic calibration, unpause night color
 **/

/*
 * Rename to: inhibit_bl3.c
 *
 * Build with: gcc -shared -fPIC inhibit_bl3.c -o inhibit_bl3 -Wno-unused
 *
 * Place inhibit_bl_mod in: $HOME/.local/share/clight/modules.d/ OR, globally, in /usr/share/clight/modules.d/
 */

CLIGHT_MODULE("INHIBIT_BL");

DECLARE_MSG(capture_req, CAPTURE_REQ);
DECLARE_MSG(calib_req, NO_AUTOCALIB_REQ);
DECLARE_MSG(kbd_bl_req, KBD_BL_REQ);
DECLARE_MSG(temp_req, TEMP_REQ);

static void init(void) {
    capture_req.capture.reset_timer = false; // avoid resetting clight internal BACKLIGHT timer
    kbd_bl_req.bl.new = 0.0;
    temp_req.temp.smooth = -1;
    temp_req.temp.daytime = NIGHT;
    
    /* Subscribe to inhibit state */
    M_SUB(INHIBIT_UPD);
}

static void receive(const msg_t *msg, const void *userdata) {
    switch (MSG_TYPE()) {
    case INHIBIT_UPD: {
        inhibit_upd *up = (inhibit_upd *)MSG_DATA();
        calib_req.nocalib.new = up->new;
        if (up->new) {
            INFO("Pausing autocalibration and night color.\n");
            M_PUB(&kbd_bl_req);  // set 0% kbd backlight
            temp_req.temp.new = 6500;
        } else {
            INFO("Doing a quick backlight calibration and unpausing night color.\n");
            M_PUB(&capture_req); // ask for a quick calibration
            temp_req.temp.new = 4200;
        }
        M_PUB(&temp_req);
        M_PUB(&calib_req); // stop or start backlight autocalibration
        break;
    }
    default:
        break;
    }
}
