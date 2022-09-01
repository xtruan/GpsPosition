# GPS Position
GPS Position Watch App for Garmin ConnectIQ - https://apps.garmin.com/en-US/apps/12097123-2f57-4d59-afd7-2887c54c0732

Simple app to display current position information in a variety of different formats:
* Lat/Long in Degrees
* Lat/Long in Degrees/Mins
* Lat/Long in Degrees/Mins/Secs
* UTM (WGS84)
* USNG (WGS84)
* MGRS (WGS84)
* QTH Locator (Maidenhead / IARU)
* UK Grid (OSGB36)
* Swiss Grid (LV95)
* Swiss Grid (LV03)
* SK-42 (Degrees)
* SK-42 (Orthogonal)

Color of position text indicates GPS signal strength. Color of battery text indicates battery life. UTM/USNG/MGRS positions are using NAD83/WGS84 datum, UK Grid (Ordnance Survey National Grid) positions is using OSGB36 datum.

***NOTE: GPS must be turned on first by going to Settings - Sensors - GPS

Tested on simulator for all supported devices and on Forerunner 55 and vivoactive hardware.

Changelog:
* 3.1.3 - Added SK-42 formats.
* 3.1.1 - Better GNSS constellation support.
* 3.1.0 - Added Swiss grid. Major refactor/cleanup.
* 3.0.9 - Added Maidenhead Locator/QTH Locator/IARU Locator. Heading now displays in mil in MGRS mode.
* 3.0.7 - Refactored out GPS formatting into separate class.
* 3.0.6 - Changed storage mode to work with CIQ 4.0.0 and above.
* 3.0.5 - Added progress dots animation.
* 3.0.4 - Added support for additional devices.
* 3.0 - Added support for MANY more devices! Cleaned up layout to work better on more devices.
* 2.6 - Added support for vivoactive HR and Forerunner 735XT! Minor adjustments to layout.
* 2.5 - Making MGRS use the same logic as USNG since they have the same datum and should be equivalent.
* 2.4 - Added support for Forerunner 230, Forerunner 235, and Forerunner 630. Fixed southern hemisphere bug with UTM (thanks simonw42 and LeongSC!).
* 2.3 - Current speed now respects device distance unit setting (statue displays mph, metric displays km/h).
* 2.2 - Current position format is now maintained between launches. Thanks to hoanBK for the suggestion!
* 2.1 - Added UK Grid Reference (Ordnance Survey National Grid) support.
* 2.0 - Added support for round watches (D2 Bravo and fenix 3), and ForeAthelete/Forerunner 920XT! Rearranged the UI to make the coordinate data bigger. Removed "Fix" field.
* 1.9 - Added UTM and USNG formats and fixed MGRS (there seems to be a bug in the ConnectIQ API for converting position to MGRS so I implemented the conversions myself). Thanks to Drewing for pointing this out!
* 1.8 - Cleaned up icon
* 1.7 - Added epix support
* 1.4/1.5/1.6 - GUI fixes
* 1.3 - Added battery indicator
* 1.1/1.2 - GUI fixes
* 1.0 - Initial release