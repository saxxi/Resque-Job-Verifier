require 'sinatra/base'
require 'resque'
require 'sitejobs'

module SiteJobs
  class App < Sinatra::Base
    get '/' do
      info = Resque.info
      out = "<html><head><title>Resque Demo</title></head><body>"
      out << "<p>"
      out << "There are #{info[:pending]} pending and "
      out << "#{info[:processed]} processed jobs across #{info[:queues]} queues."
      out << "</p>"
      out << '<form method="POST">'
      out << '<input type="submit" value="Create New Job"/>'
      out << '&nbsp;&nbsp;<a href="/resque/">View Resque</a>'
      out << '</form>'
      
      out << "<form action='/failing' method='POST''>"
      out << '<input type="submit" value="Create Failing New Job"/>'
      out << '&nbsp;&nbsp;<a href="/resque/">View Resque</a>'
      out << '</form>'
      
      redis = Resque.redis()
      
      out << "<br><br><br><br>"
      out << "<h1>Resque-Redis data</h1>"
      
      out << "<br><br>"+"<strong>Resque.info():</strong> " + Resque.info().to_json
      out << "<br><br>"+'<strong>Resque.queues():</strong> ' + Resque.queues().to_json
      out << "<br><br>"+'<strong>Queue size:</strong> ' + Resque.size('hotel_8').to_s
      out << "<br><br>"+'<strong>Peek queue from 2 to 5:</strong> ' + Resque.peek('hotel_8', 2, 5).to_json
      out << "<br><br>"+'<strong>Current queue (1..10000):</strong> ' + redis.LRANGE("resque:queue:hotel_8", 0, 10000).to_json
      out << "<br><br>"+'<strong>Resque.workers():</strong> ' + Resque.workers().to_json
      out << "<br><br>"+'<strong>Resque.working():</strong> ' + Resque.working().to_json
      
      req_jobs = ["247","72","809","423","4442","466","291","78","99934","409","991","154","866","518","570","727","643","836","92","33","577","315","994"]
      
      out << "<br><br>"+'<h3>JOBS for hotel_3:</h3> '
      out << "<br><br>"+'<strong>req_jobs:</strong> ' + req_jobs.to_json
      
      
      out << "<br><br>"+'<strong>ACTIVE JOBS:</strong> ' + Job.get_active(3).to_json
      out << "<br><br>"+'<strong>FAILED JOBS:</strong> ' + Job.get_failed(3).to_json
      
      out << "<br><br>"+'<strong>RES JOBS for hotel_3:</strong> ' + Job.get_stats(req_jobs, 3).to_json
      
      
      
      out << "</body></html>"
      out
    end
    
    post '/' do
      hotel_id = (rand * 5).round
      
      params[:job_id] = (rand * 1000).round
      params[:type] = 'image_upload'
      
      Job.enqueue(hotel_id, params)
      
      redirect '/'
    end
    
    get '/data' do
      # redis> keys *
      # "resque:stat:processed:sub01.localhost.com:1223:*"
      # "resque:workers"
      # "resque:stat:processed"
      # "resque:queues"
      # "resque:queue:hotel_8"                            <<-- ["{'class':'SiteJobs::Job','args':[{'queue_name':'hotel3331'}]}"]
      # "resque:worker:sub01.localhost.com:1223:*"            <<-- smembers "resque:workers" ## "sub01.localhost.com:1223:*"
      # "resque:worker:sub01.localhost.com:1223:*:started"
      
    end
    
    post '/failing' do 
      Resque.enqueue(FailingJob, params)
      redirect '/'
    end
    
    
    # ---------------------------------------------------------------------------------------
    
    def hr
      '--..--..--..--..--..--..--..--..--..--..--..--..--'
    end
    
  end
end
