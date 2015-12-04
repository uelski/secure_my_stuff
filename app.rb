require 'bundler'
Bundler.require

ActiveRecord::Base.establish_connection(
  :database => "bee_crypt",
  :adapter => "postgresql"
)

enable :sessions

def does_user_exist(username)
  user = Account.find_by(:user_name => username)
  if user
    return true
  else
    return false
  end
end

def authorization_check
  if session[:current_user] == nil
    redirect '/not_authorized'
    return false
  else
    return true
  end
end

get '/' do
  # return {:hello => "world"}.to_json
  authorization_check
  @user_name = session[:current_user].user_name
  erb :index
end

get '/not_authorized' do
  erb :not_authorized
end

get '/register' do
  erb :register
end

post '/register' do
  p params

  if does_user_exist(params[:user_name]) == true
    return {:message => 'user exists'}.to_json
  end
  user = Account.create(user_email: params[:user_email], user_name: params[:user_name],
  password: params[:password])

  p user

  session[:current_user] = user

  redirect '/'
end

get '/login' do
  erb :login
end

post '/login' do
  authorization_check
  user = Account.authenticate(params[:user_name], params[:password])
    if user
      session[:current_user] = user
      redirect '/'
    else
      @message = "password or user name incorrect"
      erb :login
    end
end

get '/logout' do
  authorization_check
  session[:current_user] = nil
  redirect '/'
end
