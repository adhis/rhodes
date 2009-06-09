package com.rho;

import rhomobile.RhoPhonebook;
import rhomobile.WebView;
import rhomobile.camera.Camera;

import com.xruby.runtime.builtin.RubyArray;
import com.xruby.runtime.lang.RubyProgram;
import com.xruby.runtime.lang.RubyRuntime;

import net.rim.device.api.system.DeviceInfo;

public class RhoRubyHelper implements IRhoRubyHelper {

	public void initRubyExtensions(){
        RhoPhonebook.initMethods(RubyRuntime.PhonebookClass);
        Camera.initMethods(RubyRuntime.CameraClass);
        WebView.initMethods(RubyRuntime.WebViewClass);
	}
	
	public RubyProgram createMainObject() {
		return new xruby.ServeME.main();
	}

	public String getPlatform() {
		return "Blackberry";
	}

	public void loadBackTrace(RubyArray backtrace) {
		//TODO:
	}

	public boolean hasNetwork() {
		//TODO: 
		return true;
	}

	public String getDeviceId(){
		return new Integer( DeviceInfo.getDeviceId() ).toString();
      }
}
