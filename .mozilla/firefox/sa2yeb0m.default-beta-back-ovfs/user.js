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
user_pref("gfx.webrender.all", false);
user_pref("layers.acceleration.force-enabled", true);
user_pref("browser.tabs.remote.force-enable", true);

/* Fix dark widgets with dark theme */
user_pref("widget.content.gtk-theme-override", "Minwaita:light");

/* Allow tabs to shrink more; tabs in overflow will look the same as pinned tabs */
user_pref("materialFox.reduceTabOverflow", true);

/* Disable Pocket */
user_pref("extensions.pocket.enabled", false);

/* Enable VA-API Acceleration */
user_pref("media.ffvpx.enabled", false);
user_pref("media.ffmpeg.vaapi-drm-display.enabled", true);
user_pref("media.ffmpeg.vaapi.enabled", true);
user_preg("widget.wayland-dmabuf-vaapi.enabled", true);

/* Allow smooth zooming */
user_pref("apz.allow_zooming", true);
