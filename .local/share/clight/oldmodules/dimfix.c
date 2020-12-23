#include <clight/public.h>
#include <stdlib.h>

/**
 * Small example custom module for Clight.
 *
 * It just hooks on DISPLAY state updates and:
 * -> when entering DIMMED state, saves current bl_pct
 * -> when leaving DIMMED state, restores saved bl_pct
 **/

/*
 * Rename to: dimfix.c
 *
 * Build with: gcc -shared -fPIC dimfix.c -o inhibit_bl3 -Wno-unused
 *
 * Place dimfix in: $HOME/.local/share/clight/modules.d/ OR, globally, in /usr/share/clight/modules.d/
 */

CLIGHT_MODULE("DIMFIX");

DECLARE_MSG(bl_req, BL_REQ);

static FILE *fp;
static char path[20];
static double new = 0;

static void init(void) {
	bl_req.bl.smooth = -1;
    /* Subscribe to inhibit state */
    M_SUB(DISPLAY_UPD);
    M_SUB(BL_UPD);
}

static void receive(const msg_t *msg, const void *userdata) {
    switch (MSG_TYPE()) {
    case DISPLAY_UPD: {
        display_upd *up = (display_upd *)MSG_DATA();
        if(up->new == DISPLAY_DIMMED){
            fp = popen("busctl call org.clightd.clightd /org/clightd/clightd/Backlight org.clightd.clightd.Backlight GetAll s '' | awk '{print$4}'", "r");
            while (fgets(path, sizeof(path), fp) != NULL) {
                bl_req.bl.new = atof(path);
                DEBUG("Saved bl_pct as: %s", path);
            }
            pclose(fp);
        }
        if(up->old == DISPLAY_DIMMED && bl_req.bl.new > new){
            DEBUG("Restoring bl_pct\n");
            M_PUB(&bl_req);
        }
        new = 0;
        break;
    }
    case BL_UPD: {
        bl_upd *up = (bl_upd *)MSG_DATA();
        new = up->new;
        break;
    }
    default:
        break;
    }
}
