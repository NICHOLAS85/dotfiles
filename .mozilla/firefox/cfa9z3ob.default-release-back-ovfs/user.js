/* enable userChrome.css */
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("svg.context-properties.content.enabled", true);

/* Allow tabs to shrink more; tabs in overflow will look the same as pinned tabs */
user_pref("materialFox.reduceTabOverflow", true);

/* Disable Pocket and screenshots */
user_pref("extensions.pocket.enabled", false);
user_pref("extensions.screenshots.disabled", true);

/* Enable VA-API Acceleration */
user_pref("gfx.webrender.all", true);
user_pref("gfx.webrender.compositor.force-enabled", true);
user_pref("media.ffmpeg.vaapi.enabled", true);
user_pref("media.ffvpx.enabled", false);
user_pref("media.rdd-vpx.enabled", false);
user_pref("media.navigator.mediadatadecoder_vpx_enabled", true);

/* Faster Pageload extension */
user_pref("network.dns.disablePrefetchFromHTTPS", false);
user_pref("network.predictor.enable-prefetch", true);

/* Use xdg-desktop-portal */
user_pref("widget.use-xdg-desktop-portal", true);

/* Allow blurry stuff*/
user_pref("layout.css.backdrop-filter.enabled", true);
/* Fix context menu highlight */
user_pref("layout.css.color-mix.enabled", true);

/* Enable noscript sync*/
user_pref("services.sync.prefs.sync.capability.policy.maonoscript.sites", true);
user_pref("noscript.sync.enabled", true);

/* Potential stutter fix set to higher than 1 */
//user_pref("dom.ipc.processCount.file", 2);
