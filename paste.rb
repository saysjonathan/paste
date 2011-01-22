#!/usr/bin/ruby -rubygems

require 'sinatra/base'
require 'sinatra/pygments'
require 'sinatra/redis'

class Paste < Sinatra::Base
  helpers Sinatra::Pygments
  register Sinatra::Redis
  set :redis, 'redis://127.0.0.1:6379/1'

  #new
  get '/' do
    haml :new
  end

  #create
  post '/' do
    html = pygmentize params[:snippet_body], params[:snippet_lexer]
    id = redis.dbsize
    redis.hmset id,'title',params[:snippet_title],'html',html,'time',Time.now.strftime("%d/%m/%Y %H:%M:%S")
    redis.save
    redirect "/#{id}"
  end

  #show
  get '/:id' do
    snip = redis.hmget params[:id],'title','html','time'
    @title = snip[0]
    @html = snip[1]
    @time = snip[2]
    haml :show
  end
end
