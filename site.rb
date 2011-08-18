require 'sinatra'
require 'haml'
require 'datamapper'

enable :sessions

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/site.db")

class Site
  include DataMapper::Resource
  
  property :page, String, :key => true
  
  has n, :elements
end

class Element
  include DataMapper::Resource
  
  property :id, Serial
  property :text, Text
  
  belongs_to :site
end

class Person
  include DataMapper::Resource
  
  property :id, Serial
  property :name, String, :required => true
  property :email, String, :required => true
  property :description, Text, :required => true
  property :profileImgPath, String #path to profile image in /public/media/*

  has 1, :beerbong
  
  def self.upload(file, name)
    File.open('uploads/' + file, "w") do |f|
      f.write(file.read)
      f.path
    end
  end
end

class Beerbong 
  include DataMapper::Resource
  
  property :id, Serial
  property :sales, Integer, :default => 0
  property :childrenFed, Integer, :default => 0

  belongs_to :person
end

DataMapper.finalize.auto_upgrade!  

SITE_TITLE = "Spread Peace With Us -- A BBFWP Movement"
SITE_HEADER = "Spread Peace With Us"

get '/' do  
  @counter = Beerbong.all.sum(:childrenFed)
  @profiles = Person.all(:order => :id.asc)

  erb :index
end

get '/team' do
  @counter = Beerbong.all.sum(:childrenFed)
  @profiles = Person.all.sort_by { |person| -person.beerbong.sales }
  
  erb :team
end

get '/beerbongs' do
  Beerbong.all.sum(:sales)
end

get '/admin' do
  erb :admin
end

get '/admin/add' do
  erb :add
end

post '/admin/add' do
  p = Person.create(:name => params[:name], :email => params[:email], :description => params[:description], :profileImgPath => Person.upload(params[:profileImage], 'profileImage')) 
  p.beerbong = Beerbong.new(:sales => params[:beerbongs], :childrenFed => params[:beerbongs].to_i*4)
  p.save
    
  erb '/'
end

get '/admin/edit' do
  @profiles = Person.all :order => :id.asc
  erb :edit
end

get '/admin/editItem/:id' do
  @profile = Person.get params[:id]
  
  erb :editItem
end

put '/admin/editItem/:id' do
  p = Person.get params[:id]
  p.name = params[:name] 
  p.email = params[:email]
  p.description = params[:description]
  p.save
  
  erb '/admin/edit'
end

get '/admin/editPage/about' do
  
end

put '/admin/editPage/:page' do
  
end

get '/admin/counter' do
  
end

post '/admin/counter/:id' do
  
end

get '/admin/sales' do
  
end
