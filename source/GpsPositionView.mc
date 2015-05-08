using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Position as Pos;

class GpsPositionView extends Ui.View {

    hidden var posInfo = null;

    //! Load your resources here
    function onLayout(dc) {
    }

    function onHide() {
        Pos.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }
    //! Restore the state of the app and prepare the view to be shown
    function onShow() {
        Pos.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    }

    //! Update the view
    function onUpdate(dc) {
        var string;

        // Set background color
        dc.setColor( Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK );
        dc.clear();
        
        if( posInfo != null ) {
            dc.setColor( Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT );
            dc.drawLine(0, (dc.getHeight() / 2) - 62, dc.getWidth(), (dc.getHeight() / 2) - 62);
            dc.drawLine(0, (dc.getHeight() / 2) - 38, dc.getWidth(), (dc.getHeight() / 2) - 38);
        
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
            if (geoFormat == :const_deg) {
                string = posInfo.position.toGeoString(Pos.GEO_DEG);
            } else if (geoFormat == :const_dm) {
                string = posInfo.position.toGeoString(Pos.GEO_DM);
            } else if (geoFormat == :const_dms) {
                string = posInfo.position.toGeoString(Pos.GEO_DMS);
            } else { // geoFormat == :const_mgrs
                string = posInfo.position.toGeoString(Pos.GEO_MGRS);
            }
            dc.drawText( (dc.getWidth() / 2), ((dc.getHeight() / 2) - 60 ), Gfx.FONT_SMALL, string, Gfx.TEXT_JUSTIFY_CENTER );
            
            dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
            var headingRad = posInfo.heading;
            var headingDeg = headingRad * 57.2957795;
            string = "Hdg: " + headingDeg.format("%.2f") + " deg (" + headingRad.format("%.2f") + " rad)";
            dc.drawText( (dc.getWidth() / 2), ((dc.getHeight() / 2) - 30 ), Gfx.FONT_SMALL, string, Gfx.TEXT_JUSTIFY_CENTER );
            
            var speedMsec = posInfo.speed;
            var speedMph = speedMsec * 2.23694;
            string = "Spd: " + speedMsec.format("%.2f") + " m/sec (" + speedMph.format("%.2f") + " mph)";
            dc.drawText( (dc.getWidth() / 2), ((dc.getHeight() / 2) - 10 ), Gfx.FONT_SMALL, string, Gfx.TEXT_JUSTIFY_CENTER );
            
            var altMeters = posInfo.altitude;
            var altFeet = altMeters * 3.28084;
            string = "Alt: " + altMeters.format("%.2f") + " m (" + altFeet.format("%.2f") + " ft)";
            dc.drawText( (dc.getWidth() / 2), ((dc.getHeight() / 2) + 10 ), Gfx.FONT_SMALL, string, Gfx.TEXT_JUSTIFY_CENTER );
            
            string = "Fix: " + posInfo.when.value().toString();
            dc.drawText( (dc.getWidth() / 2), ((dc.getHeight() / 2) + 30 ), Gfx.FONT_SMALL, string, Gfx.TEXT_JUSTIFY_CENTER );
        }
        else {
        
            dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
            dc.drawText( (dc.getWidth() / 2), (dc.getHeight() / 2 - 20 ), Gfx.FONT_SMALL, "Waiting for GPS...", Gfx.TEXT_JUSTIFY_CENTER );
            dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
            dc.drawText( (dc.getWidth() / 2), (dc.getHeight() / 2 ), Gfx.FONT_SMALL, "Position unavailable", Gfx.TEXT_JUSTIFY_CENTER );
        }
        
        var battPercent = Sys.getSystemStats().battery;
        if (battPercent > 50.0) {
            dc.setColor( Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT );
        } else if (battPercent > 20.0) {
            dc.setColor( Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT );
        } else {
            dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
        }
        string = "Batt: " + battPercent.format("%.1f") + "%";
        dc.drawText( (dc.getWidth() / 2), ((dc.getHeight() / 2) + 50 ), Gfx.FONT_SMALL, string, Gfx.TEXT_JUSTIFY_CENTER );
    }

    function onPosition(info) {
        posInfo = info;
        Ui.requestUpdate();
    }


}
