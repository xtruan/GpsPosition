using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.Position as Pos;

(:glance)
class PosInfoFormatter {

    // A: comes from app functions
    // B: comes from Garmin functions
    // They should be the same!
    const DEBUG = false;
    
    // compatibility mode for very old CIQ devices (1.x.x)
    var USE_USNG_FOR_MGRS = true;
    
    // degree symbol
    var DEG_SIGN = "";
    
    hidden var posInfo = null;
    
    function initialize(pPosInfo) {
        posInfo = pPosInfo;
        // super conservative version check
        if (getSystemMajorVersion() >= 3) {
            USE_USNG_FOR_MGRS = false;
            DEG_SIGN = StringUtil.utf8ArrayToString([0xC2,0xB0]);
        }
    }
    
    function getSystemMajorVersion() {
        var deviceSettings = System.getDeviceSettings();
        var ver = deviceSettings.monkeyVersion;
        if ( ver != null && ver[0] != null && ver[1] != null ) {
            return ver[0];
        } else {
            return 0;
        }
    }
    
    function initLatLong(degrees) {
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
        return [latHemi, lat, longHemi, long];
    }
    
    function getDeg() {
        var LLH = initLatLong(posInfo.position.toDegrees());
        // if decimal degrees, we're done
        var navStringTop = LLH[0] + " " + LLH[1].format("%.6f") + DEG_SIGN;
        var navStringBot = LLH[2] + " " + LLH[3].format("%.6f") + DEG_SIGN;
        if (DEBUG) {
            System.println("A: " + navStringTop + " " + navStringBot);
            System.println("B: " + posInfo.position.toGeoString(Pos.GEO_DEG));
        }
        return [navStringTop, navStringBot];
    }
    
    function getDM() {
        var LLH = initLatLong(posInfo.position.toDegrees());
        // do conversions for degs mins
        var latDegs = LLH[1].toNumber();
        var latMins = (LLH[1] - latDegs) * 60;
        var longDegs = LLH[3].toNumber();
        var longMins = (LLH[3] - longDegs) * 60;
        
        var navStringTop = LLH[0] + " " + latDegs.format("%i") + DEG_SIGN + " " + latMins.format("%.4f") + "'"; 
        var navStringBot = LLH[2] + " " + longDegs.format("%i") + DEG_SIGN + " " + longMins.format("%.4f") + "'";
        if (DEBUG) {
            System.println("A: " + navStringTop + " " + navStringBot);
            System.println("B: " + posInfo.position.toGeoString(Pos.GEO_DM));
        }
        return [navStringTop, navStringBot];
    }
    
    function getDMS() {
        var LLH = initLatLong(posInfo.position.toDegrees());
        // do conversions for degs mins secs
        var latDegs = LLH[1].toNumber();
        var latMins = (LLH[1] - latDegs) * 60;
        var longDegs = LLH[3].toNumber();
        var longMins = (LLH[3] - longDegs) * 60;
        var latMinsInt = latMins.toNumber();
        var latSecs = (latMins - latMinsInt) * 60;
        var longMinsInt = longMins.toNumber();
        var longSecs = (longMins - longMinsInt) * 60;
        
        var navStringTop = LLH[0] + " " + latDegs.format("%i") + DEG_SIGN + " " + latMinsInt.format("%i") + "' " + latSecs.format("%.2f") + "\""; 
        var navStringBot = LLH[2] + " " + longDegs.format("%i") + DEG_SIGN + " " + longMinsInt.format("%i") + "' " + longSecs.format("%.2f") + "\"";
        if (DEBUG) {
            System.println("A: " + navStringTop + " " + navStringBot);
            System.println("B: " + posInfo.position.toGeoString(Pos.GEO_DMS));
        }
        return [navStringTop, navStringBot];
    }
    
    function getMGRS() {
        if (USE_USNG_FOR_MGRS) {
            return getUSNG();
        }
    
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
            mgrsString = "BAD   MGRSDATA ";
        }
        
        var navStringTop = mgrsString.substring( 0,  3)
                   + " " + mgrsString.substring( 3,  5);
        var navStringBot = mgrsString.substring( 5, 10)
                   + " " + mgrsString.substring(10, 15);
        if (DEBUG) {
            getUSNG();
            System.println("B: " + navStringTop + " " + navStringBot);
        }
        return [navStringTop, navStringBot];
    }
    
    function getUTM() {
        var degrees = posInfo.position.toDegrees();
        var utmcoords = new CoordConvWGS84Grids()
            .LLtoUTM(degrees[0], degrees[1]);
        
        var navStringTop = "" + utmcoords[2] + " " + utmcoords[0];
        var navStringBot = "" + utmcoords[1];
        return [navStringTop, navStringBot];
    }
    
    function getUSNG() {
        var degrees = posInfo.position.toDegrees();
        var usngcoords = new CoordConvWGS84Grids()
            .LLtoUSNG(degrees[0], degrees[1], 5);
        
        var navStringTop = "";
        var navStringBot = "";
        if (usngcoords[1].length() == 0 || usngcoords[2].length() == 0 || usngcoords[3].length() == 0) {
            navStringTop = "" + usngcoords[0]; // error message
        } else {
            navStringTop = "" + usngcoords[0] + " " + usngcoords[1];
            navStringBot = "" + usngcoords[2] + " " + usngcoords[3];
        }
        if (DEBUG) {
            System.println("A: " + navStringTop + " " + navStringBot);
        }
        return [navStringTop, navStringBot];
    }
    
    function getUKGR() {
        var degrees = posInfo.position.toDegrees();
        var ukgrid = new CoordConvWGS84Grids()
            .LLToOSGrid(degrees[0], degrees[1]);
        
        var navStringTop = "";
        var navStringBot = "";
        if (ukgrid[1].length() == 0 || ukgrid[2].length() == 0) {
            navStringTop = ukgrid[0]; // error message
        } else {
            navStringTop = "" + ukgrid[0] + " " + ukgrid[1];
            navStringBot =  "" + ukgrid[2];
        }
        return [navStringTop, navStringBot];
    }
    
    function getQTH() {
        var degrees = posInfo.position.toDegrees();
        var maidenhead = new CoordConvMaidenhead();
        if (DEBUG) {
            maidenhead.testGridSquare();
        }
        
        var navStringTop = "LOC";
        var navStringBot = maidenhead.latLonToGridSquare(degrees[0], degrees[1]);
        return [navStringTop, navStringBot];
    }
    
    function getSGRLV95() {
        var degrees = posInfo.position.toDegrees();
        var swissGrid = new CoordConvSwissGrid();
        var coords = swissGrid.fromWGSToMN95(degrees[0], degrees[1]);
        
        var navStringTop = "";
        var navStringBot = "";
        if (coords.size() == 2) {
            navStringTop = coords[0].format("%i") + " E";
            navStringBot = coords[1].format("%i") + " N";
        } else {
            navStringTop = coords[0];  // error message
            navStringBot = "";
        }
        return [navStringTop, navStringBot];
    }
    
    function getSGRLV03() {
        var degrees = posInfo.position.toDegrees();
        var swissGrid = new CoordConvSwissGrid();
        var coords = swissGrid.fromWGSToMN03(degrees[0], degrees[1]);
        
        var navStringTop = "";
        var navStringBot = "";
        if (coords.size() == 2) {
            navStringTop = coords[0].format("%i") + " E";
            navStringBot = coords[1].format("%i") + " N";
        } else {
            navStringTop = coords[0];  // error message
            navStringBot = "";
        }
        return [navStringTop, navStringBot];
    }
    
    function getSK42(gridMode) {
        if (DEBUG) {
            new CoordConvSK42().testSK42();
        }
    
        var degrees = posInfo.position.toDegrees();
        var altitude = posInfo.altitude;
        
        var convertSK42 = new CoordConvSK42();
        var coords = convertSK42
            .WGS84ToSK42Coords(degrees[0], degrees[1], altitude);
            
        if (gridMode) {
            coords = convertSK42
                .SK42CoordsToSK42Grid(coords[0], coords[1]);
        }
        
        var navStringTop = "";
        var navStringBot = "";
        if (coords.size() == 2) {
            if (gridMode) {
                navStringTop = "X " + coords[1].format("%i");
                navStringBot = "Y " + coords[0].format("%i");
            } else {
                var LLH = initLatLong(coords);
                navStringTop = LLH[0] + " " + LLH[1].format("%.6f") + DEG_SIGN;
                navStringBot = LLH[2] + " " + LLH[3].format("%.6f") + DEG_SIGN;
            }
        } else {
            navStringTop = coords[0];  // error message
            navStringBot = "";
        }
        return [navStringTop, navStringBot];
    }
    
    function format(geoFormat) {
        if (geoFormat == :const_deg) {
             return getDeg(); // Degs
        } else if (geoFormat == :const_dm) {
             return getDM(); // Degs/Mins
        } else if (geoFormat == :const_dms) {
             return getDMS(); // Degs/Mins/Secs
        } else if (geoFormat == :const_utm) {
             return getUTM(); // UTM (WGS84)
        } else if (geoFormat == :const_usng) {
             return getUSNG(); // USNG (WGS84)
        } else if (geoFormat == :const_mgrs) {
             return getMGRS(); // MGRS (WGS84)
        } else if (geoFormat == :const_ukgr) {
             return getUKGR(); // UK Grid (OSGB36)
        } else if (geoFormat == :const_qth) {
             return getQTH(); // Maidenhead Locator / QTH Locator / IARU Locator
        } else if (geoFormat == :const_sgrlv95) {
             return getSGRLV95(); // Swiss Grid LV95
        } else if (geoFormat == :const_sgrlv03) {
             return getSGRLV03(); // Swiss Grid LV03
        } else if (geoFormat == :const_sk42_deg) {
             return getSK42(false); // SK-42 (Degrees)
        } else if (geoFormat == :const_sk42_grid) {
             return getSK42(true); // SK-42 (Orthogonal)
        } else {
            App.getApp().setGeoFormat(:const_dms); // Degs/Mins/Secs
            return getDMS(); // Degs/Mins/Secs (default)
        }
    }
}