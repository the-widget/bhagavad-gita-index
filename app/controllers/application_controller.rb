require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "password_security"
  end
######## HOMEPAGE ########
  get '/' do
    if is_logged_in
      erb :index
    else
      erb :homepage
    end
  end
######## SIGNUP ########
  get '/signup' do
    if is_logged_in
      redirect '/index'
    else
      erb :"/users/signup"
    end
  end

  post '/signup' do
    @user = User.create(username: params[:username], email: params[:email], password: params[:password])
    session[:user_id] = @user.id
    redirect '/'
  end
######## LOGIN/LOGOUT ########
  get '/login' do
    if is_logged_in
      redirect "/index"
    else
      erb :"/users/login"
    end
  end

  post '/login' do
    @user = User.find_by(:username => params["username"])
    if @user && @user.authenticate(params["password"])
      session[:user_id] = @user.id
      redirect "/"
    else
      erb :"users/login", locals: {message: "Invalid username or password! Please try again."}
    end
  end

  get '/logout' do
    if is_logged_in
      session.clear
      redirect '/'
    else
      redirect "/"
    end
  end

######## HELPER METHODS ########
  helpers do
    def is_logged_in
      !!session[:user_id]
    end

    def current_user
      User.find_by_id(session[:user_id])
    end
  end

end