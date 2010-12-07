require 'resque'

module SiteJobs
  module Job
    
    def self.enqueue(hotel_id, resource)
      Resque::Job.create(select_queue(hotel_id), Job, resource)
    end
    
    def self.select_queue(hotel_id)
      'hotel_' + hotel_id.to_s
    end
    
    def self.get_active(hotel_id)
      # find jobs where jobs_id = 504 (number not followed by another number)
      # \\"hotel_id\\":504(?!\d)
      #[444 => 'done']
      redis = Resque::Job.redis()
      
      jobs = []
      redis.sort("resque:queue:hotel_"+hotel_id.to_s).each do |job|
        # we'll get hotel_id through regex 'cause is faster than to_json method
        tmpstr = job.match(/"job_id":\d+(?!\d)/)[0]
        job_id = tmpstr[9..-1]
        jobs << job_id
      end
      
      jobs
    end

    def self.get_failed(hotel_id)
      # todo: WARNING we're running through ALL failed, not just hotel_id !!!
      redis = Resque::Job.redis()
      
      jobs = []
      redis.sort("resque:failed").each do |job|
        if !job.match(/"queue":"hotel_#{hotel_id}"/).nil?
          tmpstr = job.match(/"job_id":\d+(?!\d)/)[0]
          job_id = tmpstr[9..-1]
          jobs << job_id
        end
      end
      
      jobs
    end
    
    def self.get_stats(reqjobs, hotel_id)
      
      active = self.get_active(hotel_id)
      failed = self.get_failed(hotel_id)
      
      jobs = {}
      reqjobs.each do |reqjob|
        
        if active.include?(reqjob)
          jobs[reqjob] = 'active'
        elsif failed.include?(reqjob)
          jobs[reqjob] = 'failed'
        else
          jobs[reqjob] = 'inactive'
        end
        
      end
      
      jobs
    end

    def self.perform(resource)
      sleep 30
      
      if (rand * 1000).round < 500
        raise 'not processable!'
        puts ":::: FAILED ::::"
        return
      end
      
      puts "Processed a job!"
      
    end
    
  end
  
  module FailingJob
    @queue = :failing

    def self.perform(params)
      sleep 300
      raise 'not processable!'
      puts "Processed a job!"
    end
  end
end
