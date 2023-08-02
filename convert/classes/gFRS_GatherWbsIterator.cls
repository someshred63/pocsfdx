global class gFRS_GatherWbsIterator implements Iterator<String>, Iterable<String>{
	
	List<AggregateResult> duplicatedWbsCodes {get; set;}
	Integer i {get; set;} 
	
	public gFRS_GatherWbsIterator(){ 
       duplicatedWbsCodes = 
       [
       select 
		Name
		from GFRS_WBS_Codes__c
		GROUP BY Name
		HAVING count(Name)>1
       ]; 
       i = 0;
		System.debug('PN: Duplicated WBSes: ' + duplicatedWbsCodes.size());
	}
	
	global boolean hasNext(){ 
       if(i >= duplicatedWbsCodes.size()) 
           return false; 
       else 
           return true; 
   }    
   
	global String next(){ 
       return String.valueOf(duplicatedWbsCodes[i++].get('Name')); 
	}    
   
	global Iterator<String> iterator(){
		return this;
	}

}