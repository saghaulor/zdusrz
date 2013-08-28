require 'psych'
require 'faraday'
require 'faraday_middleware'
require 'csv'
#require 'pry-debugger'


credentials = Psych.load_file('auth.yml')
email = credentials['username']
password = credentials['password']

@client = Faraday.new(url: 'https://coupa.zendesk.com') do |conn|
  conn.basic_auth(email, password)
  conn.response :json, :content_type => /\bjson$/
  #conn.use FaradayMiddleware::Mashify 
  conn.adapter Faraday.default_adapter
end

def fetch_end_users(counter = 1)
  @client.get '/api/v2/users.json' do |req|
    req.headers['Content-Type'] = 'application/json'
    req.params['page'] = "#{counter}"
    req.params['role'] = 'end-user'
    #req.params['suspended'] = false
    #req.params['active'] = true
  end
end

@orgs = {}

def fetch_orgs(counter = 1)
  @client.get 'api/v2/organizations.json' do |req|
    req.params['page'] = "#{counter}"
    req.headers['Content-Type'] = 'application/json'
  end
end

def parse_orgs(response)
  response.body['organizations'].map do |org|
    @orgs["#{org['id']}"] = org['name']
  end
end

def fetch_all_end_users
  @response = fetch_end_users(1)
  until @response.body['next_page'].empty?
    counter += 1
    @response = fetch_end_users
    puts counter
  end
end

def add_to_csv(params)
  CSV.open(params[:filename], 'wb') do |row|
    row << [params[:name], params[:email], params[:org_name]]
  end
end

def org_name_lookup(org_id)
  @orgs[params[:org_id]]
end

def parse_name_orgid_and_email(response)
  response.body['users'].map do |user|
    name = user['name']
    email = user['email']
    org_name = org_name_lookup(user['organization_id'])
    add_to_csv(filename: csv_filename, name: name, email: email, org_name: org_name)
  end
end

csv_filename = "users_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv"
CSV.open(csv_filename, 'wb') do |header|
  header << ['user_name', 'email', 'organization_name']
end
#response = fetch_end_users(26)
#puts response.body
#fetch_all_end_users
