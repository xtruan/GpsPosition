using Toybox.Application as App;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

class GpsPositionMenuDelegate extends Ui.MenuInputDelegate {

    function onMenuItem(item) {
        if (item == :item_deg) {
            App.getApp().setGeoFormat(:const_deg);
        } else if (item == :item_dm) {
            App.getApp().setGeoFormat(:const_dm);
        } else if (item == :item_dms) {
            App.getApp().setGeoFormat(:const_dms);
        } else if (item == :item_utm) {
            App.getApp().setGeoFormat(:const_utm);
        } else if (item == :item_usng) {
            App.getApp().setGeoFormat(:const_usng);
        } else if (item == :item_mgrs) {
            App.getApp().setGeoFormat(:const_mgrs);
        }
    } 
    
}
