using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Position as Pos;
using Toybox.Timer;

class GpsPositionView extends Ui.View {

    hidden var posInfo = null;
    hidden var deviceSettings = null;
    hidden var deviceId = null;
    hidden var showLabels = true;
    hidden var isMono = false;
    hidden var isOcto = false;
    hidden var progressTimer = null;
    hidden var progressDots = "";
    
    function initialize() {
        View.initialize();
    }

    //! Load your resources here
    function onLayout(dc as Gfx.Dc) {
        progressTimer = new Timer.Timer();
        progressTimer.start(method(:updateProgress), 1000, true);
    }
    
    function updateProgress() {
        progressDots = progressDots + ".";
        if (progressDots.length() > 3) {
            progressDots = "";
        }
        Ui.requestUpdate();
    }

    function onHide() {
        Pos.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }
    //! Restore the state of the app and prepare the view to be shown
    function onShow() {
        deviceSettings = Sys.getDeviceSettings();
        startPositioning();
        deviceId = Ui.loadResource(Rez.Strings.DeviceId);
        isOcto = deviceId != null && deviceId.equals("octo");
        // only octo watches are mono... at least for now
        isMono = isOcto;
        //System.println(deviceId);
        if (deviceId.equals("vivoactive_hr")) {
            showLabels = false;
        }
    }

    //! Update the view
    function onUpdate(dc as Gfx.Dc) {
//        // Get position
//        var posInfo = App.getApp().getCurrentPosition();
    
        // holders for position data
        var navStringTop = "";
        var navStringBot = "";
        // holder for misc data
        var string;

        // Set background color
        dc.setColor( Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK );
        dc.clear();
        var pos = 0;
        
        // display battery life
        var battPercent = Sys.getSystemStats().battery;
        if (isMono) {
            dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
        } else if (battPercent > 50.0) {
            dc.setColor( Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT );
        } else if (battPercent > 20.0) {
            dc.setColor( Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT );
        } else {
            dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
        }
        string = "Bat: " + battPercent.format("%.1f") + "%";
        pos = pos + Gfx.getFontHeight(Gfx.FONT_TINY) - 4;
        if (isOcto) {
            dc.drawText( (dc.getWidth() / 3) - 2, (dc.getHeight() / 8) - 2, Gfx.FONT_TINY, string, Gfx.TEXT_JUSTIFY_CENTER );
        } else {
            dc.drawText( (dc.getWidth() / 2), pos, Gfx.FONT_TINY, string, Gfx.TEXT_JUSTIFY_CENTER );
        }
        
        if( posInfo != null ) {
            if (progressTimer != null) {
                progressTimer.stop();
            }
            
            var signalStrength = "?";
            if (posInfo.accuracy == Pos.QUALITY_GOOD) {
                dc.setColor( Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT );
                signalStrength = "|||||";
            } else if (posInfo.accuracy == Pos.QUALITY_USABLE) {
                dc.setColor( Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT );
                signalStrength = "|||-";
            } else if (posInfo.accuracy == Pos.QUALITY_POOR) {
                dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
                signalStrength = "|--";
            } else {
                dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
                signalStrength = "---";
            }
            if (isMono) {
                dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
            }
            if (isOcto) {
                dc.drawText( dc.getWidth() - (dc.getWidth() / 6) - 2, 
                             (dc.getHeight() / 8) - 2, 
                             Gfx.FONT_TINY, 
                             "Sig: " + signalStrength, 
                             Gfx.TEXT_JUSTIFY_CENTER );
            }
            
            var geoFormat = App.getApp().getGeoFormat();
            var formatter = new PosInfoFormatter(posInfo);
            var nav = formatter.format(geoFormat);
            navStringTop = nav[0];
            navStringBot = nav[1];
            
            // display navigation (position) string for non-octo
            if (!isOcto) {
                pos = drawNavString(dc, pos, navStringTop, navStringBot);
            }
            
            // display heading
            dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
            var headingRad = posInfo.heading;
            var headingDeg = headingRad * 57.2957795;
            if (showLabels) {
                string = "Hdg: ";
            } else {
                string = "";
            }
            if (geoFormat == :const_mgrs) {
                // if MGRS, display heading in mil
                var headingMil = headingDeg * 17.7777778;
                headingMil = modulo(headingMil + 6400, 6400);
                headingMil = (headingMil / 10).toNumber() * 10;
                string = string + headingMil.format("%i") + " mil";
            } else {
                // else, display heading in degrees
                headingDeg = modulo(headingDeg + 360, 360);
                var degSign = formatter.DEG_SIGN;
                if (degSign.length() == 0) {
                   degSign = " deg";
                }
                string = string + headingDeg.format("%i") + degSign;
            }
            //pos = pos + Gfx.getFontHeight(Gfx.FONT_MEDIUM) - 2;
            pos = pos + Gfx.getFontHeight(Gfx.FONT_TINY);
            if (isOcto) {
                pos = pos + 2;
                dc.drawText( (dc.getWidth() / 3) - 2, pos, Gfx.FONT_TINY, string, Gfx.TEXT_JUSTIFY_CENTER );
            } else {
                dc.drawText( (dc.getWidth() / 2), pos, Gfx.FONT_TINY, string, Gfx.TEXT_JUSTIFY_CENTER );
            }
            
            // display navigation (position) string for octo
            if (isOcto) {
                pos = pos + 4;
                pos = drawNavString(dc, pos, navStringTop, navStringBot);
                pos = pos + 2;
            }
            
            // display altitude
            var altMeters = posInfo.altitude;
            var altFeet = altMeters * 3.28084;
            if (showLabels) {
                string = "Alt: ";
            } else {
                string = "";
            }
            if (deviceSettings.distanceUnits == Sys.UNIT_METRIC) {
                string = string + altMeters.format("%.1f") + " m";
            } else { // deviceSettings.distanceUnits == Sys.UNIT_STATUTE
                string = string + altFeet.format("%.1f") + " ft";
            }
            pos = pos + Gfx.getFontHeight(Gfx.FONT_TINY);
            dc.drawText( (dc.getWidth() / 2), pos, Gfx.FONT_TINY, string, Gfx.TEXT_JUSTIFY_CENTER );
            
            // display speed in mph or km/h based on device unit settings
            var speedMsec = posInfo.speed;
            if (showLabels) {
                string = "Spd: ";
            } else {
                string = "";
            }
            if (deviceSettings.distanceUnits == Sys.UNIT_METRIC) {
                var speedKmh = speedMsec * 3.6;
                string = string + speedKmh.format("%.1f") + " km/h";
            } else { // deviceSettings.distanceUnits == Sys.UNIT_STATUTE
                var speedMph = speedMsec * 2.23694;
                string = string + speedMph.format("%.1f") + " mph";
            }
            pos = pos + Gfx.getFontHeight(Gfx.FONT_TINY);
            dc.drawText( (dc.getWidth() / 2), pos, Gfx.FONT_TINY, string, Gfx.TEXT_JUSTIFY_CENTER );
            
            // display Fix posix time
            //string = "Fix: " + posInfo.when.value().toString();
            //dc.drawText( (dc.getWidth() / 2), ((dc.getHeight() / 2) + 30 ), Gfx.FONT_TINY, string, Gfx.TEXT_JUSTIFY_CENTER );
        }
        else {
            // display default text for no GPS
            var posShift = 0;
            if (isOcto) {
                posShift = 10;
            }
            
            dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
            dc.drawText( (dc.getWidth() / 2), posShift + (dc.getHeight() / 2) - Gfx.getFontHeight(Gfx.FONT_SMALL), Gfx.FONT_SMALL, "Waiting for GPS" + progressDots, Gfx.TEXT_JUSTIFY_CENTER );
            if (isMono) {
                dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
            } else {
                dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
            }
            dc.drawText( (dc.getWidth() / 2), posShift + (dc.getHeight() / 2), Gfx.FONT_SMALL, "Position unavailable", Gfx.TEXT_JUSTIFY_CENTER );
        }
        
    }
    
    function drawNavString(dc, screenPos, navStringTop, navStringBot) {
        // display navigation (position) string
        var pos = screenPos;
        if (navStringBot.length() != 0) {
            pos = pos + Gfx.getFontHeight(Gfx.FONT_SMALL);
            dc.drawText( (dc.getWidth() / 2), pos, Gfx.FONT_MEDIUM, navStringTop, Gfx.TEXT_JUSTIFY_CENTER );
            pos = pos + Gfx.getFontHeight(Gfx.FONT_MEDIUM) - 6;
            dc.drawText( (dc.getWidth() / 2), pos, Gfx.FONT_MEDIUM, navStringBot, Gfx.TEXT_JUSTIFY_CENTER );
        }
        else {
            pos = pos + Gfx.getFontHeight(Gfx.FONT_SMALL);
            dc.drawText( (dc.getWidth() / 2), pos, Gfx.FONT_MEDIUM, navStringTop, Gfx.TEXT_JUSTIFY_CENTER );
            pos = pos + Gfx.getFontHeight(Gfx.FONT_MEDIUM) - 6;
        }
        pos = pos + Gfx.getFontHeight(Gfx.FONT_MEDIUM) - Gfx.getFontHeight(Gfx.FONT_TINY);
        return pos;
    }
    
    //
    // modulo operation
    //
    function modulo(a, n) {
        // a % n
        return a - (n * (a/n).toNumber());
    }
    
    function startPositioning() {
        var ver = deviceSettings.monkeyVersion;
        // custom constellations only in CIQ >= 3.2.0
        if ( ver != null && ver[0] != null && ver[1] != null && 
            ( (ver[0] == 3 && ver[1] >= 2) || ver[0] > 3 ) ) {
            if (enablePositioningWithConstellations([
                    Pos.CONSTELLATION_GPS,
                    Pos.CONSTELLATION_GLONASS, 
                    Pos.CONSTELLATION_GALILEO
            ])) {
                System.println("Constellations: GPS/GLO/GAL");
                return true;
            }
            if (enablePositioningWithConstellations([
                    Pos.CONSTELLATION_GPS,
                    Pos.CONSTELLATION_GLONASS
            ])) {
                System.println("Constellations: GPS/GLO");
                return true;
            }
            if (enablePositioningWithConstellations([
                    Pos.CONSTELLATION_GPS,
                    Pos.CONSTELLATION_GALILEO,
            ])) {
                System.println("Constellations: GPS/GAL");
                return true;
            }
            if (enablePositioningWithConstellations([
                    Pos.CONSTELLATION_GPS
            ])) {
                System.println("Constellation: GPS");
                return true;
            }
        } else {
            Pos.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
            System.println("Constellation: GPS (Legacy Mode)");
        }
        return true;
    }
    
    function enablePositioningWithConstellations(constellations) {
        var success = false;
        try {
            Pos.enableLocationEvents({
                    :acquisitionType => Pos.LOCATION_CONTINUOUS,
                    :constellations => constellations
                },
                method(:onPosition)
            );
            success = true;
        } catch (ex) {
            System.println(ex.getErrorMessage() + ": " + constellations.toString());
            success = false;
        }
        return success;
    }

    // position change callback
    function onPosition(info) {
        if (progressTimer != null) {
            progressTimer.stop();
        }
        posInfo = info;
        Ui.requestUpdate();
    }
}
