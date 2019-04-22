/*
 * Copyright (C) 2018 Vlad Zagorodniy <vladzzag@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

function interpolate(from, to, t) {
    return from * (1 - t) + to * t;
}

function morphRect(fromRect, toRect, t) {
    var targetScale = (toRect.width > toRect.height)
        ? toRect.width / fromRect.width
        : toRect.height / fromRect.height;
    var toCenter = {
        x: toRect.x + toRect.width / 2,
        y: toRect.y + toRect.height / 2
    };

    var targetRect = {
        x: toCenter.x - targetScale * fromRect.width / 2,
        y: toCenter.y - targetScale * fromRect.height / 2,
        width: targetScale * fromRect.width,
        height: targetScale * fromRect.height
    };

    var morphedRect = {
        x: interpolate(fromRect.x, targetRect.x, t),
        y: interpolate(fromRect.y, targetRect.y, t),
        width: interpolate(fromRect.width, targetRect.width, t),
        height: interpolate(fromRect.height, targetRect.height, t)
    };

    return morphedRect;
}

var minimizeScaleEffect = {
    duration: animationTime(200),
    minimizeScale: 0.4,
    unminimizeScale: 0.4,
    loadConfig: function () {
        "use strict";
        var duration = effect.readConfig("Duration", 200);
        if (duration == 0) {
            duration = 200;
        }
        minimizeScaleEffect.duration = animationTime(duration);
        minimizeScaleEffect.minimizeScale = effect.readConfig("MinimizeScale", 0.4);
        minimizeScaleEffect.unminimizeScale = effect.readConfig("UnminimizeScale", 0.4);
    },
    slotWindowMinimized: function (window) {
        "use strict";
        if (effects.hasActiveFullScreenEffect) {
            return;
        }

        var iconRect = window.iconGeometry;
        if (iconRect.width == 0 || iconRect.height == 0) {
            return;
        }

        var windowRect = window.geometry;
        if (windowRect.width == 0 || windowRect.height == 0) {
            return;
        }

        if (window.unminimizeAnimation) {
            cancel(window.unminimizeAnimation);
            delete window.unminimizeAnimation;
        }

        var targetRect = morphRect(windowRect, iconRect, 1.0 - minimizeScaleEffect.minimizeScale);

        window.minimizeAnimation = animate({
            window: window,
            curve: QEasingCurve.InOutSine,
            duration: minimizeScaleEffect.duration,
            animations: [
                {
                    type: Effect.Size,
                    from: {
                        value1: windowRect.width,
                        value2: windowRect.height
                    },
                    to: {
                        value1: targetRect.width,
                        value2: targetRect.height
                    }
                },
                {
                    type: Effect.Translation,
                    from: {
                        value1: 0.0,
                        value2: 0.0
                    },
                    to: {
                        value1: targetRect.x - windowRect.x - (windowRect.width - targetRect.width) / 2,
                        value2: targetRect.y - windowRect.y - (windowRect.height - targetRect.height) / 2
                    }
                },
                {
                    type: Effect.Opacity,
                    from: 1.0,
                    to: 0.0
                }
            ]
        });
    },
    slotWindowUnminimized: function (window) {
        "use strict";
        if (effects.hasActiveFullScreenEffect) {
            return;
        }

        var iconRect = window.iconGeometry;
        if (iconRect.width == 0 || iconRect.height == 0) {
            return;
        }

        var windowRect = window.geometry;
        if (windowRect.width == 0 || windowRect.height == 0) {
            return;
        }

        if (window.minimizeAnimation) {
            cancel(window.minimizeAnimation);
            delete window.minimizeAnimation;
        }

        var targetRect = morphRect(windowRect, iconRect, 1.0 - minimizeScaleEffect.unminimizeScale);

        window.unminimizeAnimation = animate({
            window: window,
            curve: QEasingCurve.InOutSine,
            duration: minimizeScaleEffect.duration,
            animations: [
                {
                    type: Effect.Size,
                    from: {
                        value1: targetRect.width,
                        value2: targetRect.height
                    },
                    to: {
                        value1: windowRect.width,
                        value2: windowRect.height
                    }
                },
                {
                    type: Effect.Translation,
                    from: {
                        value1: targetRect.x - windowRect.x - (windowRect.width - targetRect.width) / 2,
                        value2: targetRect.y - windowRect.y - (windowRect.height - targetRect.height) / 2
                    },
                    to: {
                        value1: 0.0,
                        value2: 0.0
                    }
                },
                {
                    type: Effect.Opacity,
                    from: 0.0,
                    to: 1.0
                }
            ]
        });
    },
    init: function () {
        "use strict";
        effect.configChanged.connect(minimizeScaleEffect.loadConfig);
        effects.windowMinimized.connect(minimizeScaleEffect.slotWindowMinimized);
        effects.windowUnminimized.connect(minimizeScaleEffect.slotWindowUnminimized);
    }
};

minimizeScaleEffect.init();
