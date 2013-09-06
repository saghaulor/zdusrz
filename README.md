zdusrz
======

A tool to call the Zendesk API and aggregate end user info into csv.

Dependencies: Ruby v1.9.3, git, bundler

Clone the code:

```#!bash
$ git clone https://saghaulor@bitbucket.org/saghaulor/zdusrz.git
``` 

Install the dependencies: 
```#!bash
$ cd zdusrz && bundle install
```
Create a credentials yml with your username and password: 
```#!bash
$ echo 'username: "<your zendesk username here>"\npassword: "<your zendesk password here>"' > auth.yml
```
Fetch the user list: 
```#!bash
$ bundle exec ruby zdusrz.rb
```
Profit: 
```#!bash
$ print 'money'
```
