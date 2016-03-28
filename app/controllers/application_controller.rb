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
    @message = params[:message] if params[:message]
    @user = current_user if current_user
    @topics = Topic.all.to_a
    if !!@user && is_logged_in
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
      redirect "/"
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
    if !is_logged_in
      message = "* You Must Be Logged In To Contribute*"
      redirect "/?message=#{message}"
    end
    erb :"topics/new"
  end

  post '/topics' do
    @topic = Topic.new(name: params["name"].capitalize)
    if !!Topic.find_by(name: @topic.name)
      message = "* Topic Already Exists. *"
      redirect "/topics/#{@topic.slug}/show?message=#{message}"
    else
      @topic.users << current_user
      @topic.save
      message = "* Created New Topic! Click 'Edit Topic' to Associate Existing Verses. Or, 'Add A New Verse' to the Associated Topic. *"
      redirect "/topics/#{@topic.slug}/show?message=#{message}"
    end
  end

  get '/topics' do
    @message = params[:message] if params[:message]
    @topics = Topic.all.to_a
    @topics.sort!{ |a,b| a.name <=> b.name }
    erb :"topics/index"
  end

  get '/topics/:slug/add_verse' do
    @message = params[:message] if params[:message]
    @topic = Topic.find_by_slug(params[:slug])
    if not_allowed_topics || !@topic
      message = "* You do not have permission to edit this topic. *"
      redirect "/topics/#{params[:slug]}/show?message=#{message}"
    else
      erb :"topics/add_verse"
    end
  end

  post '/topics/:slug/add_verse' do
    @topic = Topic.find_by_slug(params[:slug])
    @verse = Verse.new(location: "#{params["verse"]["chapter"]}.#{params["verse"]["sloka"]}", content: params["verse"]["content"])
    if !!Verse.find_by(location: @verse.location)
      message = "* That Verse Already Exists! *"
      redirect "/topics/#{@topic.slug}/add_verse?message=#{message}"
    else
      @topic.verses << @verse
      message = "* Successfully Added Verse to Topic *"
      redirect "topics/#{@topic.slug}/show?message=#{message}"
    end
  end

  get '/topics/:slug/show' do
    @message = params[:message] if params[:message]
    @topic = Topic.find_by_slug(params[:slug])
    if @topic
      @verses = @topic.verses.to_a.sort!{|a,b| a.location.to_f <=> b.location.to_f}
      erb :"topics/show"
    else
      redirect '/'
    end
  end

  get '/topics/:slug/edit' do
    @topic = Topic.find_by_slug(params[:slug])
    if not_allowed_topics
      message = "* You do not have permission to edit this topic. *"
      redirect "/topics/#{params[:slug]}/show?message=#{message}"
    elsif @topic
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

  delete '/topics/:slug' do
    @topic = Topic.find_by_slug(params[:slug])
    message = "* '#{@topic.name}' successfully deleted *"
    @topic.delete
    redirect "/topics?message=#{message}"
  end

  post '/topic/:slug/authorization' do
    @topic = Topic.find_by_slug(params[:slug])
    unless @topic.users.include?(current_user)
      @topic.users << current_user
      message = "* Congratulations! You May Now Contribute To This Topic. *"
    else
      message = "* You Already Authorized To Edit This Topic. *"
    end
    redirect "/topics/#{@topic.slug}/show?message=#{message}"
  end




######## VERSES ########

  get '/verses/new' do
    @message = params[:message] if params[:message]
    if !current_user || !is_logged_in
      message = "* You Must Be Logged In To Contribute*"
      redirect "/?message=#{message}"
    else
      @topics = Topic.all
      erb :"verses/new"
    end
  end
  
  post '/verse' do 
    @verse = Verse.new(location: "#{params["verse"]["chapter"]}.#{params["verse"]["sloka"]}", content: params["verse"]["content"])
    @topic_ids = params["verse"]["topic_ids"]
    if !!Verse.find_by(location: @verse.location)
      message = "* That Verse Already Exists! *"
      redirect "/verses/new?message=#{message}"
    elsif @topic_ids
      Topic.all.each do |topic|
        if @topic_ids.include?(topic.id.to_s)
          @verse.topics << topic unless !topic.users.include?(current_user)
        end
      end
    end
    if params["new_topic"].size != 0
      @verse.topics << Topic.create(name: params["new_topic"].capitalize)
      Topic.last.users << current_user
    end
    @verse.save
    redirect "verses/#{@verse.id}/show"
  end

  patch '/verse/:id' do
    @verse = Verse.find_by_id(params[:id])
    @verse.update(location: "#{params["verse"]["chapter"]}.#{params["verse"]["sloka"]}", content: params["verse"]["content"])
    @verse.topics.clear
    Topic.all.each do |topic|
      if params["verse"]["topic_ids"].include?(topic.id.to_s)
        @verse.topics << topic unless !topic.users.include?(current_user)
      end
    end
    if params["new_topic"].size != 0
      @verse.topics << Topic.create(name: params["new_topic"].capitalize)
      Topic.last.users << current_user
    end
    @verse.save
    redirect "verses/#{@verse.id}/show"
  end

  delete '/verse/:id' do
    @verse = Verse.find_by_id(params[:id])
    message = "* Successfully deleted verse #{@verse.location} *"
    @verse.delete
    redirect "/verses?message=#{message}"
  end

  
  get '/verses' do
    @message = params[:message] if params[:message]
    @verses = Verse.all.to_a
    @verses.sort!{|a,b| a.location.to_i <=> b.location.to_i}
    erb :"/verses/index"
  end
    
  get '/verses/:id/show' do
    @verse = Verse.find(params[:id])
    @message = params[:message] if params[:message]
    if @verse
      erb :'/verses/show'
    else
      redirect '/'
    end
  end

  get '/verses/:id/edit' do
    @verse = Verse.find(params[:id])
    if !current_user || !is_logged_in
      message = "-You do not have permission to edit this topic.-"
      redirect "/verses/#{params[:id]}/show?message=#{message}"
    elsif @verse
      @topics = Topic.all
      erb :'/verses/edit'
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

    def not_allowed_topics
      !current_user || !is_logged_in || !@topic.users.include?(current_user)
    end

  end


end

