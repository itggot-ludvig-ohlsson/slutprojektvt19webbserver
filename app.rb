require 'sinatra'
require 'sqlite3'
require 'slim'
require 'bcrypt'

require_relative 'db.rb'

enable :sessions

get('/') do
    slim(:index, locals: {session_id: session[:account], subs: get_subs(), posts: get_all_posts()})
end

get('/register') do
    slim(:register, locals: {session_id: session[:account], subs: get_subs()})
end

post('/register') do
    register(params["username"], params["password"])
    redirect('/login')
end

get('/login') do
    slim(:login, locals: {session_id: session[:account], subs: get_subs(), fail: params["fail"]})
end

post('/login') do
    success = login(params["username"], params["password"])
    if success
        redirect('/')
    else
        redirect('/login?fail=true')
    end
end

post('/logout') do
    session.clear
    redirect('/')
end

get('/user/:id') do
    id = params["id"].to_i
    usr = get_user_info(id)
    
    if usr
        slim(:user, locals: {session_id: session[:account], subs: get_subs(), usr: usr, profile_id: id})
    else
        redirect back
    end
end

get('/user/:id/edit') do
    id = params["id"].to_i
    usr = get_user_info(id)
    
    if session[:account] == id
        slim(:edit_user, locals: {session_id: session[:account], subs: get_subs(), usr: usr})
    else
        redirect back
    end
end

post('/user/:id/edit') do
    id = params["id"].to_i
    usr = get_user_info(id)
    
    if session[:account] == id
        update_bio(id, params["bio-content"])
    end

    redirect("/user/#{id}")
end

get('/sub/create') do
    if session[:account]
        slim(:create_sub, locals: {session_id: session[:account], subs: get_subs()})
    else
        redirect('/login')
    end
end

post('/sub/create') do
    if session[:account]
        if params["name"].length > 0 # still allows for a space as a name though
            id = new_sub(params["name"], session[:account])[0][0]
            redirect("/sub/#{id}")
        else
            redirect back
        end
    else
        redirect("/login")
    end
end

get('/sub/:id') do
    id = params["id"].to_i
    sub = get_sub_info(id)

    if sub
        slim(:sub, locals: {session_id: session[:account], subs: get_subs(), sub: sub, sub_id: id, posts: get_posts(id)})
    else
        redirect back
    end
end

get('/sub/:id/edit') do
    id = params["id"].to_i
    sub = get_sub_info(id)
    
    if session[:account] == sub["owner"]
        slim(:edit_sub, locals: {session_id: session[:account], subs: get_subs(), sub: sub})
    else
        redirect back
    end
end

post('/sub/:id/edit') do
    id = params["id"].to_i
    sub = get_sub_info(id)
    
    if session[:account] == sub["owner"]
        update_sub_info(id, params["sub-info"])
    end

    redirect("/sub/#{id}")
end

get('/sub/:id/post') do
    if session[:account]
        id = params["id"].to_i
        sub = get_sub_info(id) # May need to variable name, seems to conflict with existing function

        slim(:create_post, locals: {session_id: session[:account], subs: get_subs(), sub: sub})
    else
        redirect('/login')
    end
end

post('/sub/:id/post') do
    id = params["id"].to_i

    if session[:account]
        new_post(session[:account], id, params["title"], params["post-content"])
    end

    redirect("/sub/#{id}")
end

get('/post/:id') do
    id = params["id"].to_i
    post_info = get_post_info(id)

    if post_info
        slim(:post, locals: {session_id: session[:account], subs: get_subs(), post: post_info, id: id, comments: get_comments(id)})
    else
        redirect back
    end
end

post('/post/:id/voteup') do
    id = params["id"].to_i

    if session[:account]
        vote(id, true)
    end

    redirect back
end

post('/post/:id/votedown') do
    id = params["id"].to_i

    if session[:account]
        vote(id, false)
    end

    redirect back
end

post('/post/:id/delete') do
    id = params["id"].to_i

    if session[:account] == get_post_info(id)["owner"]
        delete(id)
    end

    redirect('/')
end

get('/post/:id/comment') do
    if session[:account]
        id = params["id"].to_i
        post = get_post_info(id)

        slim(:create_comment, locals: {session_id: session[:account], subs: get_subs(), post: post})
    else
        redirect('/login')
    end
end

post('/post/:id/comment') do
    id = params["id"].to_i

    if session[:account]
        new_comment(session[:account], id, params["comment-content"])
    end

    redirect("/post/#{id}")
end