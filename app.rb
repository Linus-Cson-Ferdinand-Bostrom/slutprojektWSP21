require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

get('/register') do
  slim(:register)
end

get('/') do
  slim(:login)
end

post('/login') do
  username = params[:username]
  password = params[:password]
  db = SQLite3::Database.new('db/todo2021.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM users WHERE username = ?",username).first
  pwdigest = result["pwdigest"]
  id = result["id"]
  
  if BCrypt::Password.new(pwdigest) == password
    session[:id] = id
    redirect('/todos')
  else
    "FEL LÖSENORD!"
  end
end

post('/todos/:id/delete') do
  id = params[:id].to_i
  db = SQLite3::Database.new('db/todo2021.db')
  db.execute("DELETE FROM todos WHERE id = ?",id)
  redirect("/todos")
end

post('/todos/:id/edit') do
  id = params[:id].to_i
  todo = params[:todo]
  db = SQLite3::Database.new('db/todo2021.db')
  db.results_as_hash = true
  result = db.execute("UPDATE todos SET content=? WHERE id=?",todo,id).first
  redirect('/todos')
end

post('/todos') do
  id = session[:id]
  todo = params[:todo]
  db = SQLite3::Database.new('db/todo2021.db')
  db.results_as_hash = true
  result = db.execute("INSERT INTO todos (content,user_id) VALUES (?,?)",todo,id).first
  redirect('/todos')
end

get('/todos') do
  id = session[:id].to_i
  db = SQLite3::Database.new('db/todo2021.db')
  db.results_as_hash = true
  result = db.execute("SELECT * FROM todos WHERE user_id = ?",id)
  p "Alla todos från result #{result}"
  slim(:"todos/index",locals:{todos:result})
end

post("/users/new") do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]

  if password == password_confirm
    password_digest = BCrypt::Password.create(password)
    db = SQLite3::Database.new('db/todo2021.db')
    db.execute("INSERT INTO users (username,pwdigest) VALUES (?,?)",username,password_digest)
    redirect('/')

  else
    "Passwords did not match!"
  end
end

