require 'bundler'
Bundler.require
require 'yaml'

configure {set :server, :puma}
$config =  YAML.load_file('./config.yaml')

helpers do
  def protected!
    return if authorized?
    headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
    halt 401, "Not authorized\n"
  end

  def authorized?
    @auth ||=  Rack::Auth::Basic::Request.new(request.env)
    @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == [$config['authority']['username'], $config['authority']['password']]
  end
end

result = $config['option'][$config['default']]

get '/' do
  erb :index, locals: {result: result, title: $config['title']}
end

get '/:option' do |option|
  protected!
  return 'No that option' if $config['option'][option].nil?
  result = $config['option'][option]
  result['text']
end