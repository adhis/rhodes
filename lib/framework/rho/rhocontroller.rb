require 'rho/render'
require 'rho/rhosupport'
require 'rho/rhoviewhelpers'

module Rho
  class RhoController
  	attr_accessor :menu

    @@rholog = RhoLog.new

    def rho_info(str)
      @@rholog.info("RHO " + self.class.to_s, str)
    end

    def rho_error(str)
      @@rholog.error("RHO " + self.class.to_s, str)
    end

    def app_info(str)
      @@rholog.info("APP " + self.class.to_s, str)
    end

    def app_error(str)
      @@rholog.error("APP " + self.class.to_s, str)
    end

    def default_action
      return Hash['GET','show','PUT','update','POST','update',
        'DELETE','delete'][@request['request-method']] unless @request['id'].nil?
      return Hash['GET','index','POST','create'][@request['request-method']]
    end

    def serve(application,object_mapping,req,res)
      @request, @response = req, res
      @object_mapping = object_mapping
      @params = RhoSupport::query_params req
      @rendered = false
      @redirected = false
      
      act = req['action'].nil? ? default_action : req['action']
      if self.respond_to?(act)
        res = send req['action'].nil? ? default_action : req['action']
      else
        rho_error( "Action '#{act}' does not exist in controller or has private access."  )
      end
      
      if @params['rho_callback'] == "1"
        res = "" unless res.is_a?(String)
      else
        res = render unless @rendered or @redirected
      end
        
      application.set_menu(@menu, @back_action)
  	  @menu = nil
  	  @back_action = nil;
  	  res
    end

    # Returns true if the request's header contains "XMLHttpRequest".
    def xml_http_request?
      not /XMLHttpRequest/i.match(@request['headers']['X-Requested-With']).nil?
    end
    alias xhr? :xml_http_request?

    def redirect(url_params = {},options = {})
      if @params['rho_callback'] == "1"
        rho_error( "redirect call in callback. Call WebView.navigate instead" ) 
        return ""
      end  
    
      @redirected = true
      @response['status'] = options['status'] || 302 
      @response['headers']['Location'] = url_for(url_params)
      @response['message'] = options['message'] || 'Moved temporarily'
      return ''
    end
    
    def strip_braces(str=nil)
      str ? str.gsub(/\{/,"").gsub(/\}/,"") : nil
    end

  end # RhoController
end # Rho