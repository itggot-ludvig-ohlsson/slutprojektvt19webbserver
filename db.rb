DB_PATH = 'db/db.db'

def register(username, password)
    db = SQLite3::Database.new(DB_PATH)

    password = BCrypt::Password.create(password)
    db.execute("INSERT INTO users (username, hashed_pass) VALUES (?,?)", username, password)
end

def login(username, password)
    db = SQLite3::Database.new(DB_PATH)
    db.results_as_hash = true
    
    credentials = db.execute("SELECT id, hashed_pass FROM users WHERE username=?", username)[0]

    if credentials != nil && BCrypt::Password.new(credentials["hashed_pass"]) == password
        session[:user] = credentials["id"]
        true
    else
        false
    end
end

def get_user_info(id)
    db = SQLite3::Database.new(DB_PATH)
    db.results_as_hash = true

    db.execute("SELECT username FROM users WHERE id=?", id)[0]
end

def get_sub_info(id)
    db = SQLite3::Database.new(DB_PATH)
    db.results_as_hash = true

    db.execute("SELECT name, about FROM subs WHERE id=?", id)[0]
end