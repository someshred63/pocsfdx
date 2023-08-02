global without sharing class SAPToSFDCHandler
{
	
	/*##################################################
    #Project Name           : Genentec - Primary Care
    # File                  : SAPToSFDCHandler.cls
    # Version               : 1.0 
    # Created by            : <<Sandeep Kumar>> 
    # Created Date          : <<19th May 10>> 
    # Last Modified by      : <<Sandeep Kumar>> 
    # Last Modified Date    : <<19th May 10>>  
    # Description           : <<This is the controller class for SFDC Interface to ESB to update USER_SAP_IDs_gne__c table in SFDC
    #						: The insertSapId() method upserts a unique key combination of unix id and SapId and updates status to true.
    #						: The removeSapId() method changes the status to false for a unique key combination of unix id and SapId >>
    ####################################################*/
	
	static final String ERROR_INVALID_UNIX_ID        = 'Invalid Unix Id';
	static final String ERROR_INVALID_SAP_ID         = 'Invalid SAP Id';
	
	// response objext
    global class Response {
        WebService DateTime StartTime = DateTime.now();
        WebService DateTime EndTime   = null;
        WebService String ErrorCode;
        WebService String ErrorMessage;
        WebService List<RequestIdResponseIdMap> RequestIdResponseIdList;
    }

    global class RequestIdResponseIdMap {
       WebService String RequestId;
       WebService String ResponseId;    
       WebService String ObjectType;
    }
    
    
    //upserts a unique key combination of unix id and SapId and updates status to true
    WebService static Response insertSapId(String unixId, String sapId )
    {
     	Response callResponse = new Response();        
     	SavePoint savePoint = Database.setSavePoint(); 
     	
     	USER_SAP_IDs_gne__c objUserSapId;
		//objUserSapId = [Select Id, Name, UNIX_ID_gne__c, SAP_ID_gne__c, Comments__c from USER_SAP_IDs_gne__c where UNIX_ID_gne__c = :unixId ];
		
		if(unixId == null || unixId.trim().equals('') )
		{
			callResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
            Database.rollback ( savePoint ); 
            callResponse.ErrorMessage  = ERROR_INVALID_UNIX_ID; 
            
            callResponse.EndTime = DateTime.now();
            return callResponse;
		}
		else if(SapId == null || SapId.trim().equals(''))
		{
			callResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
            Database.rollback ( savePoint ); 
            callResponse.ErrorMessage  = ERROR_INVALID_SAP_ID; 
            
            callResponse.EndTime = DateTime.now();
            return callResponse;
		}

		try{
			
			String uniqueKey = unixId.trim() + '-' + SapId.trim();
			try{
				objUserSapId = [Select Id, UNIX_ID_gne__c, SAP_ID_gne__c, Status_gne__c, Unique_Key_Calc_gne__c, Unique_Key_gne__c from USER_SAP_IDs_gne__c where Unique_Key_gne__c = :uniqueKey limit 1 ];
			}
			catch(Exception ex){
				//do nothing
			}
			
			if(objUserSapId==null)
			{
				objUserSapId = new USER_SAP_IDs_gne__c();
			}
			objUserSapId.UNIX_ID_gne__c = unixId.trim();
			objUserSapId.SAP_ID_gne__c  = SapId.trim();
			objUserSapId.Status_gne__c = true;
			
			//this ensures that even if the trigger is inactive the unique key external id field will alway be updated by this API
			if(objUserSapId.Id==null) 
			{
				objUserSapId.Unique_Key_gne__c = uniqueKey ;
			}

	     	//Schema.SObjectField f = USER_SAP_IDs_gne__c.Fields.UNIX_ID_gne__c;
			Database.UpsertResult upsertResult = Database.Upsert (objUserSapId, USER_SAP_IDs_gne__c.Unique_Key_gne__c);   
	        Id id                          = upsertResult.getId();
	        if ( id == null ) {             
	            callResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
	            Database.rollback ( savePoint ); 
	            Database.Error dbError           = upsertResult.getErrors()[0];
	            callResponse.ErrorMessage  = dbError.getStatusCode().Name() + ' : '  + 
	                                               dbError.getMessage() ; 
	            
	            callResponse.EndTime = DateTime.now();
	            return callResponse;                
	        }
	        
	        //Request Id to Response Id Map
	        callResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
	        RequestIdResponseIdMap requestIdResponseIdItem = new RequestIdResponseIdMap(); 
	        requestIdResponseIdItem.RequestId  = unixId;
	        requestIdResponseIdItem.ResponseId = id;
	        requestIdResponseIdItem.ObjectType = 'USER_SAP_IDs_gne__c';
	        callResponse.RequestIdResponseIdList.add ( requestIdResponseIdItem ); 
		}
		catch(Exception ex)
		{
			callResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
            Database.rollback ( savePoint ); 
            callResponse.ErrorMessage  = ex.getMessage(); 
            
            callResponse.EndTime = DateTime.now();
            return callResponse;
		}
        
        callResponse.EndTime = DateTime.now();
        return callResponse;
        
    }
	
	//updates the status(status_gne__c) to false for a unique key combination of unix id and SapId >
	WebService static Response removeSapId(String unixId, String SapId)
    {
     	Response callResponse = new Response();        
     	SavePoint savePoint = Database.setSavePoint(); 

     	USER_SAP_IDs_gne__c objUserSapId;
     	
     	if(unixId == null || unixId.trim().equals('') )
		{
			callResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
            Database.rollback ( savePoint ); 
            callResponse.ErrorMessage  = ERROR_INVALID_UNIX_ID; 
            
            callResponse.EndTime = DateTime.now();
            return callResponse;
		}
		else if(SapId == null || SapId.trim().equals(''))
		{
			callResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
            Database.rollback ( savePoint ); 
            callResponse.ErrorMessage  = ERROR_INVALID_SAP_ID; 
            
            callResponse.EndTime = DateTime.now();
            return callResponse;
		}
		
		String uniqueKey = unixId.trim() + '-' + SapId.trim();

		try{
			objUserSapId = [Select Id, UNIX_ID_gne__c, SAP_ID_gne__c, Status_gne__c, Unique_Key_Calc_gne__c, Unique_Key_gne__c from USER_SAP_IDs_gne__c where Unique_Key_gne__c = :uniqueKey limit 1 ];
			objUserSapId.Status_gne__c = false;
		}
		catch(Exception ex)
		{
			//do nothing
		}
		
		if(objUserSapId==null)
		{
			callResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
            Database.rollback ( savePoint ); 
            callResponse.ErrorMessage  = ERROR_INVALID_UNIX_ID; 
            
            callResponse.EndTime = DateTime.now();
            return callResponse;
		}
		
		try{
			if(objUserSapId!=null )
			{
				Database.Saveresult updateResult = Database.update (objUserSapId);   
		        Id id                          = UpdateResult.getId();
				if ( id == null ) {             
		            callResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
		            Database.rollback ( savePoint ); 
		            Database.Error dbError           = UpdateResult.getErrors()[0];
		            callResponse.ErrorMessage  = dbError.getStatusCode().Name() + ' : '  + 
		                                               dbError.getMessage() ; 
		            
		            callResponse.EndTime = DateTime.now();
		            return callResponse;                
		        }
		        
		         //Request Id to Response Id Map
		        callResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
		        RequestIdResponseIdMap requestIdResponseIdItem = new RequestIdResponseIdMap(); 
		        requestIdResponseIdItem.RequestId  = unixId;
		        requestIdResponseIdItem.ResponseId = id;
		        requestIdResponseIdItem.ObjectType = 'USER_SAP_IDs_gne__c';
		        callResponse.RequestIdResponseIdList.add ( requestIdResponseIdItem ); 
				
			}
		}
		catch(Exception ex)
		{
			callResponse.RequestIdResponseIdList = new List<RequestIdResponseIdMap>();
            Database.rollback ( savePoint ); 
            callResponse.ErrorMessage  = ex.getMessage(); 
            
            callResponse.EndTime = DateTime.now();
            return callResponse;
		}
		
		return callResponse;
    }
    
    
    
}