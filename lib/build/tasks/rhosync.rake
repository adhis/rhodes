require 'json'
require 'mechanize'
require 'zip/zip'

namespace "rhosync" do
  task :config => "config:common" do
    $host = 'localhost'
    $port = '9292'
    $url = "http://#{$host}:#{$port}"
    $agent = WWW::Mechanize.new
    $appname = $app_basedir.gsub(/\\/, '/').split('/').last
    $token_file = File.join(ENV['HOME'],'.rhosync_token')
    $token = File.read($token_file) if File.exist?($token_file)
  end
  
  desc "Fetches current api token from rhosync"
  task :get_api_token => :config do
    login = ask "Login: "
    password = ask "Password: "
    $agent.post("#{$url}/login", :login => login, :password => password)
    $token = $agent.post("#{$url}/api/get_api_token").body
    File.open($token_file,'w') {|f| f.write $token}
    puts "Token is saved in: #{$token_file}"
  end
  
  desc "Imports an application into rhosync"
  task :import_app => :config do
    name = File.join($app_basedir,'rhosync')
    compress(name)
    $agent.post("#{$url}/api/import_app",
      :app_name => $appname, :api_token => $token,
      :upload_file =>  File.new(File.join($app_basedir,'rhosync','rhosync.zip'), "rb"))
    FileUtils.rm archive(name), :force => true
    print_resp(nil)
  end
  
  desc "Deletes an application from rhosync"
  task :delete_app => :config do
    post("/api/delete_app", :app_name => $appname, :api_token => $token)
  end
  
  desc "Creates and subscribes user for application in rhosync"
  task :create_user => :config do
    login = ask "login: "
    password = ask "password: "
    post("/api/create_user", {:app_name => $appname, :api_token => $token,
      :attributes => {:login => login, :password => password}})
  end
  
  desc "Updates an existing user in rhosync"
  task :update_user => :config do
    login = ask "login: "
    password = ask "password: "
    new_password = ask "new password: "
    post("/api/update_user", {:app_name => $appname, :api_token => $token,
      :login => login, :password => password, :attributes => {:new_password => new_password}})
  end
  
  desc "List applications installed in rhosync"
  task :list_apps => :config do
    post("/api/list_apps", :api_token => $token)
  end
end

def post(path,params)
  req = Net::HTTP.new($host,$port)
  resp = req.post(path, params.to_json, 'Content-Type' => 'application/json')
  print_resp(resp, resp.is_a?(Net::HTTPSuccess) ? true : false)
end

def print_resp(resp,success=true)
  if success
    puts "=> OK" 
  else
    puts "=> FAILED"
  end
  puts resp.body if resp and resp.body and resp.body.length > 0
end

def archive(path)
  File.join(path,File.basename(path))+'.zip'
end

def ask(msg)
  print msg
  STDIN.gets.chomp
end

def compress(path)
  path.sub!(%r[/$],'')
  FileUtils.rm archive(path), :force=>true
  Zip::ZipFile.open(archive(path), 'w') do |zipfile|
    Dir["#{path}/**/**"].reject{|f|f==archive(path)}.each do |file|
      zipfile.add(file.sub(path+'/',''),file)
    end
    zipfile.close
  end
end