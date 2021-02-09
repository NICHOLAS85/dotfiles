#include <clight/public.h>
#include <stdlib.h>
#include <time.h>

/**
 * Small example custom module for Clight.
 *
 * It just hooks on INHIBIT state updates and:
 * -> when entering INHIBIT state (eg: start watching a movie), disables automatic calibration,
 *    set low kbd brightness and timeout, and pauses any gamma adjustment
 * -> when leaving INHIBIT state, triggers a new backlight calibration and re-enables automatic calibration,
 *    unpauses gamma adjustment, and restores kbd timeout
 **/

/*
 * Rename to: inhibit_mod.c
 *
 * Build with: gcc -shared -fPIC inhibit_mod.c -o inhibit_mod -Wno-unused
 *
 * Place inhibit_bl_mod in: $HOME/.local/share/clight/modules.d/ OR, globally, in /usr/share/clight/modules.d/
 */

CLIGHT_MODULE("INHIBIT_MOD");

DECLARE_MSG(capture_req, CAPTURE_REQ);
DECLARE_MSG(calib_req, NO_AUTOCALIB_REQ);
DECLARE_MSG(kbd_bl_req, KBD_BL_REQ);
DECLARE_MSG(kbd_to_req, KBD_TO_REQ);

bool in_event = false;
bool first_run_temp = true;
bool first_run_event = true;
int default_step = 50;
int default_timeout = 150;
double kbd_lev = 1.0;
int saved_temp = 6500;
int longtran_begin = 0;

time_t now;
int end_time;

static void init(void) {
    capture_req.capture.reset_timer = false; // avoid resetting clight internal BACKLIGHT timer
    kbd_bl_req.bl.new = 0.5;                 // 50% keyboard brightness

    M_SUB(INHIBIT_UPD);  // inhibit state
    M_SUB(TEMP_UPD);     // temperature levels
    M_SUB(KBD_BL_UPD);   // keyboard backlight levels
    M_SUB(IN_EVENT_UPD); // event state
}

static void receive(const msg_t *msg, const void *userdata) {
    switch (MSG_TYPE()) {
    case INHIBIT_UPD: {
        inhibit_upd *up = (inhibit_upd *)MSG_DATA();
        calib_req.nocalib.new = up->new;
        DECLARE_HEAP_MSG(temp_req, TEMP_REQ);
        temp_req->temp.smooth = 1;                // smooth mode
        temp_req->temp.step = default_step;       // default step
        temp_req->temp.timeout = default_timeout; // default timeout
        if (up->new) {
            INFO("Pausing autocalibration and night color.\n");
            if (kbd_lev >= 0.75) {
                M_PUB(&kbd_bl_req);      // set 50% kbd brightness if kbd above 50%
            }
            kbd_to_req.to.new = 2;       // set 2 second kbd backlight timeout
            temp_req->temp.daytime = -1; // affect current daytime
            temp_req->temp.new = 6500;   // day gamma value
        } else {
            INFO("Doing a quick backlight calibration and unpausing night color.\n");
            kbd_to_req.to.new = 10;   // set 10 second timeout, causes keyboard to wake
            M_PUB(&capture_req);      // ask for a quick calibration, sets kbd to proper brightness
            first_run_event = true;   // ignore first TEMPUPD temp
            if (in_event) {
                DEBUG("Restoring pre-inhibit temp\n");
                temp_req->temp.daytime = -1;     // could be day or night, adjust current daytime
                temp_req->temp.new = saved_temp; // pre-inhibit gamma value
                longtran_begin = saved_temp;     // long transition after saved_temp
            } else {
                temp_req->temp.daytime = NIGHT;  // only affect night gamma
                temp_req->temp.new = 4200;       // night gamma value
                longtran_begin = 0;              // no long transition
            }
        }
        M_PUB(temp_req);   // set gamma
        M_PUB(&calib_req); // stop or start backlight autocalibration
        M_PUB(&kbd_to_req);
        break;
    }
    case TEMP_UPD: {
        temp_upd *up = (temp_upd *)MSG_DATA();

        // set some default values on first run
        if (first_run_temp && ! in_event) {
            default_step = up->step;
            default_timeout = (up->timeout / 2);
            first_run_temp = false;
        }

        // ignore all temps set when inhibited
        // ignore first temp set during an event
        if (! calib_req.nocalib.new) {
            if (! first_run_event) {
                saved_temp = up->new;
            }
        }
        DEBUG("New temp: %d, Saved temp: %d, Step: %d, Timeout: %d\n", up->new, saved_temp, up->step, up->timeout);
        if (longtran_begin != 0 && longtran_begin >= up->new && ! first_run_event){
            DEBUG("Begin long transition\n");
            DECLARE_HEAP_MSG(long_temp_req, TEMP_REQ);
            long_temp_req->temp.daytime = -1;              // could be day or night, adjust current daytime
            long_temp_req->temp.new = 4200;                // night gamma value
            long_temp_req->temp.smooth = 1;                // use current smooth mode
            time(&now);
            auto int remaining_time = (end_time - now );
            long_temp_req->temp.step = (( up->new - 4200) / (remaining_time/10)); // determine step from remaining time and gamma
            long_temp_req->temp.timeout = 10000;              // timeout of 10s
            longtran_begin = 0;
            M_PUB(long_temp_req);
        }
        first_run_event = false;
        break;
    }
    case IN_EVENT_UPD: {
        in_event = ! in_event;
        if (in_event) {
            time(&now);
            end_time = ( now + 3600); // determine when event will end for transition calculations
        } else {
            first_run_event = true;   // reset first_run for next round
        }
        break;
    }
    case KBD_BL_UPD: {
        bl_upd *up = (bl_upd *)MSG_DATA();
        kbd_lev = up->new; // save keyboard backlight level
        break;
    }
    default:
        break;
    }
}
