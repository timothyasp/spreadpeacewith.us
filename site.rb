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
  property :profileImgPath, String, :required => true 
  property :sales, Integer, :required => true

end

DataMapper.finalize.auto_upgrade!  

SITE_TITLE = "Spread Peace With Us -- A BBFWP Movement"
SITE_HEADER = "Spread Peace With Us"

before do 
  @counter = Person.all.sum(:sales)*4
  @sidebarProfiles = Person.all(:order => :id.asc)
  
  max_length = 50;

  @sidebarProfiles.each do |profile|
    @sidebarProfiles.map { |profile|
      profile.description = profile.description.to_s[0..max_length] # I am calling #to_s because the question didn't specify if project.name is a String or not
	   profile.description << "..." if profile.description.to_s.length > max_length # add an ellipsis if we truncated the name
    }
  end
end

get '/' do  
  @counter = Person.all.sum(:sales)*4
  @profiles = Person.all(:order => :id.asc)

  erb :index
end

get '/team' do
  @profiles = Person.all :order => :id.asc
  erb :team
end

get '/join' do
  erb :team
end

get '/beerbongs' do
  Person.all.sum(:sales)*4
end

get '/admin' do
  erb :admin
end

get '/admin/add' do
  erb :add
end

post '/admin/add' do
 # File.open('uploads/' + params['profileImage'][:filename], "w") do |f|
 #	 f.write(params['profileImage'][:tempfile].read)

 # end

  print params
  p = Person.new
  p.name = params[:name]
  p.email = params[:email]
  p.description = params[:description]
  p.profileImgPath = params[:profileImage]
  p.sales = params[:beerbongs]
  p.save
    
  redirect '/'
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
  p.sales = params[:beerbongs].to_i
  p.save
  
  redirect '/admin/edit'
end

get '/admin/sales' do
  @profiles = Person.all :order => :name.asc
  erb :beerbongSales
end

put '/admin/sales' do 
  Person.all.each do |p| 
    inputField = ":beerbongs"+p.id.to_s   
	 print inputField
    p.sales = params[inputField].to_i
  end

  redirect :admin
end
