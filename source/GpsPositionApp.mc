using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class GpsPositionApp extends App.AppBase {

    hidden var geoFormat;
    
    function setGeoFormat(format) {
        geoFormat = format;
    }
    
    function getGeoFormat(format) {
        return geoFormat;
    }

    //! onStart() is called on application start up
    function onStart() {
        setGeoFormat(:const_dms);
    }

    //! onStop() is called when your application is exiting
    function onStop() {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [ new GpsPositionView(), new GpsPositionDelegate() ];
    }

}

class GpsPositionDelegate extends Ui.BehaviorDelegate {

    function onMenu() {
        var menu = new Rez.Menus.MainMenu();
        menu.setTitle("Coordinate Format");
        Ui.pushView(menu, new GpsPositionMenuDelegate(), Ui.SLIDE_UP);
        return true;
    }

}