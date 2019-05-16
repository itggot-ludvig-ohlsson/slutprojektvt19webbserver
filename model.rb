module Model
    DB_PATH = 'db/db.db'

    # Checks if any string in a hash is blank
    #
    # @param [Hash] fields, The hash
    def any_field_empty(fields)
        fields.each_value do |field|
            if field.strip.empty?
                return true
            end
        end

        false
    end

    # Creates a new user
    #
    # @param [String] username The username
    # @param [String] password The password
    def register(username, password)
        db = SQLite3::Database.new(DB_PATH)

        password = BCrypt::Password.create(password)
        db.execute("INSERT INTO users (username, hashed_pass) VALUES (?, ?)", username, password)
    end

    # Attempts to login
    #
    # @param [String] username The username
    # @param [String] password The password
    #
    # @return [Integer] The id of the user that was attempted to login to
    def login(username, password)
        db = SQLite3::Database.new(DB_PATH)
        db.results_as_hash = true
        
        credentials = db.execute("SELECT id, hashed_pass FROM users WHERE username=?", username)[0]

        if credentials != nil && BCrypt::Password.new(credentials["hashed_pass"]) == password
            credentials["id"]
        end
    end

    # Gets user info
    #
    # @param [Integer] id The user id
    #
    # @return [Hash]
    #   * "username" [String] The username
    #   * "bio" [String] The user's bio
    def get_user_info(id)
        db = SQLite3::Database.new(DB_PATH)
        db.results_as_hash = true

        db.execute("SELECT username, bio FROM users WHERE id=?", id)[0]
    end

    # Updates user bio
    #
    # @param [Integer] id The user id
    # @param [String] new_bio The updated user bio contents
    def update_bio(id, new_bio)
        db = SQLite3::Database.new(DB_PATH)
        db.execute("UPDATE users SET bio=? WHERE id=?", new_bio, id)
    end

    # Gets sub info
    #
    # @param [Integer] id The sub id
    #
    # @return [Hash]
    #   * "name" [String] The name of the sub
    #   * "about" [String] The sub's about info
    #   * "owner" [Integer] The sub's owner id
    def get_sub_info(id)
        db = SQLite3::Database.new(DB_PATH)
        db.results_as_hash = true

        db.execute("SELECT name, about, owner FROM subs WHERE id=?", id)[0]
    end

    # Updates sub about info
    #
    # @param [Integer] id The sub id
    # @param [String] new_info The updated sub about info
    def update_sub_info(id, new_info)
        db = SQLite3::Database.new(DB_PATH)
        db.execute("UPDATE subs SET about=? WHERE id=?", new_info, id)
    end

    # Creates a new sub
    #
    # @param [String] name The name of the sub
    # @param [Integer] creator The sub creator's user id
    #
    # @return [Integer] The id of the created sub
    def new_sub(name, creator)
        db = SQLite3::Database.new(DB_PATH)
        db.results_as_hash = true

        db.execute("INSERT INTO subs (name, owner) VALUES (?, ?)", name, creator)
        db.execute("SELECT seq FROM sqlite_sequence WHERE name='subs'")[0][0]
    end

    # Gets info about all subs
    #
    # @return [Array<Hash>]
    #   * "id" [Integer] The id of the sub
    #   * "name" [String] The name of the sub
    def get_subs()
        db = SQLite3::Database.new(DB_PATH)
        db.results_as_hash = true

        db.execute("SELECT id, name FROM subs")
    end

    # Creates a new post
    #
    # @param [Integer] poster The poster's user id
    # @param [Integer] sub The sub where to post
    # @param [String] title The post title
    # @param [String] content The post content
    def new_post(poster, sub, title, content)
        db = SQLite3::Database.new(DB_PATH)
        db.execute("INSERT INTO posts (title, content, owner, sub, votes) VALUES (?, ?, ?, ?, ?)", title, content, poster, sub, 0)
    end

    # Gets info about all posts in a sub
    #
    # @param [Integer] sub The sub id where the post is
    #
    # @return [Array<Hash>]
    #   * "id" [Integer] The id of the post
    #   * "title" [String] The title of the post
    #   * "username" [String] The username of the post creator
    #   * "owner" [Integer] The user id of the post creator
    #   * "votes" [Integer] The amount of votes the post has
    def get_posts(sub)
        db = SQLite3::Database.new(DB_PATH)
        db.results_as_hash = true

        db.execute("SELECT posts.id, title, username, owner, votes FROM posts INNER JOIN users ON users.id=posts.owner WHERE sub=?", sub)
    end

    # Updates a post
    #
    # @param [Integer] id The post id
    # @param [String] title The post title
    # @param [String] content The post content
    def update_post(id, title, content)
        db = SQLite3::Database.new(DB_PATH)
        db.execute("UPDATE posts SET title=?, content=? WHERE id=?", title, content, id)
    end

    # Gets info about all posts
    #
    # @return [Array<Hash>]
    #   * "id" [Integer] The id of the post
    #   * "title" [String] The title of the post
    #   * "username" [String] The username of the post creator
    #   * "owner" [Integer] The user id of the post creator
    #   * "votes" [Integer] The amount of votes the post has
    def get_all_posts()
        db = SQLite3::Database.new(DB_PATH)
        db.results_as_hash = true

        db.execute("SELECT posts.id, title, username, owner, votes FROM posts INNER JOIN users ON users.id=posts.owner")
    end

    # Gets info about a post
    #
    # @param [Integer] id The post id
    #
    # @return [Hash]
    #   * "owner" [Integer] The user id of the post creator
    #   * "username" [String] The username of the post creator
    #   * "title" [String] The title of the post
    #   * "content" [String] The content of the post
    #   * "votes" [Integer] The amount of votes the post has
    def get_post_info(id)
        db = SQLite3::Database.new(DB_PATH)
        db.results_as_hash = true

        db.execute("SELECT owner, username, title, content, votes FROM posts INNER JOIN users ON users.id=posts.owner WHERE posts.id=?", id)[0]
    end

    # Votes on a post
    #
    # @param [Integer] id The id of the post to vote on
    # @param [Boolean] voteup The boolean stating if it's an upvote (true) or a downvote (false)
    def vote(id, voteup)
        db = SQLite3::Database.new(DB_PATH)

        if voteup
            db.execute("UPDATE posts SET votes=votes+1 WHERE id=?", id)
        else
            db.execute("UPDATE posts SET votes=votes-1 WHERE id=?", id)
        end
    end

    # Deletes a post
    #
    # @param [Integer] id The id of the post to delete
    def delete(id)
        db = SQLite3::Database.new(DB_PATH)
        db.execute("DELETE FROM posts WHERE id=?", id)
    end

    # Creates a new comment
    #
    # @param [Integer] commenter The commenter's user id
    # @param [Integer] post The post where to comment
    # @param [String] content The comment content
    def new_comment(commenter, post, content)
        db = SQLite3::Database.new(DB_PATH)
        db.execute("INSERT INTO comments (owner, post, content) VALUES (?, ?, ?)", commenter, post, content)
    end

    # Gets info about all comments on a post
    #
    # @param [Integer] id The post id where the comment is
    #
    # @return [Array<Hash>]
    #   * "owner" [Integer] The user id of the comment creator
    #   * "username" [String] The username of the comment creator
    #   * "content" [String] The comment content
    def get_comments(id)
        db = SQLite3::Database.new(DB_PATH)
        db.results_as_hash = true

        db.execute("SELECT owner, username, content FROM comments INNER JOIN users ON users.id=comments.owner WHERE post=?", id)
    end
end