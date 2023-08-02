public with sharing class GNE_SFA2_CONFIG_CONSOLE_CONTROLLER {
	
	public String configuration {get; set;}
	public String brand {get; set;}
	public String role {get; set;}
	public String application {get; set;}
	public String objectType {get; set;}
	public String objectRecordType {get; set;}
	public ApexPages.StandardSetController lc {get; set;}
	public Integer currentPage;
	public Integer totalRecords;
	public Integer totalPages;
	
	public GNE_SFA2_CONFIG_CONSOLE_CONTROLLER()
	{
		getConfigurationObjects();
		lc.setPageSize(50);
	}
	
	public Integer gettotalPages()
	{
		Decimal dtotalPages;
		dtotalPages = (lc.getResultSize() / lc.getPageSize());
        dtotalPages = Math.floor(dtotalPages) + ((Math.mod(lc.getResultSize(), 50)>0) ? 1 : 0);
        totalPages = Integer.valueOf(dtotalPages);
        return totalPages;
	}
	
	public Integer getcurrentPage()
	{
		return lc.getPageNumber();
	}
	
	public Integer gettotalRecords()
	{
		return lc.getResultSize();
	}
	
	

	
	public List<SFA2_Configuration_Object_gne__c> getListItems()
	{
		return (List<SFA2_Configuration_Object_gne__c>) lc.getRecords();
	}
	
	
	public void getConfigurationObjects()
	{
		String query = 'Select Id,Is_Active_gne__c,Order_gne__c,Section_Header_gne__c,Is_Default_Record_Type_gne__c,RT_Available_On_Create_gne__c,Name,Application_Type__c,Brand_gne__c,Configuration_Type_gne__c,Object_Name_gne__c,Record_Type_gne__c,Role_gne__c from SFA2_Configuration_Object_gne__c';
		boolean moreFilters = false;
		
		if(configuration == '' || configuration == 'null' ||configuration == NULL   ) configuration = '';
		if(brand == '' || brand == 'null' ||brand == NULL   ) brand = '';
		if(role == '' || role == 'null' ||role == NULL   ) role = '';
		if(application == '' || application == 'null' ||application == NULL   ) application = '';
		if(objectType == '' || objectType == 'null' ||objectType == NULL   ) objectType = '';
		if(objectRecordType == '' || objectRecordType == 'null' ||objectRecordType == NULL   ) objectRecordType = '';
		
		if(configuration != '' || brand != '' || role != '' || application != '' || objectType != '' || objectRecordType != '' )
		{
			query+=' WHERE ';
		}
		
		if(configuration != '')
		{
			query+= 'Configuration_Type_gne__c = \''+configuration+'\' ';
			if(!moreFilters)
				moreFilters = true;
		}
		
		if(brand != '')
		{
			if(moreFilters)
			query+= ' and ';
			query+= 'Brand_gne__c = \''+brand+'\' ';
			if(!moreFilters)
				moreFilters = true;
		}
		
		if(role != '')
		{
			if(moreFilters)
			query+= ' and ';
			query+= 'Role_gne__c = \''+role+'\' ';
			if(!moreFilters)
				moreFilters = true;
		}
		
		if(application != '')
		{
			if(moreFilters)
			query+= ' and ';
			query+= 'Application_Type__c = \''+application+'\' ';
			if(!moreFilters)
				moreFilters = true;
		}
		
		if(objectType != '')
		{
			if(moreFilters)
			query+= ' and ';
			query+= 'Object_Name_gne__c = \''+objectType+'\' ';
			if(!moreFilters)
				moreFilters = true;
		}
		
		if(objectRecordType != '')
		{
			if(moreFilters)
			query+= ' and ';
			query+= 'Record_Type_gne__c = \''+objectRecordType+'\' ';
			if(!moreFilters)
				moreFilters = true;
		}
		
		query+= ' ORDER BY Application_Type__c,Brand_gne__c,Role_gne__c,Configuration_Type_gne__c,Object_Name_gne__c,Record_Type_gne__c,Order_gne__c ASC LIMIT 7500';
		System.debug('********* NEW QUERY : '+query);
		lc = new ApexPages.StandardSetController( Database.query(query));
		lc.setPageSize(50);
	}
	
	
	public List<SelectOption> getObjectNames()
   	{
    	List<SelectOption> options = new List<SelectOption>();
    	options.add(new SelectOption('' ,' -- None --'));
 	    for(AggregateResult s  : [select Object_Name_gne__c from SFA2_Configuration_Object_gne__c where Object_Name_gne__c <> null group by Object_Name_gne__c] )
     	{
       		 String lobjectName = s.get('Object_Name_gne__c')+'';
       		 //String objectDisplayName =Schema.getGlobalDescribe().get(lobjectName).getDescribe().getName();
       		 options.add(new SelectOption(lobjectName,lobjectName));
     	}
     	
     	return options;
    }
 
	public List<SelectOption> getRTNames()
   	{
    	List<SelectOption> options = new List<SelectOption>();
    	options.add(new SelectOption('',' -- None --'));
    	if(objectType != NULL && objectType != 'null' && objectType != '')
    	{
   			for(RecordType rt: [select id,DeveloperName,Name from recordtype where sobjecttype=:objectType order by name]) {
			      options.add(new SelectOption(rt.DeveloperName,rt.Name));
			  }
    	}
		
     	return options;
    }
	
	public void Filter()
	{
		getConfigurationObjects();
	}

}