using Toybox.Position as Pos;

class GpsPositionFormatter {

    // A: comes from app functions
    // B: comes from Garmin functions
    // They should be the same!
    const DEBUG = false;
    
    // don't show degree symbol
    const DEG_SIGN = "";
    
    hidden var posInfo = null;
    hidden var lat = 0.0;
    hidden var latHemi = "?";
    hidden var long = 0.0;
    hidden var longHemi = "?";     
    
    function initialize(pPosInfo) {
        posInfo = pPosInfo;
        var degrees = posInfo.position.toDegrees();
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
    }
    
    function getDeg() {
        var navStringTop = latHemi + " " + lat.format("%.6f") + DEG_SIGN;
        var navStringBot = longHemi + " " + long.format("%.6f") + DEG_SIGN;
        if (DEBUG) {
            System.println("A: " + navStringTop + " " + navStringBot);
            System.println("B: " + posInfo.position.toGeoString(Pos.GEO_DEG));
        }
        return [navStringTop, navStringBot];
    }
    
    function getDM() {
        var latDegs = lat.toNumber();
        var latMins = (lat - latDegs) * 60;
        var longDegs = long.toNumber();
        var longMins = (long - longDegs) * 60;
        
        var navStringTop = latHemi + " " + latDegs.format("%i") + DEG_SIGN + " " + latMins.format("%.4f") + "'"; 
        var navStringBot = longHemi + " " + longDegs.format("%i") + DEG_SIGN + " " + longMins.format("%.4f") + "'";
        if (DEBUG) {
            System.println("A: " + navStringTop + " " + navStringBot);
            System.println("B: " + posInfo.position.toGeoString(Pos.GEO_DM));
        }
        return [navStringTop, navStringBot];
    }
    
    function getDMS() {
        var latDegs = lat.toNumber();
        var latMins = (lat - latDegs) * 60;
        var longDegs = long.toNumber();
        var longMins = (long - longDegs) * 60;
        var latMinsInt = latMins.toNumber();
        var latSecs = (latMins - latMinsInt) * 60;
        var longMinsInt = longMins.toNumber();
        var longSecs = (longMins - longMinsInt) * 60;
        
        var navStringTop = latHemi + " " + latDegs.format("%i") + DEG_SIGN + " " + latMinsInt.format("%i") + "' " + latSecs.format("%.2f") + "\""; 
        var navStringBot = longHemi + " " + longDegs.format("%i") + DEG_SIGN + " " + longMinsInt.format("%i") + "' " + longSecs.format("%.2f") + "\"";
        if (DEBUG) {
            System.println("A: " + navStringTop + " " + navStringBot);
            System.println("B: " + posInfo.position.toGeoString(Pos.GEO_DMS));
        }
        return [navStringTop, navStringBot];
    }
    
    function getMGRS() {
        // make MGRS into an array
        var mgrsChars = posInfo.position.toGeoString(Pos.GEO_MGRS).toCharArray();
        var mgrsString = "";
        // filter out spaces
        for (var i = 0; i < mgrsChars.size(); i++) {
            if (!mgrsChars[i].equals(' ')) {
                mgrsString = mgrsString + mgrsChars[i];
            }
        }
        // should be 15 characters long, if not, garbage-ify
        if (mgrsString.length() != 15) {
            mgrsString = "????? MGRSERROR";
        }
        var navStringTop = mgrsString.substring( 0,  3)
                   + " " + mgrsString.substring( 3,  5);
        var navStringBot = mgrsString.substring( 5, 10)
                   + " " + mgrsString.substring(10, 15);
        if (DEBUG) {
            System.println("B: " + navStringTop);
            System.println("B: " + navStringBot);
        }
        return [navStringTop, navStringBot];
    }
}