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

get('/login') do
    slim(:login)
end