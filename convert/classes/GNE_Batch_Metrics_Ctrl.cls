public with sharing class GNE_Batch_Metrics_Ctrl {
	
	@ReadOnly @RemoteAction
	public static List<List<Object>> getAVGJobsMetrics() {
		return getJobsMetrics('AVG Number of Apex Jobs per Hour (GMT)', [
			SELECT CreatedDate, CompletedDate, ApexClass.Name, TotalJobItems, Status 
			FROM AsyncApexJob
			WHERE JobType = 'BatchApex'
				AND Status = 'Completed'
			ORDER BY CreatedDate, CompletedDate
			LIMIT 2000
		], null);
	}
	
	@ReadOnly @RemoteAction
	public static List<List<Object>> getLast24JobsMetrics() {
		DateTime minDate = System.now().addDays(-1);
		minDate = DateTime.newInstanceGmt(minDate.yearGmt(), minDate.monthGmt(), minDate.dayGmt(), minDate.hourGmt()+1, 0, 0);
		
		return getJobsMetrics('Last 24 Hours',[
			SELECT CreatedDate, CompletedDate, ApexClass.Name, TotalJobItems, Status 
			FROM AsyncApexJob
			WHERE JobType = 'BatchApex'
				AND Status = 'Completed'
				AND CreatedDate >= :minDate
			ORDER BY CreatedDate, CompletedDate
			LIMIT 2000
		],minDate);
	}
	
	private static List<List<Object>> getJobsMetrics(String chartTitle, List<AsyncApexJob> jobs, DateTime minHour) {
		
		List<List<Object>> result = new List<List<Object>>();
		
		Map<Integer,Integer> numberOfJobs = new Map<Integer,Integer>();
		Map<Integer,Map<String,Integer>> namesOfJobs = new Map<Integer,Map<String,Integer>>();
		Integer step = 20;
		Integer minSecs = minHour!=null ? (minHour.hourGmt()*3600 + minHour.minuteGmt()*60 + minHour.secondGmt()) : 0;
		minSecs = minSecs - Math.mod(minSecs,step);
		Long minDay = minHour!=null ? minHour.getTime()/(1000*60*60*24) : null;
		
		for(Integer i = 0; i<24*3600; i+=step) {
			numberOfJobs.put(i,0);
			namesOfJobs.put(i,new Map<String,Integer>());
		}
				
		Integer numberOfDays = null;
		
		if(!jobs.isEmpty()) {
			Long milisDiff = jobs[jobs.size()-1].CompletedDate.getTime() - jobs[0].CreatedDate.getTime();
			numberOfDays = (Integer)milisDiff/(1000*60*60*24)+1;
		}
		for(AsyncApexJob job : jobs) {
			String jobName = job.ApexClass.Name;
			DateTime startTime = job.CreatedDate;
			DateTime endTime = job.CompletedDate;
			
			
			Integer startSecs = startTime.hourGmt()*3600 + startTime.minuteGmt()*60 + startTime.secondGmt();
			startSecs = startSecs - Math.mod(startSecs,step);
			Integer endSesc = endTime.hourGmt()*3600 + endTime.minuteGmt()*60 + endTime.secondGmt();
			endSesc = endSesc - Math.mod(endSesc,step);
			
			if(minHour!=null) {
				Long startDay = startTime.getTime()/(1000*60*60*24);	
				Long endDay = endTime.getTime()/(1000*60*60*24);
				startSecs += ((Integer)(startDay-minDay)*24*3600)-minSecs;
				endSesc += ((Integer)(endDay-minDay)*24*3600)-minSecs;
			}
			
			if(startSecs<=endSesc) {
				for(Integer i = startSecs; i<=endSesc; i+=step) {
					numberOfJobs.put(i,numberOfJobs.get(i)+1);
					Map<String,Integer> numbersPerJobNames = namesOfJobs.get(i);
					
					if(!numbersPerJobNames.containsKey(jobName)) {
						numbersPerJobNames.put(jobName,1);
					} else {
						numbersPerJobNames.put(jobName,numbersPerJobNames.get(jobName)+1);
					} 
				}
			} else {
				for(Integer i = startSecs; i<24*3600; i+=step) {
					numberOfJobs.put(i,numberOfJobs.get(i)+1);
					Map<String,Integer> numbersPerJobNames = namesOfJobs.get(i);
					
					if(!numbersPerJobNames.containsKey(jobName)) {
						numbersPerJobNames.put(jobName,1);
					} else {
						numbersPerJobNames.put(jobName,numbersPerJobNames.get(jobName)+1);
					}	
				}
				
				for(Integer i = 0; i<=endSesc; i+=step) {
					numberOfJobs.put(i,numberOfJobs.get(i)+1);
					Map<String,Integer> numbersPerJobNames = namesOfJobs.get(i);
					
					if(!numbersPerJobNames.containsKey(jobName)) {
						numbersPerJobNames.put(jobName,1);
					} else {
						numbersPerJobNames.put(jobName,numbersPerJobNames.get(jobName)+1);
					}	
				}
			}
		}
		
		List<Integer> orderedKeys = new List<Integer>(numberOfJobs.keySet());
		orderedKeys.sort();
		
		result.add(new List<Object>{'Hour', 'Number of Jobs',chartTitle,0});
		
		Double maxAvgValue=0.0;
		 
		for(Integer sec : orderedKeys) {
			Double avgNumberOfJobs = (Double)numberOfJobs.get(sec)/numberOfDays;
			
			if(maxAvgValue<avgNumberOfJobs) {
				maxAvgValue = avgNumberOfJobs;
			}
			
			Double dHour = ((Double)sec)/3600.0;
			
			Integer finalSec = sec;
			
			if(minHour!=null) {
				dHour -= 24.0;
				finalSec += minSecs;
			}
			
			Integer iHour = finalSec/3600;
			Integer iMinute = (finalSec - iHour*3600)/60;
			Integer iSec = finalSec - iHour*3600 - iMinute*60;
			iHour = Math.mod(iHour,24);
			
			String tooltip = ((iHour<10) ? '0' : '') + iHour + ':' + (iMinute<10 ? '0' : '') + iMinute + ':' + (iSec<10 ? '0' : '') + iSec + ' - ' + avgNumberOfJobs;
			
			if(!namesOfJobs.get(sec).isEmpty()) {
				
				for(String jobName : namesOfJobs.get(sec).keySet()) {
					tooltip += '\n' + jobName + ' - ' + (Double)namesOfJobs.get(sec).get(jobName)/numberOfDays;
				}
			}
			
			result.add(new List<Object>{dHour, avgNumberOfJobs, tooltip});
			
		}
		
		result[0][3] = maxAvgValue;
		
		return result;		
	}
}