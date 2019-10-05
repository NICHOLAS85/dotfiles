#include <clight/public.h>
#include <stdlib.h>

/**
 * Modified to not set brightness to 100% and toggle redshift gamma correction
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
 * Build with: gcc -shared -fPIC inhibit_bl_mod.c -o inhibit_bl_mod -Wno-unused
 *
 * Place inhibit_bl_mod in: $HOME/.local/share/clight/modules.d/ OR, globally, in /usr/share/clight/modules.d/
 */

CLIGHT_MODULE("INHIBIT_BL_MOD");

DECLARE_MSG(capture_req, CAPTURE_REQ);
DECLARE_MSG(calib_req, NO_AUTOCALIB_REQ);

static void init(void) {
    capture_req.capture.reset_timer = false; // avoid resetting clight internal BACKLIGHT timer

    /* Subscribe to inhibit state */
    M_SUB(INHIBIT_UPD);
}

static void receive(const msg_t *msg, const void *userdata) {
    switch (MSG_TYPE()) {
    case INHIBIT_UPD: {
        inhibit_upd *up = (inhibit_upd *)MSG_DATA();
        calib_req.nocalib.new = up->new;
        if (up->new) {
            M_PUB(&calib_req);                // stop backlight autocalibration
            system("killall -USR1 redshift"); // Toggle redshift if active
            INFO("Pausing autocalibration and redshift.\n");
        } else {
            INFO("Doing a quick backlight calibration and unpausing redshift.\n");
            system("killall -USR1 redshift"); // toggle redshift if active
            M_PUB(&calib_req);                // resume backlight autocalibration
            M_PUB(&capture_req);              // ask for a quick calibration
        }
        break;
    }
    default:
        break;
    }
}
