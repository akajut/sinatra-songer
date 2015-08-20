class AssetHandler < Sinatra::Base
  #cofiguring assets directories for app...
  configure do
    set  :views, File.dirname(__FILE__) + '/assets'
    set  :jsdir, 'js'
    set  :cssdir, 'css'
    enable  :coffeescript
    set  :cssengine, 'scss'
  end
  #caching for coffeescript...
  get '/javascripts/*.js' do
    pass unless settings.coffeescript?
    last_modified File.mtime(settings.root+'/assets/'+settings.jsdir)
    cache_control :public, :must_revalidate
    coffee (settings.jsdir + '/' + params[:splat].first).to_sym
  end

  #caching for css...
  get '/*.css' do
    last_modified File.mtime(settings.root + '/assets/' + settings.cssdir)
    cache_control :public, :must_revalidate
    send(settings.cssengine, (settings.cssdir + '/' + params[:splat].first).to_sym)
  end
end