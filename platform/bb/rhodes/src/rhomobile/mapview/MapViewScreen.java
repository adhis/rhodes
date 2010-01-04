package rhomobile.mapview;

import com.rho.RhoEmptyLogger;
import com.rho.RhoLogger;

import net.rim.device.api.system.Application;
import net.rim.device.api.system.Display;
import net.rim.device.api.system.KeypadListener;
import net.rim.device.api.ui.Graphics;
import net.rim.device.api.ui.MenuItem;
import net.rim.device.api.ui.container.MainScreen;

public class MapViewScreen extends MainScreen {
	
	private static final RhoLogger LOG = RhoLogger.RHO_STRIP_LOG ? new RhoEmptyLogger() : 
		new RhoLogger("MapViewScreen");
	
	private static final int PAN_MODE = 1;
	private static final int ZOOM_MODE = 2;
	
	private static final MapProvider[] providers = {
		new BBMapProvider(),
		new GoogleMapProvider()
	};
	
	private MapProvider mapProvider;
	private RhoMapField mapField;
	
	private int mode;
	
	/*
	private class CloseMenuItem extends MenuItem {
		
		private MapViewScreen screen;
		
		public CloseMenuItem(MapViewScreen scr, String text, int ordinal, int priority) {
			super(text, ordinal, priority);
			screen = scr;
		}

		public void run() {
			screen.close();
		}
	}
	*/
	
	MapViewScreen(String providerName, double lat, double lon, int zoom) {
		super(DEFAULT_MENU | DEFAULT_CLOSE);
		//MenuItem closeItem = new CloseMenuItem(this, "Close", 0, 100);
		//addMenuItem(closeItem);
		createMapProvider(providerName);
		createUI(lat, lon, zoom);
	}
	
	private void createMapProvider(String providerName) {
		mapProvider = null;
		for (int i = 0; i != providers.length; ++i) {
			if (providers[i].accept(providerName)) {
				mapProvider = providers[i];
				break;
			}
		}
		if (mapProvider == null)
			throw new IllegalArgumentException("Unknown map provider: " + providerName);
	}
	
	private void createUI(double lat, double lon, int zoom) {
		synchronized (Application.getEventLock()) {
			mapField = mapProvider.createMap();
			mapField.setPreferredSize(Display.getWidth(), Display.getHeight());
			add(mapField.getBBField());
		}
		
		mapField.moveTo(lat, lon);
		mapField.setZoom(zoom);
		
		mode = PAN_MODE;
	}
	
	/**
	 * Handle trackball click events.
	 * @see net.rim.device.api.ui.Screen#invokeAction(int)
	 */   
	protected boolean invokeAction(int action)
	{
		boolean handled = super.invokeAction(action);

		if(!handled)
		{
			switch(action)
			{
    			case ACTION_INVOKE: // Trackball click.
    			{
    				return true;
    			}
			}
		}
		return handled;
	}
	
	protected void paint(Graphics graphics) {
		super.paint(graphics);
		
		// TODO: draw overlays here
		graphics.setColor(0x00000000); // Black
		// Draw black cross at center
		int xCenter = mapField.getLeft() + mapField.getWidth()/2;
		int yCenter = mapField.getTop() + mapField.getHeight()/2;
		int delta = 10;
		int yTop = yCenter - delta;
		int yBottom = yCenter + delta;
		int xLeft = xCenter - delta;
		int xRight = xCenter + delta;
		graphics.drawLine(xCenter, yTop, xCenter, yBottom);
		graphics.drawLine(xLeft, yCenter, xRight, yCenter);
		
		// Draw current mode
		String strMode  = null;
		if (mode == PAN_MODE)
			strMode = "Pan mode";
		else if (mode == ZOOM_MODE)
			strMode = "Zoom mode";
		
		if (strMode != null) {
			int x = mapField.getLeft() + mapField.getWidth()/2 - 60;
			int y = mapField.getTop() + mapField.getHeight() - 40;
			graphics.drawText(strMode, x, y);
		}
	}
	
	protected boolean navigationMovement(int dx, int dy, int status, int time) {
		if ((status & KeypadListener.STATUS_TRACKWHEEL) == 0 &&
				(status & KeypadListener.STATUS_FOUR_WAY) == 0)
			return false;

		if (mode == PAN_MODE) {
			int newDx = dx*10;
			int newDy = dy*10;
			LOG.TRACE("Scroll by " + newDx + "," + newDy);
			mapField.move(newDx, newDy);
		}
		else if (mode == ZOOM_MODE && dy != 0) {
			int currentZoom = mapField.getZoom();
			int minZoom = mapField.getMinZoom();
			int maxZoom = mapField.getMaxZoom();
			
			int newZoom;
			if (dy > 0) {
				newZoom = Math.max(currentZoom - 1, minZoom);
			}
			else {
				newZoom = Math.min(currentZoom + 1, maxZoom);
			}
			LOG.TRACE("Set zoom to " + newZoom + " (was " + currentZoom + ")");
			mapField.setZoom(newZoom);
		}
		return true;
	}
	
	protected boolean trackwheelClick(int status, int time) {
		if (mode == PAN_MODE)
			mode = ZOOM_MODE;
		else if (mode == ZOOM_MODE)
			mode = PAN_MODE;
		else
			return false;
		
		invalidate();
		return true;
	}
}
