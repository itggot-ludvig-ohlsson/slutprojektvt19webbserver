require 'sinatra'
require 'sqlite3'
require 'slim'
require 'bcrypt'

require_relative 'db.rb'

include Model

enable :sessions

# Display Landing Page
#
# @see Model#get_subs
# @see Model#get_all_posts
get('/') do
    slim(:index, locals: {session_id: session[:account], subs: get_subs(), posts: get_all_posts()})
end

# Displays registration page
#
# @see Model#get_subs
get('/register') do
    slim(:register, locals: {session_id: session[:account], subs: get_subs()})
end

# Registers a user and redirects to '/login'
#
# @param [String] username, The username to register
# @param [String] password, The password specified for the user
#
# @see Model#register
post('/register') do
    register(params["username"], params["password"])
    redirect('/login')
end

# Displays login page
#
# @param [Boolean] fail, The login failure boolean
#
# @see Model#get_subs
get('/login') do
    slim(:login, locals: {session_id: session[:account], subs: get_subs(), fail: params["fail"]})
end

# Attempts login, updates the session and redirects
#
# @param [String] username, The username specified
# @param [String] password, The password specified
#
# @see Model#login
post('/login') do
    session[:account] = login(params["username"], params["password"])
    if session[:account]
        redirect('/')
    else
        redirect('/login?fail=true')
    end
end

# Logs out by clearing session and redirects to '/'
#
post('/logout') do
    session.clear
    redirect('/')
end

# Displays the profile of an user
#
# @param [Integer] :id, The id of the user profile
#
# @see Model#get_user_info
# @see Model#get_subs
get('/user/:id') do
    id = params["id"].to_i
    usr = get_user_info(id)
    
    if usr
        slim(:user, locals: {session_id: session[:account], subs: get_subs(), usr: usr, profile_id: id})
    else
        redirect back
    end
end

# Displays the user profile editing page
#
# @param [Integer] :id, The id of the user profile
#
# @see Model#get_user_info
# @see Model#get_subs
get('/user/:id/edit') do
    id = params["id"].to_i
    usr = get_user_info(id)
    
    if session[:account] == id
        slim(:edit_user, locals: {session_id: session[:account], subs: get_subs(), usr: usr})
    else
        redirect back
    end
end

# Attempts to edit user profile and redirects to '/user/:id'
#
# @param [Integer] :id, The id of the user profile
# @param [String] bio-content, The updated user bio content
#
# @see Model#get_user_info
# @see Model#update_bio
post('/user/:id/edit') do
    id = params["id"].to_i
    usr = get_user_info(id)
    
    if session[:account] == id
        update_bio(id, params["bio-content"])
    end

    redirect("/user/#{id}")
end

# Displays sub creation page if logged in
#
# @see Model#get_subs
get('/sub/create') do
    if session[:account]
        slim(:create_sub, locals: {session_id: session[:account], subs: get_subs()})
    else
        redirect('/login')
    end
end

# Attempts to create sub and redirects
#
# @param [String] name, The name of the sub to create
#
# @see Model#new_sub
post('/sub/create') do
    if session[:account]
        if params["name"].length > 0 # still allows for a space as a name though
            id = new_sub(params["name"], session[:account])
            redirect("/sub/#{id}")
        else
            redirect back
        end
    else
        redirect("/login")
    end
end

# Displays a sub (with posts and sub info)
#
# @param [Integer] :id, The id of the sub
#
# @see Model#get_sub_info
# @see Model#get_subs
# @see Model#get_posts
get('/sub/:id') do
    id = params["id"].to_i
    sub = get_sub_info(id)

    if sub
        slim(:sub, locals: {session_id: session[:account], subs: get_subs(), sub: sub, sub_id: id, posts: get_posts(id)})
    else
        redirect back
    end
end

# Displays sub info editing page if logged in
#
# @param [Integer] :id, The id of the sub
#
# @see Model#get_sub_info
# @see Model#get_subs
get('/sub/:id/edit') do
    id = params["id"].to_i
    sub = get_sub_info(id)
    
    if session[:account] == sub["owner"]
        slim(:edit_sub, locals: {session_id: session[:account], subs: get_subs(), sub: sub})
    else
        redirect back
    end
end

# Attempts to edit sub info and redirects to '/sub/:id'
#
# @param [Integer] :id, The id of the sub
# @param [String] sub-info, The updated sub info
#
# @see Model#get_sub_info
# @see Model#update_sub_info
post('/sub/:id/edit') do
    id = params["id"].to_i
    sub = get_sub_info(id)
    
    if session[:account] == sub["owner"]
        update_sub_info(id, params["sub-info"])
    end

    redirect("/sub/#{id}")
end

# Displays post creation page if logged in
#
# @param [Integer] :id, The id of the sub where the user posts
#
# @see Model#get_sub_info
# @see Model#get_subs
get('/sub/:id/post') do
    if session[:account]
        id = params["id"].to_i
        sub = get_sub_info(id) # May need to variable name, seems to conflict with existing function

        slim(:create_post, locals: {session_id: session[:account], subs: get_subs(), sub: sub})
    else
        redirect('/login')
    end
end

# Attempts to post something to a sub, and then redirects to '/sub/:id'
#
# @param [Integer] :id, The id of the sub where the user posts
# @param [String] title, The title of the post
# @param [String] post-content, The content of the post
#
# @see Model#new_post
post('/sub/:id/post') do
    id = params["id"].to_i

    if session[:account]
        new_post(session[:account], id, params["title"], params["post-content"])
    end

    redirect("/sub/#{id}")
end

# Displays a post (with its title, content and comments)
#
# @param [Integer] :id, The id of the post
#
# @see Model#get_post_info
# @see Model#get_subs
# @see Model#get_comments
get('/post/:id') do
    id = params["id"].to_i
    post_info = get_post_info(id)

    if post_info
        slim(:post, locals: {session_id: session[:account], subs: get_subs(), post: post_info, id: id, comments: get_comments(id)})
    else
        redirect back
    end
end

# Displays post editing page if logged in
#
# @param [Integer] :id, The id of the post
#
# @see Model#get_post_info
# @see Model#get_subs
get('/post/:id/edit') do
    id = params["id"].to_i
    post = get_post_info(id)
    
    if session[:account] == post["owner"]
        slim(:edit_post, locals: {session_id: session[:account], subs: get_subs(), post: post})
    else
        redirect back
    end
end

# Attempts to edit post and then redirects to '/post/:id'
#
# @param [Integer] :id, The id of the post
# @param [String] title, The updated title of the post
# @param [String] post-content, The updated content of the post
#
# @see Model#get_post_info
# @see Model#update_post
post('/post/:id/edit') do
    id = params["id"].to_i
    post = get_post_info(id)
    
    if session[:account] == post["owner"]
        update_post(id, params["title"], params["post-content"])
    end

    redirect("/post/#{id}")
end

# Attempts to upvote a post and then redirects back
#
# @param [Integer] :id, The id of the post
#
# @see Model#vote
post('/post/:id/voteup') do
    id = params["id"].to_i

    if session[:account]
        vote(id, true)
    end

    redirect back
end

# Attempts to downvote a post and then redirects back
#
# @param [Integer] :id, The id of the post
#
# @see Model#vote
post('/post/:id/votedown') do
    id = params["id"].to_i

    if session[:account]
        vote(id, false)
    end

    redirect back
end

# Attempts to delete a post and then redirects to '/'
#
# @param [Integer] :id, The id of the post
#
# @see Model#get_post_info
# @see Model#delete
post('/post/:id/delete') do
    id = params["id"].to_i

    if session[:account] == get_post_info(id)["owner"]
        delete(id)
    end

    redirect('/')
end

# Displays commenting page if logged in
#
# @param [Integer] :id, The id of the post to comment on
#
# @see Model#get_post_info
# @see Model#get_subs
get('/post/:id/comment') do
    if session[:account]
        id = params["id"].to_i
        post = get_post_info(id)

        slim(:create_comment, locals: {session_id: session[:account], subs: get_subs(), post: post})
    else
        redirect('/login')
    end
end

# Attempts to comment on a post and then redirects to '/post/:id'
#
# @param [Integer] :id, The id of the post to comment on
# @param [String] comment-content, The content of the comment
#
# @see Model#new_comment
post('/post/:id/comment') do
    id = params["id"].to_i

    if session[:account]
        new_comment(session[:account], id, params["comment-content"])
    end

    redirect("/post/#{id}")
end