Resque Job verifier for polling requests
-----------

Please note these file are heavily inspired by Defunkt's Resque demo files.

This buildup returns a list of active, inactive and failed jobs based on a particular given set.


### Testing

	rackup config.ru  (site will be available by default at: http://127.0.0.1:9292/)
	rake resque:work QUEUE=*

##How it works

Create a new job

	hotel_id = (rand * 5).round # id of used db (will be stored in hotel_[hotel_id])
	
	params = various_job_params
	params[:job_id] = (rand * 1000).round # only param required
	params[:type] = 'image_upload'
	
	Job.enqueue(hotel_id, params)
	
These two are pretty straightforward.
They return all job tasks for a specific hotel_id:
	
	Job.get_active(3).to_json # ["11", "33", ... ]
	Job.get_failed(3).to_json # ["22", "44", ... ]

This one will be useful for a js poller.
Basically it's a join of previous methods and returns also inactive.

	req_jobs = ["11","33","44","884", ...]
	Job.get_stats(req_jobs, 3).to_json
	
	# {"884":"inactive","33":"active","44":"failed","11":"active", ... }


### Other info

Querying could be improved, especially while retrieving failed jobs.
Would be nice to add manually to db list of successful jobs.




