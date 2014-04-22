require 'psych'
require 'faraday'
require 'faraday_middleware'
require 'csv'

credentials = Psych.load_file('auth.yml')
email = credentials['username']
password = credentials['password']

@client = Faraday.new(url: 'https://coupa.zendesk.com') do |conn|
  conn.basic_auth(email, password)
  conn.response :json, :content_type => /\bjson$/
  conn.adapter Faraday.default_adapter
end

def fetch_end_users(counter = 1)
  @client.get '/api/v2/users.json' do |req|
    req.headers['Content-Type'] = 'application/json'
    req.params['page'] = "#{counter}"
    req.params['role'] = 'end-user'
  end
end

def fetch_all_end_users
  counter = 1
  @response = fetch_end_users(counter)
  parse_name_org_id_and_email(@response)
  until @response.body['next_page'].nil? == true
    counter += 1
    @response = fetch_end_users(counter)
    parse_name_org_id_and_email(@response)
  end
end

def fetch_orgs(counter = 1)
  @client.get 'api/v2/organizations.json' do |req|
    req.params['page'] = "#{counter}"
    req.headers['Content-Type'] = 'application/json'
  end
end

def fetch_all_orgs
  counter = 1
  @response = fetch_orgs(counter)
  parse_orgs(@response)
  until @response.body['next_page'].nil? == true
    counter += 1
    @response = fetch_orgs(counter)
    parse_orgs(@response)
  end
end

def parse_orgs(response)
  response.body['organizations'].map do |org|
    @orgs["#{org['id']}"] = org['name']
  end
end

def add_users_to_csv(filename = @csv_filename, users = @users)
  CSV.open(filename, 'wb') do |row|
      row << ['username', 'email', 'org_id', 'org_name']
    users.map do |user|
      row << [user[:name], user[:email], user[:org_id], user[:org_name]]
    end
  end
end

def org_name_lookup(org_id)
  @orgs[org_id]
end

def parse_name_org_id_and_email(response) 
  response.body['users'].map do |user|
    @users << { name: user['name'], 
      email: user['email'], 
      org_id: user['organization_id'], 
      org_name: org_name_lookup(user['organization_id'].to_s) }
  end
end

@orgs = {}
@users = []

@csv_filename = "users_#{Time.now.strftime('%Y%m%d%H%M%S')}.csv"
CSV.open(@csv_filename, 'wb') do |header|
  header << ['user_name', 'email', 'organization_id', 'organization_name']
end

puts "Fetching organizations."
fetch_all_orgs
puts "Fetching end-users."
fetch_all_end_users
puts "Adding users and their org to #{@csv_filename}"
add_users_to_csv
puts "All done!"
