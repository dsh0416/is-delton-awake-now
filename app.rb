require 'bundler'
Bundler.require

configure {set :server, :puma}

$authority = JSON.parse(File.read('./config.json'))['authority']
# Example Config
# {"authority":["admin","admin"]}

helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == $authority
  end
end

result = false

get '/' do
  erb :index, locals: {result: result}
end

get '/awake' do
  protected!
  result = true
  result
  'Awake'
end

get '/asleep' do
  protected!
  result = false
  result
  'Asleep'
end