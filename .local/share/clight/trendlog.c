#include <clight/public.h>
#include <stdlib.h>
#include <pwd.h>
#include <sys/stat.h>

CLIGHT_MODULE("TRENDLOG");

/*
 * Rename to: trendlog.c
 *
 * Build with: gcc -shared -fPIC trendlog.c -o trendlog -Wno-unused
 *
 * Place trendlog in: $HOME/.local/share/clight/modules.d/ OR, globally, in /usr/share/clight/modules.d/
 */

static bool clightBLCTRL = false; // Set to true if you are using Clight's dbus interface to inc/dec backlight level

static int mode = 0;
static bool skip = true;
static double bl_level = 0;
static char logpath[100], cmd[200];

static void init(void) {
    /**
     * Subscribe to the following events
     * Ambient Brightness updates: Log Ambient Br and BlPct on each capture
     * AC state updates: Log to file depending on if AC/BAT/Neither
     * Display state updates: Skip log if previously dimmed or off.
     * Inhibition updates: Skip log if previously inhibited
     * Lid state updates: Skip log if lid previously closed
     * Backlight level updates: Conditionally use Clight provided backlight level
     **/

    M_SUB(AMBIENT_BR_UPD);
    M_SUB(UPOWER_UPD);
    M_SUB(DISPLAY_UPD);
    M_SUB(INHIBIT_UPD);
    M_SUB(LID_UPD);
    if(clightBLCTRL) M_SUB(BL_UPD);

    if (getenv("XDG_CACHE_HOME")) {
        sprintf(logpath, "%s/clight-trendlog/", getenv("XDG_CACHE_HOME"));
    } else {
        sprintf(logpath,"%s/.cache/clight-trendlog/", getpwuid(getuid())->pw_dir);
    }
    mkdir(logpath, 0755);
    INFO("Logging AmbientBr and BlPct into %s\n", logpath);
}

static void receive(const msg_t *msg, const void *userdata) {
    switch (MSG_TYPE()) {
        case AMBIENT_BR_UPD: {
            bl_upd *up = (bl_upd *)MSG_DATA();

            if (!skip){
                    // TODO: Figure out a per-monitor solution instead of first detected
                    if (clightBLCTRL){
                        sprintf(cmd, "echo '%.3lf %.3lf' >> %s%sdata", up->new, bl_level, logpath, mode ? "AC-" : "BAT-");
                    } else {
                        sprintf(cmd, "busctl call org.clightd.clightd /org/clightd/clightd/Backlight org.clightd.clightd.Backlight Get s '' | awk '{print \"%.3lf \"$4}' >> %s%sdata", up->new, logpath, mode ? "AC-" : "BAT-");
                    }
                    system(cmd);
                    DEBUG("Ran %s\n", cmd);
            }
            skip = false;
            break;
        }
        case UPOWER_REQ: {
            upower_upd *up = (upower_upd *)MSG_DATA();
            mode = up->new == ON_AC ? 1 : 0;
            break;
        }
        case DISPLAY_UPD: {
            display_upd *up = (display_upd *)MSG_DATA();
            // TODO: Impliment logic for dimmed and queued capture specifically,
            // this just skips the next capture regardless of if it was queued or not
            if(up->old == DISPLAY_DIMMED || up->old == DISPLAY_OFF){
                    skip = true;
                    DEBUG("Skipping next log\n");
            }
            break;
        }
        case INHIBIT_UPD: {
            inhibit_upd *up = (inhibit_upd *)MSG_DATA();
            skip = up->old;
            if(skip) DEBUG("Skipping next log\n");
            break;
        }
        case LID_UPD: {
            lid_upd *up = (lid_upd *)MSG_DATA();
            if (up->old == CLOSED){
                    skip = true;
                    DEBUG("Skipping next log\n");
            }
            break;
        }
        case BL_UPD: {
            bl_upd *up = (bl_upd *)MSG_DATA();
            bl_level=up->new;
            break;
        }
        default:
            break;
        }
}
