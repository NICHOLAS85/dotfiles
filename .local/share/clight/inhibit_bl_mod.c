#include <clight/public.h>

/**
 * Modified to not set brightness to 100%
 **/

/**
 * Small example custom module for Clight.
 * 
 * It just hooks on INHIBIT state updates and:
 * -> when entering INHIBIT state (eg: start watching a movie), sets 100% backlight and disable automatic calibration.
 * -> when leaving INHIBIT state, triggers a new backlight calibration and re-enables automatic calibration
 **/

/*
 * Rename to: inhibit_bl_mod.c
 * 
 * Build with: gcc -shared -fPIC inhibit_bl.c -o inhibit_bl -Wno-unused
 * 
 * Place inhibit_bl_mod in: $HOME/.local/share/clight/modules.d/ OR, globally, in /usr/share/clight/modules.d/
 */

CLIGHT_MODULE("INHIBIT_BL_MOD");

//DECLARE_MSG(bl_req, BL_REQ);
DECLARE_MSG(capture_req, CAPTURE_REQ);
DECLARE_MSG(calib_req, NO_AUTOCALIB_REQ);

static void init(void) {
    capture_req.capture.reset_timer = false; // avoid resetting clight internal BACKLIGHT timer
    //bl_req.bl.new = 1.0;    // 100% screen backlight
    //bl_req.bl.smooth = -1;  // use conf values
    
    /* Subscribe to inhibit state */
    M_SUB(INHIBIT_UPD);
}

static void receive(const msg_t *msg, const void *userdata) {
    switch (MSG_TYPE()) {
    case INHIBIT_UPD: {
        inhibit_upd *up = (inhibit_upd *)MSG_DATA();
        calib_req.nocalib.new = up->new;
        if (up->new) {
            M_PUB(&calib_req);      // stop backlight autocalibration
            //M_PUB(&bl_req);         // set 100% screen backlight
            INFO("We are now inhibited! Pausing autocalibration.\n");
        } else {
            INFO("We're not inhibited anymore. Do a quick backlight calibration.\n");
            M_PUB(&calib_req);      // resume backlight autocalibration
            M_PUB(&capture_req);    // ask for a quick calibration
        }
        break;
    }
    default:
        break;
    }
}
