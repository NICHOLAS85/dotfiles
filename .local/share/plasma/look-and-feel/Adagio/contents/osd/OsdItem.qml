/* THIS IS A MODIFIED VERSION
 * 
 * Copyright 2014 Martin Klapetek <mklapetek@kde.org> (Original)
 * Copyright 2019 Koneko-Nyaa (Changes)
 * Thanks to Chris Holland <zrenfire@gmail.com> for inspiration.
 * 
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.4
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtra
import QtQuick.Window 2.2

Item {
    property QtObject rootItem
    //Use a Medium Size icon (Smaller than Original)
    property int iconWidth: units.iconSizes.medium
    //Variable to use for padding (1/10 icon size)
    property int spacer: Math.round(units.iconSizes.medium/10)
    //Determine a suitable fixed width for progress bar based on screen width
    property int progressBarWidth: Math.round(Screen.width/750)*100
    //Width of label displaying percentage
    property int labelWidthP: labelMetricsP.boundingRect.width
    //Width of label showing text
    property int labelWidthT: labelMetricsT.boundingRect.width
    //Width of OSD based on Icon + Progress Bar + Progress Text + Padding
    property int itemWidthP: iconWidth + spacer*3 + progressBarWidth + labelWidthP
    //Width of OSD based on Icon + Message Text + Padding
    property int itemWidthT: iconWidth + spacer*3 + labelWidthT
    
    //Set OSD height to the height of a medium size icon
    height: iconWidth
    //Set OSD width as determined above depending on whether progress or message is shown
    width: rootItem.showingProgress ? itemWidthP : ((itemWidthP > itemWidthT) ? itemWidthP : itemWidthT)

    //Determine how wide the percentage label needs to be
    TextMetrics {
        id: labelMetricsP
        font: label.font
        text: "000."
    }

    //Determine how wide the message label needs to be
    TextMetrics {
        id: labelMetricsT
        font: label.font
        text: rootItem.osdValue ? rootItem.osdValue : ""
    }

    //Set icon size as determined above
    PlasmaCore.IconItem {
        id: icon
        height: parent.height
        width: iconWidth
        source: rootItem.icon
    }

    //Set Progress Bar Size, Position, and Value
    PlasmaComponents.ProgressBar {
        id: progressBar
        width: progressBarWidth
        height: parent.height
        x: iconWidth + spacer*2
        visible: rootItem.showingProgress
        minimumValue: 0
        maximumValue: 100
        value: Number(rootItem.osdValue)
    }

    //Set Text Size, Position, and Value depending on whether progress or message is shown
    PlasmaExtra.Heading {
        id: label
        x: rootItem.showingProgress ? (itemWidthP - labelWidthP) : (iconWidth + spacer)
        width: rootItem.showingProgress ? labelWidthP : (rootItem.width - label.x - spacer*2)
        height: parent.height
        visible: true
        text: rootItem.showingProgress ? rootItem.osdValue : (rootItem.osdValue ? rootItem.osdValue : "")
        horizontalAlignment: Text.AlignHCenter
        maximumLineCount: 1
        elide: Text.ElideLeft
        minimumPointSize: theme.defaultFont.pointSize
        fontSizeMode: Text.HorizontalFit
    }
}
