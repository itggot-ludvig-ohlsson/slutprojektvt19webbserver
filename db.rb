def register(username, password)
    db = SQLite3::Database.new('db/db.db')

    password = BCrypt::Password.create(password)
    db.execute("INSERT INTO users (username, hashed_pass) VALUES (?,?)", username, password)
end

def login(username, password)
    db = SQLite3::Database.new('db/db.db')

    db.results_as_hash = true
    credentials = db.execute("SELECT id, hashed_pass FROM users WHERE username=?", username)[0]

    if credentials != nil && BCrypt::Password.new(credentials["hashed_pass"]) == password
        session[:user] = credentials["id"]
        true
    else
        false
    end
end