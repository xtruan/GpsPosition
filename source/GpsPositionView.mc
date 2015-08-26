using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Position as Pos;

class GpsPositionView extends Ui.View {

    hidden var posInfo = null;
    hidden var deviceSettings = null;

    //! Load your resources here
    function onLayout(dc) {
    }

    function onHide() {
        Pos.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }
    //! Restore the state of the app and prepare the view to be shown
    function onShow() {
        Pos.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
        deviceSettings = Sys.getDeviceSettings();
    }

    //! Update the view
    function onUpdate(dc) {
        // holders for position data
        var navStringTop = "";
        var navStringBot = "";
        // holder for misc data
        var string;

        // Set background color
        dc.setColor( Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK );
        dc.clear();
        
        if( posInfo != null ) {
            if (posInfo.accuracy == Pos.QUALITY_GOOD) {
                dc.setColor( Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT );
            } else if (posInfo.accuracy == Pos.QUALITY_USABLE) {
                dc.setColor( Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT );
            } else if (posInfo.accuracy == Pos.QUALITY_POOR) {
                dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
            } else {
                dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
            }
            
            var geoFormat = App.getApp().getGeoFormat();
            // the built in helper function (toGeoString) sucks!!!
            if (geoFormat == :const_deg || geoFormat == :const_dm || geoFormat == :const_dms) {
                var degrees = posInfo.position.toDegrees();
                var lat = 0.0;
                var latHemi = "?";
                var long = 0.0;
                var longHemi = "?";
                // do latitude hemisphere
                if (degrees[0] < 0) {
                    lat = degrees[0] * -1;
                    latHemi = "S";
                } else {
                    lat = degrees[0];
                    latHemi = "N";
                }
                // do longitude hemisphere
                if (degrees[1] < 0) {
                    long = degrees[1] * -1;
                    longHemi = "W";
                } else {
                    long = degrees[1];
                    longHemi = "E";
                }
                
                // if decimal degrees, we're done
                if (geoFormat == :const_deg) {
                    navStringTop = latHemi + " " + lat.format("%.6f");
                    navStringBot = longHemi + " " + long.format("%.6f");
                    //string = posInfo.position.toGeoString(Pos.GEO_DEG);
                // do conversions for degs mins or degs mins secs
                } else { // :const_dm OR :const_dms
                    var latDegs = lat.toNumber();
                    var latMins = (lat - latDegs) * 60;
                    var longDegs = long.toNumber();
                    var longMins = (long - longDegs) * 60;
                    if (geoFormat == :const_dm) {
                        navStringTop = latHemi + " " + latDegs.format("%i") + " " + latMins.format("%.4f") + "'"; 
                        navStringBot = longHemi + " " + longDegs.format("%i") + " " + longMins.format("%.4f") + "'";
                        //string = posInfo.position.toGeoString(Pos.GEO_DM);
                    } else { // :const_dms
                        var latMinsInt = latMins.toNumber();
                        var latSecs = (latMins - latMinsInt) * 60;
                        var longMinsInt = longMins.toNumber();
                        var longSecs = (longMins - longMinsInt) * 60;
                        navStringTop = latHemi + " " + latDegs.format("%i") + " " + latMinsInt.format("%i") + "' " + latSecs.format("%.2f") + "\""; 
                        navStringBot = longHemi + " " + longDegs.format("%i") + " " + longMinsInt.format("%i") + "' " + longSecs.format("%.2f") + "\"";
                        //string = posInfo.position.toGeoString(Pos.GEO_DMS);
                    }
                } 
            } else if (geoFormat == :const_utm || geoFormat == :const_usng || geoFormat == :const_mgrs ||geoFormat == :const_ukgr) {
                var degrees = posInfo.position.toDegrees();
                var functions = new GpsPositionFunctions();
                if (geoFormat == :const_utm) {
                    var utmcoords = functions.LLtoUTM(degrees[0], degrees[1]);
                    navStringTop = "" + utmcoords[2] + " " + utmcoords[0] + " " + utmcoords[1];
                } else if (geoFormat == :const_usng) {
                    var usngcoords = functions.LLtoUSNG(degrees[0], degrees[1], 5);
                    navStringTop = "" + usngcoords[0] + " " + usngcoords[1] + " " + usngcoords[2] + " " + usngcoords[3];
                } else if (geoFormat == :const_ukgr) {
                    var ukgrid = functions.LLToOSGrid(degrees[0], degrees[1]);
                    if (ukgrid[1].length() == 0 || ukgrid[2].length() == 0) {
                        navStringTop = ukgrid[0]; // error message
                    } else {
                        navStringTop = ukgrid[0] + " " + ukgrid[1] + " " + ukgrid[2];
                    }
                } else { // :const_mgrs
                    var mgrszone = posInfo.position.toGeoString(Pos.GEO_MGRS).substring(0, 6);
                    var usngcoords = functions.LLtoUSNG(degrees[0], degrees[1], 5);
                    navStringTop = "" + mgrszone + " " + usngcoords[2] + " " + usngcoords[3];
                }
            } else {
                navStringTop = "Invalid format";
            }
            
            // display navigation (position) string
            if (navStringBot.length() != 0) {
                dc.drawText( (dc.getWidth() / 2), ((dc.getHeight() / 2) - 66 ), Gfx.FONT_MEDIUM, navStringTop, Gfx.TEXT_JUSTIFY_CENTER );
                dc.drawText( (dc.getWidth() / 2), ((dc.getHeight() / 2) - 44 ), Gfx.FONT_MEDIUM, navStringBot, Gfx.TEXT_JUSTIFY_CENTER );
            }
            else {
                dc.drawText( (dc.getWidth() / 2), ((dc.getHeight() / 2) - 44 ), Gfx.FONT_MEDIUM, navStringTop, Gfx.TEXT_JUSTIFY_CENTER );
            }
            
            // draw border around position
            //dc.setColor( Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT );
            //dc.drawLine(0, (dc.getHeight() / 2) - 62, dc.getWidth(), (dc.getHeight() / 2) - 62);
            //dc.drawLine(0, (dc.getHeight() / 2) - 18, dc.getWidth(), (dc.getHeight() / 2) - 18);
            
            // display heading
            dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
            var headingRad = posInfo.heading;
            var headingDeg = headingRad * 57.2957795;
            string = "Hdg: " + headingDeg.format("%.2f") + " deg (" + headingRad.format("%.2f") + " rad)";
            dc.drawText( (dc.getWidth() / 2), ((dc.getHeight() / 2) - 10 ), Gfx.FONT_TINY, string, Gfx.TEXT_JUSTIFY_CENTER );
            
            // display altitude
            var altMeters = posInfo.altitude;
            var altFeet = altMeters * 3.28084;
            string = "Alt: " + altMeters.format("%.2f") + " m (" + altFeet.format("%.2f") + " ft)";
            dc.drawText( (dc.getWidth() / 2), ((dc.getHeight() / 2) + 10 ), Gfx.FONT_TINY, string, Gfx.TEXT_JUSTIFY_CENTER );
            
            // display speed in mph or km/h based on device unit settings
            var speedMsec = posInfo.speed;
            if (deviceSettings.distanceUnits == Sys.UNIT_METRIC) {
                var speedKmh = speedMsec * 3.6;
                string = "Spd: " + speedMsec.format("%.2f") + " m/s (" + speedKmh.format("%.2f") + " km/h)";
            } else { // deviceSettings.distanceUnits == Sys.UNIT_STATUTE
                var speedMph = speedMsec * 2.23694;
                string = "Spd: " + speedMsec.format("%.2f") + " m/s (" + speedMph.format("%.2f") + " mph)";
            }
            dc.drawText( (dc.getWidth() / 2), ((dc.getHeight() / 2) + 30 ), Gfx.FONT_TINY, string, Gfx.TEXT_JUSTIFY_CENTER );
            
            // display Fix posix time
            //string = "Fix: " + posInfo.when.value().toString();
            //dc.drawText( (dc.getWidth() / 2), ((dc.getHeight() / 2) + 30 ), Gfx.FONT_TINY, string, Gfx.TEXT_JUSTIFY_CENTER );
        }
        else {
            // display default text for no GPS
            dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
            dc.drawText( (dc.getWidth() / 2), (dc.getHeight() / 2 - 25 ), Gfx.FONT_SMALL, "Waiting for GPS...", Gfx.TEXT_JUSTIFY_CENTER );
            dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
            dc.drawText( (dc.getWidth() / 2), (dc.getHeight() / 2 - 5 ), Gfx.FONT_SMALL, "Position unavailable", Gfx.TEXT_JUSTIFY_CENTER );
        }
        
        // display battery life
        var battPercent = Sys.getSystemStats().battery;
        if (battPercent > 50.0) {
            dc.setColor( Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT );
        } else if (battPercent > 20.0) {
            dc.setColor( Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT );
        } else {
            dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
        }
        string = "Batt: " + battPercent.format("%.1f") + "%";
        dc.drawText( (dc.getWidth() / 2), ((dc.getHeight() / 2) + 50 ), Gfx.FONT_TINY, string, Gfx.TEXT_JUSTIFY_CENTER );
    }

    // position change callback
    function onPosition(info) {
        posInfo = info;
        Ui.requestUpdate();
    }
}
