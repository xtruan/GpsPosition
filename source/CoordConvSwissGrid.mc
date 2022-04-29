using Toybox.Math as Math;

(:glance)
class CoordConvSwissGrid {

/// CoordConvSwissGrid.mc by Struan Clark (2022)
/// Major components translated to Monkey C from PHP library SwisstopoConverter.php

/**
 * Convert GPS (WGS84) to Swiss (LV03 or LV95) coordinates - and vice versa.
 */
    
    function inBoundsWGS(lat, long) {
        
        // boundary check
        if ( lat  > 45.2 &&  lat  < 48.2 &&
             long >  5.5 &&  long < 11.0 ) {
            return true;
        } else {
            return false;
        }
    }
    
    /**
     * Convert the given Swiss (MN95) coordinate points into WGS notation.
     *
     * @param int east
     *   The East Swiss (MN95) coordinate point
     * @param int north
     *   The North Swiss (MN95) coordinate point
     *
     * @return array
     *   The array containing WGS latitude & longitude coordinates
     */
    function fromMN95ToWGS(east, north)
    {
        // [lat, long]
        return [fromMN95ToWGSLatitude(east, north), fromMN95ToWGSLongitude(east, north)];
    }

    /**
     * Convert the given WGS coordinate points into Swiss (MN95) notation.
     *
     * @param float lat
     *   The WGS latitude coordinate point in degree
     * @param float long
     *   The WGS longitude coordinate point in degree
     *
     * @return array
     *   The array containing Swiss (MN95) East & North coordinates
     */
    function fromWGSToMN95(pLat, pLong)
    {
        var lat = pLat;
        var long = pLong;
        
//        // Zurich (test)
//        lat = 47.3769;
//        long = 8.5417;

        if (!inBoundsWGS(lat, long)) {
           return ["OUTSIDE CH"];
        }
        
        // [east, north]
        return [fromWGSToMN95East(lat, long), fromWGSToMN95North(lat, long)];
    }

    /**
     * Convert the given Swiss (MN03) coordinate points into WGS notation.
     *
     * @param int y
     *   The Y Swiss (MN03) coordinate point
     * @param int x
     *   The X Swiss (MN03) coordinate point
     *
     * @return array
     *   The array containing WGS latitude & longitude coordinates
     */
    function fromMN03ToWGS(y, x)
    {
        // [lat, long]
        return [fromMN03ToWGSLatitude(y, x), fromMN03ToWGSLongitude(y, x)];
    }

    /**
     * Convert the given WGS coordinate points into Swiss (MN03) notation.
     *
     * @param float lat
     *   The WGS latitude coordinate point in degree
     * @param float long
     *   The WGS longitude coordinate point in degree
     *
     * @return array
     *   The array containing Swiss (MN03) x & y coordinates
     */
    function fromWGSToMN03(pLat, pLong)
    {
        var lat = pLat;
        var long = pLong;
    
//        // Zurich (test)
//        lat = 47.3769;
//        long = 8.5417;
    
        if (!inBoundsWGS(lat, long)) {
           return ["OUTSIDE CH"];
        }
    
        // [x, y]
        return [fromWGSToMN03x(lat, long), fromWGSToMN03y(lat, long)];
    }

    /**
     * Convert WGS coordinates latitude & longitude into Swiss (MN03) Y value.
     *
     * @param float lat
     *   The WGS latitude coordinate point in degree
     * @param float long
     *   The WGS longitude coordinate point in degree
     *
     * @return float
     *   The converted WGS coordinates to Swiss (MN03) Y
     */
    function fromWGSToMN03y(pLat, pLong)
    {
        // Converts Decimal Degrees to Sexagesimal Degree.
        var lat = degToSex(pLat);
        var long = degToSex(pLong);

        // Convert Decimal Degrees to Seconds of Arc.
        lat = degToSec(lat);
        long = degToSec(long);

        // Auxiliary values (% Bern).
        var lat_aux = (lat - 169028.66) / 10000.0;
        var long_aux = (long - 26782.5) / 10000.0;

        // Process Swiss (MN03) Y calculation.
        return 600072.37
      + 211455.93 * long_aux
      - 10938.51 * long_aux * lat_aux
      - 0.36 * long_aux * Math.pow(lat_aux, 2)
      - 44.54 * Math.pow(long_aux, 3);
    }

    /**
     * Convert WGS coordinates latitude & longitude into Swiss (MN03) X value.
     *
     * @param float lat
     *   The WGS latitude coordinate point in degree
     * @param float long
     *   The WGS longitude coordinate point in degree
     *
     * @return float
     *   The converted WGS coordinates to Swiss (MN03) X
     */
    function fromWGSToMN03x(pLat, pLong)
    {
        // Converts Decimal Degrees to Sexagesimal Degree.
        var lat = degToSex(pLat);
        var long = degToSex(pLong);

        // Convert Decimal Degrees to Seconds of Arc.
        lat = degToSec(lat);
        long = degToSec(long);

        // Auxiliary values (% Bern).
        var lat_aux = (lat - 169028.66) / 10000.0;
        var long_aux = (long - 26782.5) / 10000.0;

        // Process Swiss (MN03) X calculation.
        return 200147.07
      + 308807.95 * lat_aux
      + 3745.25 * Math.pow(long_aux, 2)
      + 76.63 * Math.pow(lat_aux, 2)
      - 194.56 * Math.pow(long_aux, 2) * lat_aux
      + 119.79 * Math.pow(lat_aux, 3);
    }

    /**
     * Convert WGS coordinates latitude & longitude into Swiss (MN95) North value.
     *
     * @param float lat
     *   The WGS latitude coordinate point in degree
     * @param float long
     *   The WGS longitude coordinate point in degree
     *
     * @return float
     *   The converted WGS coordinates to Swiss (MN95) North
     */
    function fromWGSToMN95North(pLat, pLong)
    {
        // Converts Decimal Degrees to Sexagesimal Degree.
        var lat = degToSex(pLat);
        var long = degToSex(pLong);

        // Convert Decimal Degrees to Seconds of Arc.
        var phi = degToSec(lat);
        var lambda = degToSec(long);

        // Calculate the auxiliary values (differences of latitude and longitude
        // relative to Bern in the unit[10000"]).
        var phi_aux = (phi - 169028.66) / 10000.0;
        var lambda_aux = (lambda - 26782.5) / 10000.0;

        // Process Swiss (MN95) North calculation.
        return 1200147.07
      + 308807.95 * phi_aux
      + 3745.25 * Math.pow(lambda_aux, 2)
      + 76.63 * Math.pow(phi_aux, 2)
      - 194.56 * Math.pow(lambda_aux, 2) * phi_aux
      + 119.79 * Math.pow(phi_aux, 3);
    }

    /**
     * Convert WGS coordinates latitude & longitude into Swiss (MN95) East value.
     *
     * @param float lat
     *   The WGS latitude coordinate point in degree
     * @param float long
     *   The WGS longitude coordinate point in degree
     *
     * @return float
     *   The converted WGS coordinates to Swiss (MN95) East
     */
    function fromWGSToMN95East(pLat, pLong)
    {
        // Converts Decimal Degrees to Sexagesimal Degree.
        var lat = degToSex(pLat);
        var long = degToSex(pLong);

        // Convert Decimal Degrees to Seconds of Arc.
        var phi = degToSec(lat);
        var lambda = degToSec(long);

        // Calculate the auxiliary values (differences of latitude and longitude
        // relative to Bern in the unit[10000"]).
        var phi_aux = (phi - 169028.66) / 10000.0;
        var lambda_aux = (lambda - 26782.5) / 10000.0;

        // Process Swiss (MN95) East calculation.
        return 2600072.37
      + 211455.93 * lambda_aux
      - 10938.51 * lambda_aux * phi_aux
      - 0.36 * lambda_aux * Math.pow(phi_aux, 2)
      - 44.54 * Math.pow(lambda_aux, 3);
    }

    /**
     * Convert Swiss (MN95) coordinates East & North to WGS latitude value.
     *
     * @param int east
     *   The East Swiss (MN95) coordinate point
     * @param int north
     *   The North Swiss (MN95) coordinate point
     *
     * @return float
     *   The converted Swiss (MN95) coordinates to WGS latitude
     */
    function fromMN95ToWGSLatitude(pEast, pNorth)
    {
        var east = pEast.toNumber();
        var north = pNorth.toNumber();
        
        // Convert the projection coordinates E (easting) and N (northing) in MN95
        // into the civilian system (Bern = 0 / 0) and express in the unit 1000 km.
        var y_aux = (east - 2600000) / 1000000;
        var x_aux = (north - 1200000) / 1000000;

        // Process latitude calculation.
        var lat = 16.9023892
      + 3.238272 * x_aux
      - 0.270978 * Math.pow(y_aux, 2)
      - 0.002528 * Math.pow(x_aux, 2)
      - 0.0447 * Math.pow(y_aux, 2) * x_aux
      - 0.0140 * Math.pow(x_aux, 3);

        // Unit 10000" to 1" and converts seconds to degrees notation.
        lat = lat * 100.0 / 36.0;

        return lat;
    }

    /**
     * Convert Swiss (MN95) coordinates East & North to WGS longitude value.
     *
     * @param int east
     *   The East Swiss (MN95) coordinate point
     * @param int north
     *   The North Swiss (MN95) coordinate point
     *
     * @return float
     *   The converted Swiss (MN95) coordinates to WGS longitude
     */
    function fromMN95ToWGSLongitude(pEast, pNorth)
    {
        var east = pEast.toNumber();
        var north = pNorth.toNumber();
    
        // Convert the projection coordinates E (easting) and N (northing) in MN95
        // into the civilian system (Bern = 0 / 0) and express in the unit 1000 km.
        var y_aux = (east - 2600000) / 1000000;
        var x_aux = (north - 1200000) / 1000000;

        // Process longitude calculation.
        var long = 2.6779094
      + 4.728982 * y_aux
      + 0.791484 * y_aux * x_aux
      + 0.1306 * y_aux * Math.pow(x_aux, 2)
      - 0.0436 * Math.pow(y_aux, 3);

        // Unit 10000" to 1" and converts seconds to degrees notation.
        long = long * 100.0 / 36.0;

        return long;
    }

    /**
     * Convert Swiss (MN03) coordinates y & x to WGS latitude value.
     *
     * @param int y
     *   The Y Swiss (MN03) coordinate point
     * @param int x
     *   The X Swiss (MN03) coordinate point
     *
     * @return float
     *   The converted Swiss (MN03) coordinates to WGS latitude
     */
    function fromMN03ToWGSLatitude(pY, pX)
    {
        var y = pY.toNumber();
        var x = pX.toNumber();
    
        // Convert the projection coordinates y and x in MN03 into the civilian
        // system (Bern = 0 / 0) and express in the unit [1000 km].
        var y_aux = (y - 600000) / 1000000;
        var x_aux = (x - 200000) / 1000000;

        // Process latitude calculation.
        var lat = 16.9023892
      + 3.238272 * x_aux
      - 0.270978 * Math.pow(y_aux, 2)
      - 0.002528 * Math.pow(x_aux, 2)
      - 0.0447 * Math.pow(y_aux, 2) * x_aux
      - 0.0140 * Math.pow(x_aux, 3);

        // Unit 10000" to 1" and converts seconds to degrees notation.
        lat = lat * 100 / 36;

        return lat;
    }

    /**
     * Convert Swiss (MN03) coordinates y & x to WGS longitude value.
     *
     * @param int y
     *   The Y Swiss (MN03) coordinate point
     * @param int x
     *   The X Swiss (MN03) coordinate point
     *
     * @return float
     *   The converted Swiss (MN03) coordinates to WGS longitude
     */
    function fromMN03ToWGSLongitude(pY, pX)
    {
        var y = pY.toNumber();
        var x = pX.toNumber();
    
        // Convert the projection coordinates y and x in MN03 into the civilian
        // system (Bern = 0 / 0) and express in the unit [1000 km].
        var y_aux = (y - 600000) / 1000000;
        var x_aux = (x - 200000) / 1000000;

        // Process longitude calculation.
        var long = 2.6779094
      + 4.728982 * y_aux
      + 0.791484 * y_aux * x_aux
      + 0.1306 * y_aux * Math.pow(x_aux, 2)
      - 0.0436 * Math.pow(y_aux, 3);

        // Unit 10000" to 1" and converts seconds to degrees notation.
        long = long * 100.0 / 36.0;

        return long;
    }

    /**
     * Convert Decimal Degrees to Sexagesimal Degrees.
     *
     * @param float|int angle
     *   The Decimal Degrees notation of angle to convert in Sexagesimal notation
     *
     * @return float|int
     *   The converted Decimal Degrees to Sexagesimal Degrees
     */
    function degToSex(angle)
    {
        // Extract D M'S".
        var deg = angle.toNumber();
        var min = ((angle - deg) * 60).toNumber();
        var sec = (((angle - deg) * 60) - min) * 60;

        // Result in degrees sec (dd.mmss)
        return deg + min / 100.0 + sec / 10000.0;
    }

    /**
     * Convert Decimal Degrees to Seconds of Arc (seconds only of D M'S").
     *
     * @param float|int angle
     *   The Decimal Degrees notation of angle to convert in Seconds of Arc
     *
     * @return float|int
     *   The converted Decimal Degrees to Seconds of Arc
     */
    function degToSec(angle)
    {
        // Extract D M'S".
        var deg = angle.toNumber();
        var min = ((angle - deg) * 100).toNumber();
        var sec = (((angle - deg) * 100) - min) * 100;

        // Result in degrees sec (dd.mmss).
        return sec + min * 60.0 + deg * 3600.0;
    }
}