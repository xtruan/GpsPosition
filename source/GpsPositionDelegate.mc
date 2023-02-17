using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class GpsPositionDelegate extends Ui.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
        var menu = new Rez.Menus.CoordFormatMenu();
        menu.setTitle("Coordinate Format");
        Ui.pushView(menu, new GpsPositionMenuDelegate(), Ui.SLIDE_UP);
        return true;
    }
    
    function onKey(key) {
        Sys.println("Key: " + key.getKey());
        if (key.getKey() == Ui.KEY_UP || key.getKey() == Ui.KEY_ENTER) {
            onMenu();
            return true;
        } else if (key.getKey() == Ui.KEY_ESC) {
        	Sys.println("Quitting!");
        	return false;
        }
        return false;
    }

}