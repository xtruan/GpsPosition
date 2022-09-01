using Toybox.Math as Math;
using Toybox.System as Sys;

(:glance)
class CoordConvWGS84Grids {

/// CoordConvWGS84Grids.mc by Struan Clark (2015)
/// Major components translated to Monkey C from JavaScript libraries usng.js and osgridref.js

//// ***************************************************************************
// *  usng.js  (U.S. National Grid functions)
// *  Module to calculate National Grid Coordinates
// *
// *  last change or bug fix: February 2009
// ****************************************************************************/
//
// Copyright (c) 2009 Larry Moore, jane.larry@gmail.com

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */
//  osgridref.js  (Ordnance Survey Grid Reference functions)                                      */
//  Convert latitude/longitude <=> OS National Grid Reference points (c) Chris Veness 2005-2010   */
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -  */

// Released under the MIT License; see 
// http://www.opensource.org/licenses/mit-license.php 
// or http://en.wikipedia.org/wiki/MIT_License
//
// Permission is hereby granted, free of charge, to any person
// obtaining a copy of this software and associated documentation
// files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following
// conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
// OTHER DEALINGS IN THE SOFTWARE.
//
//
//****************************************************************************
//
//    References and history of this code:
//
//    For detailed information on the U.S. National Grid coordinate system, 
//    see  http://www.fgdc.gov/usng
//
//    Reference ellipsoids derived from Peter H. Dana's website- 
//    http://www.utexas.edu/depts/grg/gcraft/notes/datum/elist.html
//    Department of Geography, University of Texas at Austin
//    Internet: pdana@mail.utexas.edu   
//
//    Technical reference:
//    Defense Mapping Agency. 1987b. DMA Technical Report: Supplement to 
//    Department of Defense World Geodetic System 1984 Technical Report. Part I
//    and II. Washington, DC: Defense Mapping Agency
//
//    Originally based on C code written by Chuck Gantz for UTM calculations
//    http://www.gpsy.com/gpsinfo/geotoutm/     -- chuck.gantz@globalstar.com
// 
//    Converted from C to JavaScript by Grant Wong for use in the 
//    USGS National Map Project in August 2002
//
//    Modifications and developments continued by Doug Tallman from 
//    December 2002 through 2004 for the USGS National Map viewer
//
//    Adopted with modifications by Larry Moore, January 2007, 
//    for GoogleMaps application;  
//    http://www.fidnet.com/~jlmoore/usng
//
//    Assumes a datum of NAD83 (or its international equivalent WGS84). 
//    If NAD27 is used, set IS_NAD83_DATUM to 'false'. (This does
//    not do a datum conversion; it only allows either datum to 
//    be used for geographic-UTM/USNG calculations.)
//    NAD83 and WGS84 are equivalent for all practical purposes.
//    (NAD27 computations are irrelevant to Google Maps applications)
//  
//  
    
//******************************** Constants ********************************/
    
    var FOURTHPI    = Math.PI / 4;
    var DEG_2_RAD   = Math.PI / 180;
    var RAD_2_DEG   = 180.0 / Math.PI;
    var BLOCK_SIZE  = 100000; // size of square identifier (within grid zone designation),
                          // (meters)
    
// For diagram of zone sets, please see the "United States National Grid" white paper.
    var GRIDSQUARE_SET_COL_SIZE = 8;  // column width of grid square set  
    var GRIDSQUARE_SET_ROW_SIZE = 20; // row height of grid square set
    
// UTM offsets
    var EASTING_OFFSET  = 500000.0;   // (meters)
    var NORTHING_OFFSET = 10000000.0; // (meters)
    
// scale factor of central meridian
    var k0 = 0.9996;
    
    // NAD83/WGS84 datum
    var EQUATORIAL_RADIUS = 6378137.0; // GRS80 ellipsoid (meters)
    var ECC_SQUARED = 0.006694380023; 
    
    var ECC_PRIME_SQUARED = ECC_SQUARED / (1 - ECC_SQUARED);
    
// variable used in inverse formulas (UTMtoLL function)
    var E1 = (1 - Math.sqrt(1 - ECC_SQUARED)) / (1 + Math.sqrt(1 - ECC_SQUARED));
    
// Number of digits to display for x,y coords 
//  One digit:    10 km precision      eg. "18S UJ 2 1"
//  Two digits:   1 km precision       eg. "18S UJ 23 06"
//  Three digits: 100 meters precision eg. "18S UJ 234 064"
//  Four digits:  10 meters precision  eg. "18S UJ 2348 0647"
//  Five digits:  1 meter precision    eg. "18S UJ 23480 06470"
    
//************ retrieve zone number from latitude, longitude *************

//    Zone number ranges from 1 - 60 over the range [-180 to +180]. Each
//    range is 6 degrees wide. Special cases for points outside normal
//    [-80 to +84] latitude zone.

//************************************************************************/
    
    function getZoneNumber(lat, lon) {
    
      lat = parseFloat(lat);
      lon = parseFloat(lon);
    
      // sanity check on input
      ////////////////////////////////   /*
      if (lon > 360 || lon < -180 || lat > 90 || lat < -90) {
        Sys.println("Bad input. lat: " + lat + " lon: " + lon);
      }
      ////////////////////////////////  */
    
      // convert 0-360 to [-180 to 180] range
      var lonTemp = (lon + 180) - parseInt((lon + 180) / 360) * 360 - 180; 
      var zoneNumber = parseInt((lonTemp + 180) / 6) + 1;
    
      // Handle special case of west coast of Norway
      if ( lat >= 56.0 && lat < 64.0 && lonTemp >= 3.0 && lonTemp < 12.0 ) {
        zoneNumber = 32;
      }
    
      // Special zones for Svalbard
      if ( lat >= 72.0 && lat < 84.0 ) {
        if ( lonTemp >= 0.0  && lonTemp <  9.0 ) {
          zoneNumber = 31;
        } 
        else if ( lonTemp >= 9.0  && lonTemp < 21.0 ) {
          zoneNumber = 33;
        }
        else if ( lonTemp >= 21.0 && lonTemp < 33.0 ) {
          zoneNumber = 35;
        }
        else if ( lonTemp >= 33.0 && lonTemp < 42.0 ) {
          zoneNumber = 37;
        }
      }
      return zoneNumber;  
    } 
// END getZoneNumber() function
    
    
    
//**************** convert latitude, longitude to UTM  *******************

//    Converts lat/long to UTM coords.  Equations from USGS Bulletin 1532 
//    (or USGS Professional Paper 1395 "Map Projections - A Working Manual", 
//    by John P. Snyder, U.S. Government Printing Office, 1987.)
 
//    East Longitudes are positive, West longitudes are negative. 
//    North latitudes are positive, South latitudes are negative
//    lat and lon are in decimal degrees

//    output is in the input array utmcoords
//        utmcoords[0] = easting
//        utmcoords[1] = northing (NEGATIVE value in southern hemisphere)
//        utmcoords[2] = UTM zone
//        utmcoords[3] = zone number

//**************************************************************************/
    function LLtoUTM(lat,lon) {
      var utmcoords = new [4];
      // utmcoords is a 2-D array declared by the calling routine
    
      lat = parseFloat(lat);
      lon = parseFloat(lon);
    
      // sanity check on input - turned off when testing with Generic Viewer
      /////////////////////  /*
      if (lon > 360 || lon < -180 || lat > 90 || lat < -90) {
        Sys.println("Bad input. lat: " + lat + " lon: " + lon);
      }
      ////////////////////// */
    
      // Make sure the longitude is between -180.00 .. 179.99..
      // Convert values on 0-360 range to this range.
      var lonTemp = (lon + 180) - parseInt((lon + 180) / 360) * 360 - 180;
      var latRad = lat     * DEG_2_RAD;
      var lonRad = lonTemp * DEG_2_RAD;
    
      // integer...two digits
      var zoneNumber = getZoneNumber(lat, lon);
    
      var lonOrigin = (zoneNumber - 1) * 6 - 180 + 3;  // +3 puts origin in middle of zone
      var lonOriginRad = lonOrigin * DEG_2_RAD;
    
      // compute the UTM Zone from the latitude and longitude
      // 3 chars...two digits and letter
      var UTMZone = zoneNumber + "" + UTMLetterDesignator(lat);
    
      var N = EQUATORIAL_RADIUS / Math.sqrt(1 - ECC_SQUARED * 
                                Math.sin(latRad) * Math.sin(latRad));
      var T = Math.tan(latRad) * Math.tan(latRad);
      var C = ECC_PRIME_SQUARED * Math.cos(latRad) * Math.cos(latRad);
      var A = Math.cos(latRad) * (lonRad - lonOriginRad);
    
      // Note that the term Mo drops out of the "M" equation, because phi 
      // (latitude crossing the central meridian, lambda0, at the origin of the
      //  x,y coordinates), is equal to zero for UTM.
      var M = EQUATORIAL_RADIUS * (( 1 - ECC_SQUARED / 4         
            - 3 * (ECC_SQUARED * ECC_SQUARED) / 64     
            - 5 * (ECC_SQUARED * ECC_SQUARED * ECC_SQUARED) / 256) * latRad 
            - ( 3 * ECC_SQUARED / 8 + 3 * ECC_SQUARED * ECC_SQUARED / 32  
            + 45 * ECC_SQUARED * ECC_SQUARED * ECC_SQUARED / 1024) 
            * Math.sin(2 * latRad) + (15 * ECC_SQUARED * ECC_SQUARED / 256 
            + 45 * ECC_SQUARED * ECC_SQUARED * ECC_SQUARED / 1024) * Math.sin(4 * latRad) 
            - (35 * ECC_SQUARED * ECC_SQUARED * ECC_SQUARED / 3072) * Math.sin(6 * latRad));
    
      var UTMEasting = (k0 * N * (A + (1 - T + C) * (A * A * A) / 6
                      + (5 - 18 * T + T * T + 72 * C - 58 * ECC_PRIME_SQUARED )
                      * (A * A * A * A * A) / 120)
                      + EASTING_OFFSET);
    
      var UTMNorthing = (k0 * (M + N * Math.tan(latRad) * ( (A * A) / 2 + (5 - T + 9 
                      * C + 4 * C * C ) * (A * A * A * A) / 24
                      + (61 - 58 * T + T * T + 600 * C - 330 * ECC_PRIME_SQUARED )
                      * (A * A * A * A * A * A) / 720)));
    
      // added by LRM 2/08...not entirely sure this doesn't just move a bug somewhere else
      // sclark - looks like this was being done here and for USNG, moved it back to here and removed from USNG
      // utm values in southern hemisphere
      if (UTMNorthing < 0) {
          UTMNorthing += NORTHING_OFFSET;
      }
    
      utmcoords[0] = parseInt(UTMEasting);
      utmcoords[1] = parseInt(UTMNorthing);
      utmcoords[2] = UTMZone;
      
      // stash zone number in utmcoords[3] so we don't have to recompute later
      utmcoords[3] = zoneNumber;
      
      return utmcoords;
    }
// end LLtoUTM
    
    
//**************** convert latitude, longitude to USNG  *******************
//   Converts lat/lng to USNG coordinates.  Calls LLtoUTM first, then
//   converts UTM coordinates to a USNG string.

//    DEPRECATED: Returns string of the format: DDL LL DDDD DDDD (4-digit precision), eg:
//      "18S UJ 2286 0705" locates Washington Monument in Washington, D.C.
//      to a 10-meter precision.

//    output is in the input array usngcoords
//        utmcoords[3] = easting
//        utmcoords[4] = northing (NEGATIVE value in southern hemisphere)
//        utmcoords[1] = zone
//        utmcoords[2] = letters

//**************************************************************************/
    
    function LLtoUSNG(lat, lon, precision) {
    
      var usngcoords = new [4];

      lat = parseFloat(lat);
      lon = parseFloat(lon);
      
      // Constrain reporting USNG coords to the latitude range [80S .. 84N]
      //////////////////////
      if (lat > 84.0 || lat < -80.0){
          usngcoords[0] = "OUTSIDE RANGE";
          usngcoords[1] = "";
          usngcoords[2] = "";
          usngcoords[3] = "";
          return usngcoords;
      }
      //////////////////////
    
      // convert lat/lon to UTM coordinates
      var coords = LLtoUTM(lat, lon);
      var UTMEasting = coords[0];
      var UTMNorthing = coords[1];
      
      // get pre-computed zone number
      // integer...two digits
      var zoneNumber = coords[3];
    
      // ...then convert UTM to USNG
      
      var USNGLetters  = findGridLetters(zoneNumber, UTMNorthing, UTMEasting);
      var USNGNorthing = parseInt(UTMNorthing + 0.5) % BLOCK_SIZE;
      var USNGEasting  = parseInt(UTMEasting + 0.5)  % BLOCK_SIZE;
    
      // added... truncate digits to achieve specified precision
      USNGNorthing = parseInt(USNGNorthing / Math.pow(10,(5-precision)));
      USNGEasting = parseInt(USNGEasting / Math.pow(10,(5-precision)));
      
      var unsg_zone = getZoneNumber(lat, lon) +  UTMLetterDesignator(lat);
      var unsg_letters = USNGLetters;
      //var USNG = getZoneNumber(lat, lon) +  UTMLetterDesignator(lat) + " " + USNGLetters + " ";
    
      // REVISIT: Modify to incorporate dynamic precision ?
      var eastingStr = "" + USNGEasting;
      var unsg_easting = "";
      for (var i = eastingStr.length(); i < precision; i++) {
        unsg_easting += "0";
        //USNG += "0";
      }
    
      unsg_easting += USNGEasting;
      //USNG += USNGEasting + " ";
    
      var northingStr = "" + USNGNorthing;
      var unsg_northing = "";
      for (var i = northingStr.length(); i < precision; i++) {
        unsg_northing += "0";
        //USNG += "0";
      }
    
      unsg_northing += USNGNorthing;
      //USNG += USNGNorthing;
    
      usngcoords[0] = unsg_zone;
      usngcoords[1] = unsg_letters;
      usngcoords[2] = unsg_easting;
      usngcoords[3] = unsg_northing;
      
      return usngcoords;
    
      //return (USNG);
    
    }
// END LLtoUSNG() function
    
    
//************* retrieve grid zone designator letter **********************

//    This routine determines the correct UTM letter designator for the given 
//    latitude returns 'Z' if latitude is outside the UTM limits of 84N to 80S

//    Returns letter designator for a given latitude. 
//    Letters range from C (-80 lat) to X (+84 lat), with each zone spanning
//    8 degrees of latitude.

//**************************************************************************/
    
    function UTMLetterDesignator(lat) {
      lat = parseFloat(lat);
    
      var letterDesignator;
    
      if ((84 >= lat) && (lat >= 72)) {
        letterDesignator = "X";
      } else if ((72 > lat) && (lat >= 64)) {
        letterDesignator = "W";
      } else if ((64 > lat) && (lat >= 56)) {
        letterDesignator = "V";
      } else if ((56 > lat) && (lat >= 48)) {
        letterDesignator = "U";
      } else if ((48 > lat) && (lat >= 40)) {
        letterDesignator = "T";
      } else if ((40 > lat) && (lat >= 32)) {
        letterDesignator = "S";
      } else if ((32 > lat) && (lat >= 24)) {
        letterDesignator = "R";
      } else if ((24 > lat) && (lat >= 16)) {
        letterDesignator = "Q";
      } else if ((16 > lat) && (lat >= 8)) {
        letterDesignator = "P";
      } else if (( 8 > lat) && (lat >= 0)) {
        letterDesignator = "N";
      } else if (( 0 > lat) && (lat >= -8)) {
        letterDesignator = "M";
      } else if ((-8> lat) && (lat >= -16)) {
        letterDesignator = "L";
      } else if ((-16 > lat) && (lat >= -24)) { 
        letterDesignator = "K";
      } else if ((-24 > lat) && (lat >= -32)) {
        letterDesignator = "J";
      } else if ((-32 > lat) && (lat >= -40)) {
        letterDesignator = "H";
      } else if ((-40 > lat) && (lat >= -48)) {
        letterDesignator = "G";
      } else if ((-48 > lat) && (lat >= -56)) {
        letterDesignator = "F";
      } else if ((-56 > lat) && (lat >= -64)) {
        letterDesignator = "E";
      } else if ((-64 > lat) && (lat >= -72)) {
        letterDesignator = "D";
      } else if ((-72 > lat) && (lat >= -80)) {
        letterDesignator = "C";
      } else {
        letterDesignator = "Z"; // This is here as an error flag to show 
      }                        // that the latitude is outside the UTM limits
      
      return letterDesignator;
    }
// END UTMLetterDesignator() function
    
    
//***************** Find the set for a given zone. ************************

//    There are six unique sets, corresponding to individual grid numbers in 
//    sets 1-6, 7-12, 13-18, etc. Set 1 is the same as sets 7, 13, ..; Set 2 
//    is the same as sets 8, 14, ..

//    See p. 10 of the "United States National Grid" white paper.

//**************************************************************************/
    
    function findSet(zoneNum) {
    
      zoneNum = parseInt(zoneNum);
      zoneNum = zoneNum % 6; 
      
      if (zoneNum == 0) {
        return 6;
      } else if (zoneNum == 1) {
        return 1;
      } else if (zoneNum == 2) {
        return 2;
      } else if (zoneNum == 3) {
        return 3;
      } else if (zoneNum == 4) {
        return 4;
      } else if (zoneNum == 5) {
        return 5;
      } else {
        return -1;
      }
      
    }
// END findSet() function
    
    
//*************************************************************************  
//  Retrieve the square identification for a given coordinate pair & zone  
//  See "lettersHelper" function documentation for more details.
//**************************************************************************/
    
    function findGridLetters(zoneNum, northing, easting) {
    
      zoneNum  = parseInt(zoneNum);
      northing = parseFloat(northing);
      easting  = parseFloat(easting);
      var row = 1;
    
      // northing coordinate to single-meter precision
      var north_1m = parseInt(northing + 0.5);
    
      // Get the row position for the square identifier that contains the point
      while (north_1m >= BLOCK_SIZE) {
        north_1m = north_1m - BLOCK_SIZE;
        row++;
      }
    
      // cycle repeats (wraps) after 20 rows
      row = row % GRIDSQUARE_SET_ROW_SIZE;
      var col = 0;
    
      // easting coordinate to single-meter precision
      var east_1m = parseInt(easting + 0.5);
    
      // Get the column position for the square identifier that contains the point
      while (east_1m >= BLOCK_SIZE) {
        east_1m = east_1m - BLOCK_SIZE;
        col++;
      }
    
      // cycle repeats (wraps) after 8 columns
      col = col % GRIDSQUARE_SET_COL_SIZE;
    
      return lettersHelper(findSet(zoneNum), row, col);
    }
    
// END findGridLetters() function 
    
    
//*************************************************************************  
//    Retrieve the Square Identification (two-character letter code), for the
//    given row, column and set identifier (set refers to the zone set: 
//    zones 1-6 have a unique set of square identifiers; these identifiers are 
//    repeated for zones 7-12, etc.) 

//    See p. 10 of the "United States National Grid" white paper for a diagram
//    of the zone sets.

//**************************************************************************/
    
    function lettersHelper(set, row, col) {
    
      // handle case of last row
      if (row == 0) {
        row = GRIDSQUARE_SET_ROW_SIZE - 1;
      } 
      else {
        row--;
      }
    
      // handle case of last column
      if (col == 0) {
        col = GRIDSQUARE_SET_COL_SIZE - 1;
      }
      else {
        col--;     
      }
    
      //Sys.println("lettersHelper, " + col + " " + row);
    
      var l1;
      var l2;
      if (set == 1) {
        l1="ABCDEFGH";              // column ids
        l2="ABCDEFGHJKLMNPQRSTUV";  // row ids
        //Sys.println("set == 1, " + col + " " + row);
        return l1.substring(col,col+1) + l2.substring(row,row+1);
      } else if (set == 2) {
        l1="JKLMNPQR";
        l2="FGHJKLMNPQRSTUVABCDE";
        //Sys.println("set == 2, " + col + " " + row);
        return l1.substring(col,col+1) + l2.substring(row,row+1);
      } else if (set == 3) {
        l1="STUVWXYZ";
        l2="ABCDEFGHJKLMNPQRSTUV";
        //Sys.println("set == 3, " + col + " " + row);
        return l1.substring(col,col+1) + l2.substring(row,row+1);
      } else if (set == 4) {
        l1="ABCDEFGH";
        l2="FGHJKLMNPQRSTUVABCDE";
        //Sys.println("set == 4, " + col + " " + row);
        return l1.substring(col,col+1) + l2.substring(row,row+1);
      } else if (set == 5) {
        l1="JKLMNPQR";
        l2="ABCDEFGHJKLMNPQRSTUV";
        //Sys.println("set == 5, " + col + " " + row);
        return l1.substring(col,col+1) + l2.substring(row,row+1);
      } else if (set == 6) {
        l1="STUVWXYZ";
        l2="FGHJKLMNPQRSTUVABCDE";
        //Sys.println("set == 6, " + col + " " + row);
        return l1.substring(col,col+1) + l2.substring(row,row+1);
      } else {
        return "ZZ";
      }
    }
// END lettersHelper() function
    
//**************** convert latitude, longitude to UK National Grid  ********
//   Converts lat/lng to UK Grid coordinates. Converts from WGS84 to OSGB36 
//   datum by calling Wgs84ToOsgb36(). Calculates Northing and Easting and 
//   calls gridrefNumToLet()

//    output is based on output from gridrefNumToLet()
//**************************************************************************/
//
// convert geodesic co-ordinates to OS grid reference
//
    function LLToOSGrid(latDeg, longDeg) {
      
      // Glasgow, Scotland LL in WGS84 (for testing)
      //latDeg = 55.86246;
      //longDeg = -4.253709;
      // should return NS 59050 65549
      
      var osgb36LatLong = Wgs84ToOsgb36(latDeg, longDeg);
      
      //Sys.println("wgs84 - lat: " + latDeg.format("%.6f") + ", lon:" + longDeg.format("%.6f"));
      //Sys.println("osgb36 - lat: " + osgb36LatLong[0].format("%.6f") + ", lon:" + osgb36LatLong[1].format("%.6f"));
      
      var lat = DEG_2_RAD * osgb36LatLong[0];
      var lon = DEG_2_RAD * osgb36LatLong[1];
      
      var a = 6377563.396, b = 6356256.910;          // Airy 1830 major & minor semi-axes
      var F0 = 0.9996012717;                         // NatGrid scale factor on central meridian
      var lat0 = (DEG_2_RAD * 49), lon0 = (DEG_2_RAD * -2);  // NatGrid true origin
      var N0 = -100000, E0 = 400000;                 // northing & easting of true origin, metres
      var e2 = 1 - (b*b)/(a*a);                      // eccentricity squared
      var n = (a-b)/(a+b), n2 = n*n, n3 = n*n*n;
    
      var cosLat = Math.cos(lat);
      var sinLat = Math.sin(lat);
      var nu = a*F0/Math.sqrt(1-e2*sinLat*sinLat);              // transverse radius of curvature
      var rho = a*F0*(1-e2)/Math.pow(1-e2*sinLat*sinLat, 1.5);  // meridional radius of curvature
      var eta2 = nu/rho-1;
    
      var Ma = (1 + n + (5/4)*n2 + (5/4)*n3) * (lat-lat0);
      var Mb = (3*n + 3*n*n + (21/8)*n3) * Math.sin(lat-lat0) * Math.cos(lat+lat0);
      var Mc = ((15/8)*n2 + (15/8)*n3) * Math.sin(2*(lat-lat0)) * Math.cos(2*(lat+lat0));
      var Md = (35/24)*n3 * Math.sin(3*(lat-lat0)) * Math.cos(3*(lat+lat0));
      var M = b * F0 * (Ma - Mb + Mc - Md);              // meridional arc
    
      var cos3lat = cosLat*cosLat*cosLat;
      var cos5lat = cos3lat*cosLat*cosLat;
      var tan2lat = Math.tan(lat)*Math.tan(lat);
      var tan4lat = tan2lat*tan2lat;
    
      var I = M + N0;
      var II = (nu/2)*sinLat*cosLat;
      var III = (nu/24)*sinLat*cos3lat*(5-tan2lat+9*eta2);
      var IIIA = (nu/720)*sinLat*cos5lat*(61-58*tan2lat+tan4lat);
      var IV = nu*cosLat;
      var V = (nu/6)*cos3lat*(nu/rho-tan2lat);
      var VI = (nu/120) * cos5lat * (5 - 18*tan2lat + tan4lat + 14*eta2 - 58*tan2lat*eta2);
    
      var dLon = lon-lon0;
      var dLon2 = dLon*dLon;
      var dLon3 = dLon2*dLon;
      var dLon4 = dLon3*dLon;
      var dLon5 = dLon4*dLon;
      var dLon6 = dLon5*dLon;
    
      var N = I + II*dLon2 + III*dLon4 + IIIA*dLon6;
      var E = E0 + IV*dLon + V*dLon3 + VI*dLon5;
      
      //Sys.println("N: " + N.format("%.6f") + ", E:" + E.format("%.6f"));
    
      return gridrefNumToLet(E, N, 10);
    }
    // END findGridLetters() function 

//**************** convert grid ref numeric to standard-form  **************
//   converts numeric grid reference (in metres) to standard-form grid ref

//    output is in the array gridRef
//        gridRef[0] = letters (or error message)
//        gridRef[1] = easting (or blank)
//        gridRef[2] = northing (or blank)
//**************************************************************************/
    function gridrefNumToLet(e, n, digits) {
      // get the 100km-grid indices
      var e100k = parseInt(e/100000);
      var n100k = parseInt(n/100000);
      
      var gridRef = new [3];
      
      if (e100k<0 || e100k>6 || n100k<0 || n100k>12) {
        gridRef[0] = "OUTSIDE UK";
        gridRef[1] = "";
        gridRef[2] = "";
        return gridRef;
      }
    
      // translate those into numeric equivalents of the grid letters
      var l1 = (19-n100k) - (19-n100k)%5 + parseInt((e100k+10)/5);
      var l2 = (19-n100k)*5%25 + e100k%5;
    
      var alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZ";
      // compensate for skipped 'I' and build grid letter-pairs
      if (l1 > 7) {
        l1++;
      }
      if (l2 > 7) {
        l2++;
      }
      var letPair = alphabet.substring(l1,l1+1) + alphabet.substring(l2,l2+1);
    
      // strip 100km-grid indices from easting & northing, and reduce precision
      var denominator = Math.pow(10, 5-digits/2);
      var eNumerator = modulo(e,100000);
      var nNumerator = modulo(n,100000);
      var e2 = parseInt(eNumerator / denominator);
      var n2 = parseInt(nNumerator / denominator);
      
      gridRef[0] = letPair;
      gridRef[1] = padLZ(e2,digits/2);
      gridRef[2] = padLZ(n2,digits/2);
      
      // stringify
      //var ukgrid = gridRef[0] + " " + gridRef[1] + " " + gridRef[2];
    
      return gridRef;
    }
    
//**************** convert lat long from WGS84 datum to OSGB36 datum  *******
//   converts numeric grid reference (in metres) to standard-form grid ref
    
//    output is in the array osgb36LatLong
//        osgb36LatLong[0] = latitude (degrees)
//        osgb36LatLong[1] = longitude (degrees)
//**************************************************************************/
    function Wgs84ToOsgb36(lat, long) {
        // to cartesian
        var phi = lat * DEG_2_RAD;
        var lambda = long * DEG_2_RAD;
        var h = 0; // height above ellipsoid - not currently used
        var a = 6378137.0; // WGS84
        var b = 6356752.31425; // WGS84
    
        var sinphi = Math.sin(phi);
        var cosphi = Math.cos(phi);
        var sinlambda = Math.sin(lambda);
        var coslambda = Math.cos(lambda);
    
        var eSq = (a*a - b*b) / (a*a);
        var v = a / Math.sqrt(1 - eSq*sinphi*sinphi);
    
        var x1 = (v+h) * cosphi * coslambda;
        var y1 = (v+h) * cosphi * sinlambda;
        var z1 = ((1-eSq)*v + h) * sinphi;
        
        // transform datum
        var tx = -446.448; 
        var ty = 125.157;
        var tz = -542.060;
        var rx = (-0.1502/3600) * DEG_2_RAD; // normalise seconds to radians
        var ry = (-0.2470/3600) * DEG_2_RAD; // normalise seconds to radians
        var rz = (-0.8421/3600) * DEG_2_RAD; // normalise seconds to radians
        var s1 = 20.4894/1000000 + 1;        // normalise ppm to (s+1)

        // apply transform
        var x2 = tx + x1*s1 - y1*rz + z1*ry;
        var y2 = ty + x1*rz + y1*s1 - z1*rx;
        var z2 = tz - x1*ry + y1*rx + z1*s1;

        // to lat lon
        a = 6377563.396; // Airy1830
        b = 6356256.909; // Airy1830
    
        var e2 = (a*a-b*b) / (a*a); // 1st eccentricity squared
        var ee2 = (a*a-b*b) / (b*b); // 2nd eccentricity squared
        var p = Math.sqrt(x2*x2 + y2*y2); // distance from minor axis
        var R = Math.sqrt(p*p + z2*z2); // polar radius
    
        // parametric latitude (Bowring eqn 17, replacing tanbeta = z*a / p*b)
        var tanbeta = (b*z2)/(a*p) * (1+ee2*b/R);
        var sinbeta = tanbeta / Math.sqrt(1+tanbeta*tanbeta);
        var cosbeta = sinbeta / tanbeta;
    
        var osgb36LatLong = new [2];
        
        // geodetic latitude (Bowring eqn 18)
        osgb36LatLong[0] = atan2(z2 + ee2*b*sinbeta*sinbeta*sinbeta, p - e2*a*cosbeta*cosbeta*cosbeta) * RAD_2_DEG;
    
        // longitude
        osgb36LatLong[1] = atan2(y2, x2) * RAD_2_DEG;
        
        return osgb36LatLong;
    }
    
//
// pad a number with sufficient leading zeros to make it w chars wide
//
    function padLZ(num, w) {
      var n = num.format("%i");
      for (var i = 0; i < w-n.length(); i++) {
        n = "0" + n;
      }
      return n;
    }

//
// atan2 function using built in atan function
//
    function atan2(y, x)  {
        if (x > 0) {
            return Math.atan(y/x);
        } else if (y >= 0 && x < 0) {
            return Math.atan(y/x) + Math.PI;
        } else if (y < 0 && x < 0) {
            return Math.atan(y/x) - Math.PI;
        } else if (y > 0 && x == 0) {
            return (Math.PI)/2;
        } else if (y < 0 && x == 0) {
            return -(Math.PI)/2;
        } else {
            return -999;
        }
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
    
//
// modulo operation
//
    function modulo(a, n) {
        // a % n
        return a - (n * (a/n).toNumber());
    }
    
}
