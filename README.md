# GPS Position
GPS Position app for Garmin ConnectIQ - https://apps.garmin.com/en-US/apps/12097123-2f57-4d59-afd7-2887c54c0732

Simple app to display current position information in a variety of different formats. Color of position text indicates GPS signal strength, color of battery text indicates battery life. UTM/USNG/MGRS positions are using NAD83/WGS84 datum, UK Grid (Ordnance Survey National Grid) positions is using OSGB36 datum.
***NOTE: GPS must be turned on first by going to Settings - Sensors - GPS

Tested on simulator for all supported devices and on vivoactive hardware.

Changelog:
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
