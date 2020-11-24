#include <clight/public.h>
#include <stdlib.h>

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
double cont = 1.0;

static void init(void) {
    capture_req.capture.reset_timer = false; // avoid resetting clight internal BACKLIGHT timer
    temp_req.temp.smooth = -1;               // use current smooth mode
    temp_req.temp.daytime = NIGHT;           // only affect night gamma
    kbd_bl_req.bl.new = 0.5;                 // set kbd 50% brightness during inhibition

    /* Subscribe to inhibit and kbd_bl state */
    M_SUB(INHIBIT_UPD);
    M_SUB(KBD_BL_UPD);
}

static void kbd_timeout(char* timeout) {
    char cmd[128];
    snprintf(cmd, sizeof(cmd), "echo %s | sudo /usr/bin/tee /sys/devices/platform/dell-laptop/leds/dell::kbd_backlight/stop_timeout", timeout);
    system(cmd);
}

static void receive(const msg_t *msg, const void *userdata) {
    switch (MSG_TYPE()) {
    case KBD_BL_UPD: {
        bl_upd *up = (bl_upd *)MSG_DATA();
        cont = up->new;
        break;
    }
    case INHIBIT_UPD: {
        inhibit_upd *up = (inhibit_upd *)MSG_DATA();
        calib_req.nocalib.new = up->new;
        if (up->new) {
            INFO("Pausing autocalibration and night color.\n");
            if (cont > 0) { M_PUB(&kbd_bl_req) }; // set 50% kbd backlight
            kbd_timeout("2s");                    // set short timeout
            temp_req.temp.new = 6500;
        } else {
            INFO("Doing a quick backlight calibration and unpausing night color.\n");
            kbd_timeout("10s");  // set default timeout
            M_PUB(&capture_req); // ask for a quick calibration
            temp_req.temp.new = 4200;
        }
        M_PUB(&temp_req);  // set gamma value
        M_PUB(&calib_req); // stop or start backlight autocalibration
        break;
    }
    default:
        break;
    }
}
