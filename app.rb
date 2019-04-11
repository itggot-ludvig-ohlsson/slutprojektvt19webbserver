require 'sinatra'
require 'sqlite3'
require 'slim'
require 'bcrypt'

require_relative 'db.rb'

enable :sessions

get('/') do
    slim(:index, locals: {subs: get_subs()})
end

get('/register') do
    slim(:register, locals: {subs: get_subs()})
end

post('/register') do
    register(params["username"], params["password"])
    redirect('/login')
end

get('/login') do
    slim(:login, locals: {subs: get_subs(), fail: params["fail"]})
end

post('/login') do
    success = login(params["username"], params["password"])
    if success
        redirect('/')
    else
        redirect('/login?fail=true')
    end
end

get('/user/:id') do
    id = params["id"].to_i
    usr = get_user_info(id)
    
    if usr
        slim(:user, locals: {subs: get_subs(), usr: usr})
    else
        redirect back
    end
end

get('/sub/create') do
    slim(:create_sub)
end

post('/sub/create') do
    id = new_sub(params["name"])[0][0]
    redirect("/sub/#{id}")
end

get('/sub/:id') do
    id = params["id"].to_i
    sub = get_sub_info(id)

    if sub
        slim(:sub, locals: {subs: get_subs(), sub: sub})
    else
        redirect back
    end
end