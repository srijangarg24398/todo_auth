require 'sinatra'
require 'data_mapper'
DataMapper.setup(:default,'sqlite:///'+Dir.pwd+'/project.db')

class Todo
    include DataMapper::Resource
 
    property :id,         Serial    
    property :task,       String   
    property :done,       Boolean
    property :user_id,    Numeric
end
class User
    include DataMapper::Resource
 
    property :id,         Serial    
    property :email,      String   
    property :password,   String
end
DataMapper.finalize
DataMapper.auto_upgrade!
enable :sessions

get '/' do 
	if session[:user_id].nil?
		return redirect '/signin'
	end
	tasks=Todo.all(user_id:session[:user_id])
	erb :index,locals: {tasks:tasks,user_id:session[:user_id]}
end
get '/signin' do 
	erb :signin,locals: {user_id:session[:user_id]}
end
get '/pass' do 
	user=User.get(id:session[:user_id])
	erb :pass,locals:{user_id:session[:user_id]}
end

get '/signup' do 
	erb :signup
end
get '/signout' do 
	session[:user_id]=nil
	return redirect '/'
end
post '/signin' do 
	yoemail=params["input_email"]
	user=User.all(email: yoemail).first
	if user.nil?
		return redirect 'signup'
	else
		session[:user_id]=user.id
		return redirect '/pass'
	end
end
post '/signup' do 
	yoemail=params["input_email"]
	yopassword=params["input_password"]
	user=User.all(email:yoemail).first
	if user
		return redirect '/signup'
	else
		user=User.new
		user.email=yoemail
		user.password=yopassword
		user.save
		session[:user_id]=user.id
		return redirect '/'
	end
end
post '/pass' do
	yoid=params["user_id"]
	yopassword=params["input_password"]
	user=User.get(id:yoid)
	session[:user_id]=yoid
	user = User.get(yoid)
		if user.password == yopassword
			session[:user_id] = user.id
			return redirect '/'
		else
			return redirect '/pass'
		end
	return redirect '/'
end
post '/add' do 
	todo=Todo.new
	todo.task= params["input_task"]
	todo.done=false
	todo.user_id=session[:user_id]
	todo.save
	return redirect '/'
end
post '/done' do 
	task=Todo.get(params["done_id"].to_i)
	task.done!=task.done
	task.save
	return redirect '/'
end
