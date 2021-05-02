require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

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

post('/login') do
  username = params[:username]
  password = params[:password]
  db = SQLite3::Database.new('db/slutprojektWSP21.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM users WHERE username = ?",username).first
  pwdigest = result["pwdigest"]
  id = result["id"]
  
  if BCrypt::Password.new(pwdigest) == password
    session[:id] = id
    redirect('/lists')
  else
    "Wrong password!"
  end
end

post("/users/new") do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]
  if username != "" && password != "" && password_confirm != ""
    if password == password_confirm
      password_digest = BCrypt::Password.create(password)
      db = SQLite3::Database.new('db/slutprojektWSP21.db')
      db.execute("INSERT INTO users (username,pwdigest) VALUES (?,?)",username,password_digest)
      redirect('/lists')

    else
      "Passwords did not match!"
    end
  else
    "Please fill all the boxes."
  end
end

get('/lists') do
  id = session[:id].to_i
  db = SQLite3::Database.new('db/slutprojektWSP21.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM lists WHERE user_id = ?",id)
  slim(:"lists",locals:{lists:result})
end

post('/lists') do
  id = session[:id].to_i
  list = params[:list]
  db = SQLite3::Database.new('db/slutprojektWSP21.db')
  db.results_as_hash = true
  result = db.execute("INSERT INTO lists (name,user_id) VALUES (?,?)",list,id).first
  redirect('/lists')
end

post('/lists/:id/edit') do
  id = params[:id].to_i
  list = params[:list]
  db = SQLite3::Database.new('db/slutprojektWSP21.db')
  db.results_as_hash = true
  result = db.execute("UPDATE lists SET content=? WHERE id=?",list,id).first
  redirect('/lists')
end

post('/lists/:id/delete') do
  id = params[:id].to_i
  db = SQLite3::Database.new('db/slutprojektWSP21.db')
  db.execute("DELETE FROM lists WHERE id = ?",id)
  redirect("/lists")
end