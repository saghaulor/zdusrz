zdusrz
======

A tool to call the Zendesk API and aggregate end user info into csv.

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
$ bundle exec ruby zdursz.rb
```
Profit: 
```#!bash
$ print 'money'
```
