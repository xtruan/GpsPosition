using Toybox.Math as Math;

/// CoordConvUtils.mc
///
/// Shared helper functions used by the various CoordConv* coordinate
/// conversion classes. Extracting these removes duplicated logic that
/// previously appeared (identically) in several files.
///
/// Marked (:glance) because it is used by classes that are compiled into
/// the glance-scope build (CoordConvSK42, CoordConvMaidenhead,
/// CoordConvWGS84Grids). Glance-scoped code is also included in the main
/// application build, so the non-glance classes (CoordConvLKS92,
/// CoordConvSwissGrid) and views can use it too.
(:glance)
module CoordConvUtils {

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
    // modulo operation (a % n)
    //
    function modulo(a, n) {
        return a - (n * (a / n).toNumber());
    }

    //
    // Transverse Mercator (Gauss-Kruger / Redfearn) projection.
    //
    // Projects a geodetic latitude/longitude onto a Transverse Mercator grid
    // using the standard Redfearn series. This is the shared math that was
    // previously duplicated in:
    //   * CoordConvSK42.SK42CoordsToSK42Grid  (SK-42 / USK-2000 grid)
    //   * CoordConvWGS84Grids.LLToOSGrid       (UK OSGB36 National Grid)
    //
    // All floating-point coefficients are used (5/4, 21/8, 15/8, 35/24). Note
    // that the previous UK-grid copy used integer-division for these
    // coefficients, which truncated them (e.g. 5/4 -> 1). Using the correct
    // float coefficients here fixes that latent inaccuracy.
    //
    // Parameters (angles in radians, distances in metres):
    //   latRad, lonRad - geodetic latitude/longitude of the point
    //   a, b           - ellipsoid semi-major / semi-minor axes
    //   F0             - central meridian scale factor
    //   lat0, lon0     - true origin latitude / central meridian
    //   N0, E0         - false northing / easting of the true origin
    //
    // Returns [Easting, Northing].
    //
    function latLonToTransverseMercator(latRad, lonRad, a, b, F0, lat0, lon0, N0, E0) {
        var e2 = (a * a - b * b) / (a * a);   // eccentricity squared
        var n = (a - b) / (a + b);
        var n2 = n * n;
        var n3 = n * n * n;

        var sinLat = Math.sin(latRad);
        var cosLat = Math.cos(latRad);
        var tanLat = Math.tan(latRad);

        var tan2lat = tanLat * tanLat;
        var tan4lat = tan2lat * tan2lat;
        var cos3lat = cosLat * cosLat * cosLat;
        var cos5lat = cos3lat * cosLat * cosLat;

        var nu = a * F0 * Math.pow(1 - e2 * sinLat * sinLat, -0.5);         // transverse radius of curvature
        var rho = a * F0 * (1 - e2) * Math.pow(1 - e2 * sinLat * sinLat, -1.5); // meridional radius of curvature
        var eta2 = nu / rho - 1;

        // meridional arc
        var Ma = (1 + n + (5.0 / 4.0) * n2 + (5.0 / 4.0) * n3) * (latRad - lat0);
        var Mb = (3.0 * n + 3.0 * n * n + (21.0 / 8.0) * n3) * Math.sin(latRad - lat0) * Math.cos(latRad + lat0);
        var Mc = ((15.0 / 8.0) * n2 + (15.0 / 8.0) * n3) * Math.sin(2 * (latRad - lat0)) * Math.cos(2 * (latRad + lat0));
        var Md = (35.0 / 24.0) * n3 * Math.sin(3 * (latRad - lat0)) * Math.cos(3 * (latRad + lat0));
        var M = b * F0 * (Ma - Mb + Mc - Md);

        var I = M + N0;
        var II = (nu / 2.0) * sinLat * cosLat;
        var III = (nu / 24.0) * sinLat * cos3lat * (5 - tan2lat + 9 * eta2);
        var IIIA = (nu / 720.0) * sinLat * cos5lat * (61 - 58 * tan2lat + tan4lat);
        var IV = nu * cosLat;
        var V = (nu / 6.0) * cos3lat * (nu / rho - tan2lat);
        var VI = (nu / 120.0) * cos5lat * (5 - 18 * tan2lat + tan4lat + 14 * eta2 - 58 * tan2lat * eta2);

        var dLon = lonRad - lon0;
        var dLon2 = dLon * dLon;
        var dLon3 = dLon2 * dLon;
        var dLon4 = dLon3 * dLon;
        var dLon5 = dLon4 * dLon;
        var dLon6 = dLon5 * dLon;

        var N = I + II * dLon2 + III * dLon4 + IIIA * dLon6;
        var E = E0 + IV * dLon + V * dLon3 + VI * dLon5;

        return [E, N];
    }
}
