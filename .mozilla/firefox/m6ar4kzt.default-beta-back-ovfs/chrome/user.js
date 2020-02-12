/* enable userChrome.css */
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("svg.context-properties.content.enabled", true);

/* Disable browser write to disk */
user_pref("browser.cache.disk.enable", false);

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

/* Fix dark widgets with dark theme */
user_pref("widget.content.gtk-theme-override", "Breeze:light");
