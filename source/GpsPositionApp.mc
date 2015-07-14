using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class GpsPositionApp extends App.AppBase {

    hidden var geoFormat;
    
    // property store can't handle symbol types 
    // this method converts from symbol to number for writing to properties
    function geoFormatSymbolToNumber(sym) {
        if (sym == :const_deg) {
             return 0; // Degs
        } else if (sym == :const_dm) {
             return 1; // Degs/Mins
        } else if (sym == :const_dms) {
             return 2; // Degs/Mins/Secs
        } else if (sym == :const_utm) {
             return 3; // UTM (WGS84)
        } else if (sym == :const_usng) {
             return 4; // USNG (WGS84)
        } else if (sym == :const_mgrs) {
             return 5; // MGRS (WGS84)
        } else if (sym == :const_ukgr) {
             return 6; // UK Grid (OSGB36)
        } else {
            return -1; // Error condition
        }
    }
    
    // property store can't handle symbol types 
    // this method converts from number to symbol for reading from properties
    function geoFormatNumberToSymbol(num) {
        if (num == 0) {
             return :const_deg;  // Degs
        } else if (num == 1) {
             return :const_dm;   // Degs/Mins
        } else if (num == 2) {
             return :const_dms;  // Degs/Mins/Secs
        } else if (num == 3) {
             return :const_utm;  // UTM (WGS84)
        } else if (num == 4) {
             return :const_usng; // USNG (WGS84)
        } else if (num == 5) {
             return :const_mgrs; // MGRS (WGS84)
        } else { // num == 6
             return :const_ukgr; // UK Grid (OSGB36)
        }
    }
    
    // set geoFormat var and write to properties
    function setGeoFormat(format) {
        geoFormat = format;
        setProperty("geo", geoFormatSymbolToNumber(format));
    }
    
    // return current geoFormat
    function getGeoFormat(format) {
        return geoFormat;
    }
    
    // initialize geoFormat var to current value in properties (called at app startup)
    function initGeoFormat() {
        var formatNum = getProperty("geo");
        if (formatNum != null && formatNum != -1) {
            setGeoFormat(geoFormatNumberToSymbol(formatNum));
        } else {
            setGeoFormat(:const_dms);
        }
    }

    //! onStart() is called on application start up
    function onStart() {
        initGeoFormat();
    }

    //! onStop() is called when your application is exiting
    function onStop() {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [ new GpsPositionView(), new GpsPositionDelegate() ];
    }

}

class GpsPositionDelegate extends Ui.BehaviorDelegate {

    function onMenu() {
        var menu = new Rez.Menus.CoordFormatMenu();
        menu.setTitle("Coordinate Format");
        Ui.pushView(menu, new GpsPositionMenuDelegate(), Ui.SLIDE_UP);
        return true;
    }
    
    function onKey(key) {
        //System.println(key.getKey());
        if (key.getKey() == Ui.KEY_UP) {
            onMenu();
        }
    }

}