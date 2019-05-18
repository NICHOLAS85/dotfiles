#!/bin/bash
if [[ $(qdbus org.kde.KWin /Compositor active) = "false" ]]; then
    qdbus org.kde.KWin /Compositor resume
fi
akbl --on
