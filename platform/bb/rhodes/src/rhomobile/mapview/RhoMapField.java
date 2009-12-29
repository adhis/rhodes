package rhomobile.mapview;

import net.rim.device.api.ui.Field;

public interface RhoMapField {
	
	public Field getBBField();
	public void setPreferredSize(int width, int height);
	public void move(int dx, int dy);
	public void moveTo(double latitude, double longitude);
	
	public int getMinZoom();
	public int getMaxZoom();
	public void setZoom(int zoom);
	public int getZoom();
	
	public int getLeft();
	public int getTop();
	public int getWidth();
	public int getHeight();
	
	public int getContentLeft();
	public int getContentTop();
	public int getContentWidth();
	public int getContentHeight();

}
