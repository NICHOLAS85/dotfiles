/* enable userChrome.css */
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("svg.context-properties.content.enabled", true);

/* Move disk cache to RAM */
user_pref("browser.cache.disk.parent_directory", "/run/user/1000/firefox");

/* Touchscreen firefox stuff */
user_pref("browser.gesture.pinch.in", "");
user_pref("browser.gesture.pinch.out", "");
user_pref("dom.w3c_touch_events.enabled", 1);
user_pref("dom.w3c_touch_events.legacy_apis.enabled", true);
user_pref("ui.touch.radius.enabled", true);

/* Faster firefox? */
user_pref("gfx.canvas.azure.accelerated", true);
user_pref("gfx.webrender.all", true);
user_pref("layers.acceleration.force-enabled", true);
user_pref("browser.tabs.remote.force-enable", true);

/* Fix dark widgets with dark theme */
user_pref("widget.content.gtk-theme-override", "Minwaita:light");

/* Allow tabs to shrink more; tabs in overflow will look the same as pinned tabs */
user_pref("materialFox.reduceTabOverflow", true);

/* Disable Pocket and screenshots */
user_pref("extensions.pocket.enabled", false);
user_pref("extensions.screenshots.disabled". true);

/* Enable VA-API Acceleration */
user_pref("media.ffvpx.enabled", false);
user_pref("media.ffmpeg.vaapi-drm-display.enabled", true);
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("widget.wayland-dmabuf-vaapi.enabled", true);
user_pref("media.ffmpeg.low-latency.enabled", true);
user_pref("media.navigator.mediadatadecoder_vpx_enabled", true);

/* Allow smooth zooming */
user_pref("apz.allow_zooming", true);

/* Disable regular zoom function */
user_pref("zoom.maxPercent", 100);
user_pref("zoom.minPercent", 100);

/* Increase scroll speed */
user_pref("mousewheel.default.delta_multiplier_y", 200);
user_pref("general.autoScroll", true);
user_pref("general.smoothScroll.msdPhysics.enabled", false);
//user_pref("general.smoothScroll.mouseWheel.migrationPercent", 0);
user_pref("apz.gtk.kinetic_scroll.enabled", false); // make trackpad scrolling less floaty

/* Faster Pageload extension */
user_pref("network.dns.disablePrefetchFromHTTPS", false);
user_pref("network.predictor.enable-prefetch", true);

/* Up refresh rate */
user_pref("layout.frame_rate", 75);
