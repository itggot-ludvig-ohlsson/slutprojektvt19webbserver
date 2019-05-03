DB_PATH = 'db/db.db'

def register(username, password)
    db = SQLite3::Database.new(DB_PATH)

    password = BCrypt::Password.create(password)
    db.execute("INSERT INTO users (username, hashed_pass) VALUES (?, ?)", username, password)
end

def login(username, password)
    db = SQLite3::Database.new(DB_PATH)
    db.results_as_hash = true
    
    credentials = db.execute("SELECT id, hashed_pass FROM users WHERE username=?", username)[0]

    if credentials != nil && BCrypt::Password.new(credentials["hashed_pass"]) == password
        session[:account] = credentials["id"]
        true
    else
        false
    end
end

def get_user_info(id)
    db = SQLite3::Database.new(DB_PATH)
    db.results_as_hash = true

    db.execute("SELECT username, bio FROM users WHERE id=?", id)[0]
end

def update_bio(id, new_bio)
    db = SQLite3::Database.new(DB_PATH)
    db.execute("UPDATE users SET bio=? WHERE id=?", new_bio, id)
end

def get_sub_info(id)
    db = SQLite3::Database.new(DB_PATH)
    db.results_as_hash = true

    db.execute("SELECT name, about, owner FROM subs WHERE id=?", id)[0]
end

def update_sub_info(id, new_info)
    db = SQLite3::Database.new(DB_PATH)
    db.execute("UPDATE subs SET about=? WHERE id=?", new_info, id)
end

def new_sub(name, creator)
    db = SQLite3::Database.new(DB_PATH)
    db.results_as_hash = true

    db.execute("INSERT INTO subs (name, owner) VALUES (?, ?)", name, creator)
    db.execute("SELECT seq FROM sqlite_sequence WHERE name='subs'")
end

def get_subs()
    db = SQLite3::Database.new(DB_PATH)
    db.results_as_hash = true

    db.execute("SELECT id, name FROM subs")
end

def new_post(poster, sub, title, content)
    db = SQLite3::Database.new(DB_PATH)
    db.execute("INSERT INTO posts (title, content, owner, sub, votes) VALUES (?, ?, ?, ?, ?)", title, content, poster, sub, 0)
end

def get_posts(sub)
    db = SQLite3::Database.new(DB_PATH)
    db.results_as_hash = true

    db.execute("SELECT posts.id, title, username, owner, votes FROM posts INNER JOIN users ON users.id=posts.owner WHERE sub=?", sub)
end

def update_post(id, title, content)
    db = SQLite3::Database.new(DB_PATH)
    db.execute("UPDATE posts SET title=?, content=? WHERE id=?", title, content, id)
end

def get_all_posts()
    db = SQLite3::Database.new(DB_PATH)
    db.results_as_hash = true

    db.execute("SELECT posts.id, title, username, owner, votes FROM posts INNER JOIN users ON users.id=posts.owner")
end

def get_post_info(id)
    db = SQLite3::Database.new(DB_PATH)
    db.results_as_hash = true

    db.execute("SELECT owner, username, title, content, votes FROM posts INNER JOIN users ON users.id=posts.owner WHERE posts.id=?", id)[0]
end

def vote(id, voteup)
    db = SQLite3::Database.new(DB_PATH)

    if voteup
        db.execute("UPDATE posts SET votes=votes+1 WHERE id=?", id)
    else
        db.execute("UPDATE posts SET votes=votes-1 WHERE id=?", id)
    end
end

def delete(id)
    db = SQLite3::Database.new(DB_PATH)
    db.execute("DELETE FROM posts WHERE id=?", id)
end

def new_comment(commenter, post, content)
    db = SQLite3::Database.new(DB_PATH)
    db.execute("INSERT INTO comments (owner, post, content) VALUES (?, ?, ?)", commenter, post, content)
end

def get_comments(id)
    db = SQLite3::Database.new(DB_PATH)
    db.results_as_hash = true

    db.execute("SELECT owner, username, content FROM comments INNER JOIN users ON users.id=comments.owner WHERE post=?", id)
end