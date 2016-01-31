using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class GpsPositionMenuDelegate extends Ui.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        if (item == :item_deg) {
            App.getApp().setGeoFormat(:const_deg);  // Degs
        } else if (item == :item_dm) {
            App.getApp().setGeoFormat(:const_dm);   // Degs/Mins
        } else if (item == :item_dms) {
            App.getApp().setGeoFormat(:const_dms);  // Degs/Mins/Secs
        } else if (item == :item_utm) {
            App.getApp().setGeoFormat(:const_utm);  // UTM (WGS84)
        } else if (item == :item_usng) {
            App.getApp().setGeoFormat(:const_usng); // USNG (WGS84)
        } else if (item == :item_mgrs) {
            App.getApp().setGeoFormat(:const_mgrs); // MGRS (WGS84)
        } else if (item == :item_ukgr) {
            App.getApp().setGeoFormat(:const_ukgr); // UK Grid (OSGB36)
        }
    } 
    
}
