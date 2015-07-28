class AssetHandler < Sinatra::Base
  configure do
    set  :views, File.dirname(__FILE__) + '/assets'
    set  :jsdir, 'js'
    set  :cssdir, "css"
    enable  :coffecript
    set  :cssengine, 'scss'
  end

  get '/javascripts/*.js' do
    pass unless settings.coffecript?
    last_modified File.mtime(settings.root+'/assets'.jsdir)
    cache_control :public, :must_revalidate
    coffee (settings.jsdir + '/' + params[:splat].first).to_sym
  end

  get '/*.css' do
    last_modified File.mtime(settings.root+'/assets'.cssdir)
    cache_control :public, :must_revalidate
    send(settings.cssengine, (settings.cssdir + '/' + params[:splat].first).to_sym)
  end
end