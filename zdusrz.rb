require 'psych'
require 'faraday'
require 'faraday_middleware'
require 'pry-debugger'


credentials = Psych.load_file('auth.yml')
email = credentials['username']
password = credentials['password']

client = Faraday.new(url: 'https://coupa.zendesk.com') do |conn|
  conn.basic_auth(email, password)
  conn.response :json, :content_type => /\bjson$/
  #conn.use FaradayMiddleware::Mashify 
  conn.adapter Faraday.default_adapter
end

@counter = 0
response = client.get '/api/v2/users.json' do |req|
  req.headers['Content-Type'] = 'application/json'
  req.params['page'] = "#{@counter}"
  req.params['role'] = 'end-user'
end

until response.body['next_page'].empty?
  @counter += 1
end
