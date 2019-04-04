require 'sinatra'
require 'sqlite3'
require 'slim'
require 'bcrypt'

require_relative 'db.rb'

enable :sessions

get('/') do
    slim(:index)
end

get('/register') do
    slim(:register)
end

post('/register') do
    register(params["username"], params["password"])
    redirect('/login')
end

get('/login') do
    slim(:login)
end

post('/login') do
    success = login(params["username"], params["password"])
    if success
        redirect('/')
    else
        redirect('/login?fail=true')
    end
end