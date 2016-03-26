require './config/environment'
require 'pry'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, 'app/views'
    enable :sessions
    set :session_secret, "password_security"
  end
######## HOMEPAGE ########
  get '/' do
    @topics = Topic.all.to_a
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

######## TOPICS ########

  get '/topics/new' do
    erb :"topics/new"
  end

  post '/topics' do
    @topic = Topic.new(name: params["name"])
    erb :topics, locals: {message: "Topic Created!"}
  end

  get '/topics' do
    @topics = Topic.all
    erb :"topics/index"
  end

  get '/topics/:slug/show' do
    @topic = Topic.find_by_slug(params[:slug])
    if @topic
      @verses = @topic.verses
      erb :"topics/show"
    else
      redirect '/'
    end
  end

  get '/topics/:slug/edit' do
    @topic = Topic.find_by_slug(params[:slug])
    if @topic
      @verses = Verse.all
      erb :"topics/edit"
    else
      redirect '/'
    end
  end

  patch '/topics/:slug' do 
    @topic = Topic.find_by_slug(params[:slug])
    @topic.update(name: params["topic"]["name"])
    @verse_ids = params["topic"]["verse_ids"]
    unless !@verse_ids
      @topic.verses.clear
      Verse.all.each do |verse|
        if @verse_ids.include?(verse.id.to_s)
          @topic.verses << verse
        end
      end
    end
    @topic.save
    redirect "/topics/#{@topic.slug}/show"
  end


######## VERSES ########

  get '/verses/new' do
    @topics = Topic.all
    erb :"verses/new"
  end
  
  post '/verse' do 
    @location = "#{params["verse"]["chapter"]}:#{params["verse"]["sloka"]}"
    @topic_ids = params["verse"]["topic_ids"]
    @verse = Verse.create(location: @location, content: params["verse"]["content"])
    unless !@topic_ids
      Topic.all.each do |topic|
        if @topic_ids.include?(topic.id.to_s)
          @verse.topics << topic unless @verse.topics.include?(topic)
        end
      end
    end
    if params["new_topic"].size != 0
      @verse.topics << Topic.create(name: params["new_topic"])
    end
    @verse.save
    redirect "verses/#{@verse.id}/show"
  end
  
  get '/verses' do
    @verses = Verse.all
    erb :"/verses/index"
  end
    
  get '/verses/:id/show' do
    @verse = Verse.find(params[:id])
    if @verse
      erb :'/verses/show'
    else
      redirect '/'
    end
  end

  get '/verses/:id/edit' do
    @verse = Verse.find(params[:id])
    if @verse
      @topics = Topic.all
      erb :'/verses/edit'
    else
      redirect '/'
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






#############NOTES#############
# post '/topic' do
#     # Do whatever you were doing
#     message = "Topic Created!"
#     redirect to '/index?message=#{message}'
#   end

#   get '/index'
#     @message = params[:message] if params[:message]
#     erb :index
#   end 









