using Toybox.Math as Math;

(:glance)
class CoordConvSK42 {

    /// CoordConvSwissGrid.mc by Struan Clark (2022)
    /// Major components translated to Monkey C from Java library here: https://gis.stackexchange.com/questions/418151/how-to-convert-wgs84-degrees-coordinates-to-sk42-in-meters-in-java

    function WGS84ToSK42Coords(pLat, pLon, pAlt)
    {
        var latWgs84 = parseFloat(pLat);
        var longWgs84 = parseFloat(pLon);
        var heightWgs84 = parseFloat(pAlt);
        
        // Part 1: Converting Wgs84 geographical coordinates(longitude and latitude in degrees) to SK42 geographical coordinates(longitude and latitude in degrees)
        var ro = 206264.8062; //The number of angular seconds in radians
        var aP = 6378245.0; //Large semi - axis
        var alP = 1.0 / 298.3; //Compression
        var e2P = 2.0 * alP - Math.pow(alP, 2.0); //Eccentricity square

        // Ellipsoid WGS84 (GRS80, these two ellipsoids are similar in most parameters)
        var aW = 6378137.0; //Large semi - axis
        var alW = 1.0 / 298.257223563; //Compression
        var e2W = 2.0 * alW - Math.pow(alW, 2.0); //Eccentricity square

        // Auxiliary values for converting ellipsoids
        var a1 = (aP + aW) / 2.0;
        var e21 = (e2P + e2W) / 2.0;
        var da = aW - aP;
        var de2 = e2W - e2P;

        // Linear transformation elements, in meters
        var dx = 23.92;
        var dy = -141.27;
        var dz = -80.9;

        // Angular transformation elements, in seconds
        var wx = 0;
        var wy = -0.35;
        var wz = -0.82;

        // Differential difference of scales
        var ms = -0.12 * Math.pow(10.0, -6.0);

        var B, L, M11, N1;
        B = latWgs84 * Math.PI / 180.0;
        L = longWgs84 * Math.PI / 180.0;
        M11 = a1 * (1.0 - e21) / Math.pow((1.0 - e21 * Math.pow(Math.sin(B), 2.0)), 1.5);
        N1 = a1 * Math.pow((1.0 - e21 * Math.pow(Math.sin(B), 2.0)), -0.5);
        var dB = ro / (M11 + heightWgs84) * (N1 / a1 * e21 * Math.sin(B) * Math.cos(B) * da + (Math.pow(N1, 2.0) / Math.pow(a1, 2.0) + 1.0) * N1 * Math.sin(B) * Math.cos(B) * de2 / 2.0 - (dx * Math.cos(L) + dy * Math.sin(L)) * Math.sin(B) + dz * Math.cos(B)) - wx * Math.sin(L) * (1 + e21 * Math.cos(2 * B)) + wy * Math.cos(L) * (1.0 + e21 * Math.cos(2.0 * B)) - ro * ms * e21 * Math.sin(B) * Math.cos(B);

        // latitude in sk42 in degrees
        var SK42_LatDegrees = latWgs84 - dB / 3600.0; 

        B = latWgs84 * Math.PI / 180.0;
        L = longWgs84 * Math.PI / 180.0;
        N1 = a1 * Math.pow((1 - e21 * Math.pow(Math.sin(B), 2.0)), -0.5);
        var dL = ro / ((N1 + heightWgs84) * Math.cos(B)) * (-dx * Math.sin(L) + dy * Math.cos(L)) + Math.tan(B) * (1.0 - e21) * (wx * Math.cos(L) + wy * Math.sin(L)) - wz;

        // longitude in sk42 in degrees
        var SK42_LongDegrees = longWgs84 - dL / 3600.0;
        
        return [SK42_LatDegrees, SK42_LongDegrees];
    }

    function SK42CoordsToSK42Grid(pLat, pLon)
    {
        
        var SK42_LatDegrees = parseFloat(pLat);
        var SK42_LongDegrees = parseFloat(pLon);
        
        // Part 2: Converting of SK42 geographical coordinates (latitude and longitude in degrees) into SK42 rectangular coordinates(easting and northing in meters)        
        // Number of the Gauss-Kruger zone
        var zone = parseFloat(parseInt(SK42_LongDegrees / 6.0 + 1.0));
        //System.println(zone);

        // Parameters of the Krasovsky ellipsoid
        var a = 6378245.0;          //Large (equatorial) semi-axis
        var b = 6356863.019;        //Small (polar) semi-axis
        var e2 = (Math.pow(a, 2.0) - Math.pow(b, 2.0)) / Math.pow(a, 2.0);  //Eccentricity
        var n = (a-b) / (a+b);        //Flatness


        // Parameters of the Gauss-Kruger zone
        var F = 1.0;                   //Scale factor
        var Lat0 = 0.0;                //Initial parallel (in radians)
        var Lon0 = (zone * 6.0 - 3.0)* Math.PI / 180.0;  //Central Meridian (in radians)
        var N0 = 0.0;                  //Conditional north offset for the initial parallel
        var E0 = zone * 1000000.0 + 500000.0;    //Conditional eastern offset for the central meridian

        // Converting latitude and longitude to radians
        var Lat = SK42_LatDegrees * Math.PI / 180.0;
        var Lon = SK42_LongDegrees * Math.PI / 180.0;

        // Calculating variables for conversion
        var sinLat = Math.sin(Lat);
        var cosLat = Math.cos(Lat);
        var tanLat = Math.tan(Lat);

        var v = a * F * Math.pow(1-e2* Math.pow(sinLat,2),-0.5);
        var p = a*F*(1-e2) * Math.pow(1-e2*Math.pow(sinLat,2),-1.5);
        var n2 = v/p-1;
        var M1 = (1+n+5.0/4.0* Math.pow(n,2) +5.0/4.0* Math.pow(n,3)) * (Lat-Lat0);
        var M2 = (3*n+3* Math.pow(n,2) +21.0/8.0* Math.pow(n,3)) * Math.sin(Lat - Lat0) * Math.cos(Lat + Lat0);
        var M3 = (15.0/8.0* Math.pow(n,2) +15.0/8.0* Math.pow(n,3))*Math.sin(2 * (Lat - Lat0))*Math.cos(2 * (Lat + Lat0));
        var M4 = 35.0/24.0* Math.pow(n,3) *Math.sin(3 * (Lat - Lat0)) * Math.cos(3 * (Lat + Lat0));
        var M = b*F*(M1-M2+M3-M4);
        var I = M+N0;
        var II = v/2 * sinLat * cosLat;
        var III = v/24 * sinLat * Math.pow(cosLat,3) * (5-Math.pow(tanLat,2)+9*n2);
        var IIIA = v/720 * sinLat * Math.pow(cosLat,5) * (61-58*Math.pow(tanLat,2)+Math.pow(tanLat,4));
        var IV = v * cosLat;
        var V = v/6 * Math.pow(cosLat,3) * (v/p-Math.pow(tanLat,2));
        var VI = v/120 * Math.pow(cosLat,5) * (5-18*Math.pow(tanLat,2)+Math.pow(tanLat,4)+14*n2-58*Math.pow(tanLat,2)*n2);

        // Calculation of the north and east offset (in meters)
        var N = I+II* Math.pow(Lon-Lon0,2)+III* Math.pow(Lon-Lon0,4)+IIIA* Math.pow(Lon-Lon0,6);
        var E = E0+IV*(Lon-Lon0)+V* Math.pow(Lon-Lon0,3)+VI* Math.pow(Lon-Lon0,5);

        return [N, E];
    }
    
//
// cast to number (integer)
//
    function parseInt(numeric) {
        return numeric.toNumber();
    }
    
//
// cast to float
//
    function parseFloat(numeric) {
        return numeric.toFloat();
    }
    
    function testSK42() {
        // TESTER - http://www.gcgpx.cz/transform/?lang=en
        
        var loc, lat, lon, alt, coords;
        
        // TEST - Kyiv
        loc = "Kyiv";
        lat = 50.450001;
        lon = 30.523333;
        alt = 178.9;
        
        coords = WGS84ToSK42Coords(lat, lon, alt);
        System.println(loc + " - SK42 Degs: " + coords);
        coords = SK42CoordsToSK42Grid(coords[0], coords[1]);
        System.println(loc + " - SK42 Grid: " + coords);
        
//        // TEST - Kyiv (actual)
//        X 6324226 Y 5593947
//        N 50.450169 E 30.525049
//        
//        // TEST - Kyiv (expected)
//        S42 (Pulkovo) ortogonal
//        AL:X 6324229 Y 5593949
//        CZ:X 6324222 Y 5593947
//        HU:X 6324223 Y 5593946
//        KZ:X 6324224 Y 5593938
//        LT:X 6324223 Y 5593945
//        PL:X 6324223 Y 5593944
//        RO:X 6324223 Y 5593946
//        RU:X 6324231 Y 5593953
//        SK:X 6324222 Y 5593947
//        
//        S42 (Pulkovo) D.DDDDDD
//        AL:N 50.450183 E 030.525081
//        CZ:N 50.450169 E 030.524986
//        HU:N 50.450153 E 030.525001
//        KZ:N 50.450083 E 030.525017
//        LT:N 50.450147 E 030.525009
//        PL:N 50.450141 E 030.525001
//        RO:N 50.450153 E 030.525001
//        RU:N 50.450224 E 030.52511
//        SK:N 50.450169 E 030.524986
        
        // TEST - Moscow
        loc = "Moscow";
        lat = 55.7558;
        lon = 37.6173;
        alt = 156.1;
        
        coords = WGS84ToSK42Coords(lat, lon, alt);
        System.println(loc + " - SK42 Degs: " + coords);
        coords = SK42CoordsToSK42Grid(coords[0], coords[1]);
        System.println(loc + " - SK42 Grid: " + coords);
        
//        // TEST - Moscow (actual)
//        X 7413305 Y 6182341
//        N 55.755760 E 37.619171
//        
//        // TEST - Moscow (expected)
//        S42 (Pulkovo) ortogonal
//        AL:X 7413306 Y 6182345
//        CZ:X 7413300 Y 6182345
//        HU:X 7413301 Y 6182343
//        KZ:X 7413300 Y 6182334
//        LT:X 7413301 Y 6182342
//        PL:X 7413300 Y 6182341
//        RO:X 7413301 Y 6182343
//        RU:X 7413308 Y 6182349
//        SK:X 7413300 Y 6182345
//        
//        S42 (Pulkovo) D.DDDDDD
//        AL:N 55.755788 E 037.619173
//        CZ:N 55.75579 E 037.619079
//        HU:N 55.755777 E 037.619099
//        KZ:N 55.755695 E 037.619086
//        LT:N 55.755765 E 037.619098
//        PL:N 55.755759 E 037.619088
//        RO:N 55.755777 E 037.619099
//        RU:N 55.755827 E 037.619212
//        SK:N 55.75579 E 037.619079
    }

}