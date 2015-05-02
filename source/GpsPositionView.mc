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
            string = "HDG: " + headingDeg.format("%.3f") + " deg (" + headingRad.format("%.3f") + " rad)";
            dc.drawText( (dc.getWidth() / 2), ((dc.getHeight() / 2) - 30 ), Gfx.FONT_SMALL, string, Gfx.TEXT_JUSTIFY_CENTER );
            
            var speedMsec = posInfo.speed;
            var speedMph = speedMsec * 2.23694;
            string = "SPD: " + speedMsec.format("%.3f") + " m/sec (" + speedMph.format("%.3f") + " mph)";
            dc.drawText( (dc.getWidth() / 2), ((dc.getHeight() / 2) - 10 ), Gfx.FONT_SMALL, string, Gfx.TEXT_JUSTIFY_CENTER );
            
            var altMeters = posInfo.altitude;
            var altFeet = altMeters * 3.28084;
            string = "ALT: " + altMeters.format("%.3f") + " m (" + altFeet.format("%.3f") + " ft)";
            dc.drawText( (dc.getWidth() / 2), ((dc.getHeight() / 2) + 10 ), Gfx.FONT_SMALL, string, Gfx.TEXT_JUSTIFY_CENTER );
            
            string = "FIX: " + posInfo.when.value().toString();
            dc.drawText( (dc.getWidth() / 2), ((dc.getHeight() / 2) + 30 ), Gfx.FONT_SMALL, string, Gfx.TEXT_JUSTIFY_CENTER );
        }
        else {
            dc.setColor( Gfx.COLOR_LT_GRAY, Gfx.COLOR_TRANSPARENT );
            dc.drawText( (dc.getWidth() / 2), (dc.getHeight() / 2 - 10 ), Gfx.FONT_SMALL, "POSITION UNAVAILABLE", Gfx.TEXT_JUSTIFY_CENTER );
        }
    }

    function onPosition(info) {
        posInfo = info;
        Ui.requestUpdate();
    }


}
