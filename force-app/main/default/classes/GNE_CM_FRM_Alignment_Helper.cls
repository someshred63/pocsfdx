public class GNE_CM_FRM_Alignment_Helper 
{
	public static Map<String, Set<String>> zipsToReallign {get; set;}
	
    public static List<GNE_CM_Case_Owner_FRM_Alignment__c> searchForFRMAlignment(String zipCode, String product)
    {         
         return [select GNE_CM_Primary_Case_Manager_gne__c,
                       GNE_CM_Secondary_Case_Manager_gne__r.Name,
                       GNE_CM_Primary_Foundation_Specialist_gne__r.Name,
                       GNE_CM_Secondary_Foundation_Specialist__c,GNE_CM_Reimbursement_Specialist_gne__c,GNE_CM_Reimbursement_Specialist_gne__r.Name, 
                       GNE_CM_CS_gne__r.Name,
                       GNE_CM_FRM_gne__r.Name
                from GNE_CM_Case_Owner_FRM_Alignment__c
                where GNE_CM_FRM_Zip_gne__c = :zipCode
                and GNE_CM_Product_gne__c = :product];
    }
    
    public static List<GNE_CM_Case_Owner_FRM_Alignment__c> searchForFRMAlignment(List<String> zipCodes, List<String> products)
    {         
         return [select GNE_CM_Primary_Case_Manager_gne__c,
                       GNE_CM_Secondary_Case_Manager_gne__r.Name,
                       GNE_CM_Primary_Foundation_Specialist_gne__r.Name,
                       GNE_CM_Secondary_Foundation_Specialist__c,GNE_CM_Reimbursement_Specialist_gne__c,GNE_CM_Reimbursement_Specialist_gne__r.Name, 
                       GNE_CM_CS_gne__r.Name,
                       GNE_CM_FRM_gne__r.Name,
                       GNE_CM_FRM_Zip_gne__c, GNE_CM_Product_gne__c
                from GNE_CM_Case_Owner_FRM_Alignment__c
                where GNE_CM_FRM_Zip_gne__c in :zipCodes
                and GNE_CM_Product_gne__c in :products];
    }
    
    public static Set<String> getProductsForAlignment()
    {
    	Set<String> result = new Set<String>();
    	
        String env = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Environment_Name__c;
		for(GNE_CM_Auto_Alignment_Product__c envVar : GNE_CM_Auto_Alignment_Product__c.getAll().values()){
			if(envVar.Environment__c == env || envVar.Environment__c.toLowerCase() == 'all'){
		    	result.add(envVar.Value__c);
		    }
		}
		
    	/*
    	Set<String> result = new Set<String>();
    	
    	List<Environment_Variables__c> envVar = GNE_CM_Environment_variable.get_envVariable(new Set<String>{'GNE-CM-Auto-Alignment-Product'});
		for (Environment_Variables__c ev : envVar)
		{
			result.add(ev.Value__c);
		}
		*/
		return result;
    }

    public static List<List<String>> getInvalidProductZip(Map<String, Set<String>> productZipMap)
    {
        List<List<String>> invalidProductZip = new List<List<String>>();
        for(String product : productZipMap.keySet())
        {
            List<GNE_CM_Case_Owner_FRM_Alignment__c> duplicates = [SELECT GNE_CM_Product_gne__c, GNE_CM_FRM_Zip_gne__c FROM GNE_CM_Case_Owner_FRM_Alignment__c 
                                                        WHERE GNE_CM_Product_gne__c =: product AND
                                                        GNE_CM_FRM_Zip_gne__c IN : productZipMap.get(product)];
            
            for(GNE_CM_Case_Owner_FRM_Alignment__c dup : duplicates)
            {
                invalidProductZip.add(new List<String>{dup.GNE_CM_Product_gne__c, dup.GNE_CM_FRM_Zip_gne__c});
            }
        }
        return invalidProductZip;
    }

	public static void changeOwner(String oldOwner, String newOwner, Case caseItem)
	{
    	List<Error_log_gne__c> errorLogList = new List<Error_log_gne__c>();		
		List<caseShare>caseshare_list = new List<caseShare>();
		List<caseShare>csh_list = new List<caseShare>();
		String Caseowner = oldOwner;
		Case css = caseItem;
		css.OwnerId = newOwner;
		Integer taskFlag=1;
		List<Environment_Variables__c> ev_list = new List<Environment_Variables__c>();
		Map<String,String> Profilemap = new Map<String,String>();
		Map<String,String> Valuemap = new Map<String,String>();
		Set<String>profileset = new Set<String>();
		List<Task> task_list = new List<Task>();
		List<Task> taskupdate_list = new List<Task>();
		String querystring;     
		String Casenum = css.CaseNumber;
		String case_record_type = css.recordtype.Name;
		if(css.OwnerId != Caseowner)
		{
			try 
			{
				caseshare_list = [Select CaseId, UserorGroupId,CaseAccessLevel, RowCause from CaseShare where CaseId=:css.id and RowCause = 'Manual'];
			}
			catch(exception e)
			{
		        errorLogList.add(new Error_log_gne__c(Error_Level_gne__c = 'Low',
		                                       Code_Type__c       = 'Apex Class',
                                               Snippet_Name__c    = 'GNE_CM_FRM_Alignment_Helper.changeOwner',
                                               User_Name__c       = UserInfo.getUserName(),
                                               Object_Name__c     = 'Case',    
                                               Error_Description__c  = e.getMessage()
                                               ));				
				throw e;
			}
			finally
			{
				if(errorLogList.size() > 0)
        		{
            		insert errorLogList;
            		errorLogList.clear();
        		}
			}
			for(integer i = 0; i< caseshare_list.size(); i++)
			{
				CaseShare csh = new CaseShare();
				csh.CaseId =  caseshare_list[i].CaseId;
				csh.UserorGroupId = caseshare_list[i].UserorGroupId;
				csh.CaseAccessLevel = caseshare_list[i].CaseAccessLevel;
				csh_list.add(csh);
			}
		}
		try 
		{
			insert csh_list;
			taskFlag = 1;
		}
		catch(DMLException ex)
		{
	        errorLogList.add(new Error_log_gne__c(Error_Level_gne__c = 'Low',
		                                       Code_Type__c       = 'Apex Class',
                                               Snippet_Name__c    = 'GNE_CM_FRM_Alignment_Helper.changeOwner',
                                               User_Name__c       = UserInfo.getUserName(),
                                               Object_Name__c     = 'Case',    
                                               Error_Description__c  = ex.getMessage()
                                               ));			
			taskFlag= 0;
			throw ex;
		}
		finally
		{
			if(errorLogList.size() > 0)
    		{
        		insert errorLogList;
        		errorLogList.clear();
    		}
		}		
		try
		{
			if(taskFlag == 1)
			{
		        String env = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Environment_Name__c;
				for(GNE_CM_CASE_OWNER_TASK_INCLUDED_PROFILES__c envVar : GNE_CM_CASE_OWNER_TASK_INCLUDED_PROFILES__c.getAll().values()){
					if((envVar.Environment__c == env || envVar.Environment__c.toLowerCase() == 'all') && envVar.Description_Name__c == case_record_type){
				    	Profilemap.put(envVar.Value__c, envVar.Value__c);
				    }
				}
				for(GNE_CM_CASE_OWNER_TASK_REASSIGN_LOGIC__c envVar : GNE_CM_CASE_OWNER_TASK_REASSIGN_LOGIC__c.getAll().values()){
					if((envVar.Environment__c == env || envVar.Environment__c.toLowerCase() == 'all') && envVar.Description_Name__c == case_record_type){
				    	Valuemap.put('CASE_OWNER_TASK_REASSIGN_LOGIC', envVar.Value__c);
				    }
				}					
				/*
				ev_list= [Select Key__c , value__c from Environment_Variables__c  where Key__c IN ('CASE_OWNER_TASK_INCLUDED_PROFILES', 'CASE_OWNER_TASK_REASSIGN_LOGIC') and Description_Name__c = :case_record_type];   
				for(integer j= 0; j<ev_list.size(); j++)
				{
					if(ev_list[j].Key__c  == 'CASE_OWNER_TASK_INCLUDED_PROFILES' )
					{
						Profilemap.put(ev_list[j].value__c,ev_list[j].value__c);
					}
					
					if (ev_list[j].Key__c == 'CASE_OWNER_TASK_REASSIGN_LOGIC')
					{
						Valuemap.put(ev_list[j].Key__c, ev_list[j].value__c);
					}              
				}    
				*/
				
				profileset = Profilemap.keySet();
				if(profileset.size() == 0)
				{
					querystring = 'select id , ownerid  from task where Isclosed = false and CM_Case_Number_gne__c = :Casenum ';
				}
				else
				{
					querystring = 'select id , ownerid  from task where Isclosed = false and CM_Case_Number_gne__c = :Casenum AND OwnerId IN (SELECT ID FROM User WHERE Profile.Name IN :profileset)';                                         
				}
				
				task_list  = Database.query(querystring);
				
				if(Valuemap.get('CASE_OWNER_TASK_REASSIGN_LOGIC') == 'Owner Only')
				{
					for(integer k = 0; k<task_list.size();k++)
					{
						if (task_list[k].OwnerId  == Caseowner)
						{ 
							task_list[k].OwnerId = css.OwnerId ; 
							taskupdate_list.add(task_list[k]);
						}
					}
				}
				else if(Valuemap.get('CASE_OWNER_TASK_REASSIGN_LOGIC') == 'All Tasks')
				{
					for(integer k = 0; k<task_list.size();k++)
					{              
						task_list[k].OwnerId = css.OwnerId ; 
						taskupdate_list.add(task_list[k]);
					}
				}
				try
				{ 
					if(taskupdate_list.size()>0)
					{
						GNE_CM_Request_Assignment_Helper.skipProfileValidation = true;						
						update taskupdate_list;
						GNE_CM_Request_Assignment_Helper.skipProfileValidation = false;
					}
				}
				catch(DMLException ex)
				{
			        errorLogList.add(new Error_log_gne__c(Error_Level_gne__c = 'Low',
		                                       Code_Type__c       = 'Apex Class',
                                               Snippet_Name__c    = 'GNE_CM_FRM_Alignment_Helper.changeOwner',
                                               User_Name__c       = UserInfo.getUserName(),
                                               Object_Name__c     = 'Case',    
                                               Error_Description__c  = ex.getMessage()
                                               ));						
					throw ex;
				}
				finally
				{
					if(errorLogList.size() > 0)
		    		{
		        		insert errorLogList;
		        		errorLogList.clear();
		    		}
				}				
			}
		}
		catch(exception e)
		{
	        errorLogList.add(new Error_log_gne__c(Error_Level_gne__c = 'Low',
                                       Code_Type__c       = 'Apex Class',
                                       Snippet_Name__c    = 'GNE_CM_FRM_Alignment_Helper.changeOwner',
                                       User_Name__c       = UserInfo.getUserName(),
                                       Object_Name__c     = 'Case',    
                                       Error_Description__c  = e.getMessage()
                                       ));			
			throw e;
		}
		finally
		{
			if(errorLogList.size() > 0)
    		{
        		insert errorLogList;
        		errorLogList.clear();
    		}
		}		
	}
	
	public static void changeOwnerForAllTasks(String oldOwner, String newOwner, Case caseItem)
	{
    	List<Error_log_gne__c> errorLogList = new List<Error_log_gne__c>();		
		List<caseShare>caseshare_list = new List<caseShare>();
		List<caseShare>csh_list = new List<caseShare>();
		String Caseowner = oldOwner;		
		caseItem.OwnerId = newOwner;
		Integer taskFlag=1;
		List<Task> task_list = new List<Task>();
		List<Task> taskupdate_list = new List<Task>();		 
		String Casenum = caseItem.CaseNumber;
		String case_record_type = caseItem.recordtype.Name;
		if(caseItem.OwnerId != Caseowner)
		{
			try 
			{
				caseshare_list = [Select CaseId, UserorGroupId,CaseAccessLevel, RowCause from CaseShare where CaseId=:caseItem.id and RowCause = 'Manual'];
			}
			catch(exception e)
			{
		        errorLogList.add(new Error_log_gne__c(Error_Level_gne__c = 'Low',
		                                       Code_Type__c       = 'Apex Class',
                                               Snippet_Name__c    = 'GNE_CM_FRM_Alignment_Helper.changeOwner',
                                               User_Name__c       = UserInfo.getUserName(),
                                               Object_Name__c     = 'Case',    
                                               Error_Description__c  = e.getMessage()
                                               ));				
				throw e;
			}
			finally
			{
				if(errorLogList.size() > 0)
        		{
            		insert errorLogList;
            		errorLogList.clear();
        		}
			}
			for(integer i = 0; i< caseshare_list.size(); i++)
			{
				CaseShare csh = new CaseShare();
				csh.CaseId =  caseshare_list[i].CaseId;
				csh.UserorGroupId = caseshare_list[i].UserorGroupId;
				csh.CaseAccessLevel = caseshare_list[i].CaseAccessLevel;
				csh_list.add(csh);
			}
		}
		try 
		{
			insert csh_list;
			taskFlag = 1;
		}
		catch(DMLException ex)
		{
	        errorLogList.add(new Error_log_gne__c(Error_Level_gne__c = 'Low',
		                                       Code_Type__c       = 'Apex Class',
                                               Snippet_Name__c    = 'GNE_CM_FRM_Alignment_Helper.changeOwner',
                                               User_Name__c       = UserInfo.getUserName(),
                                               Object_Name__c     = 'Case',    
                                               Error_Description__c  = ex.getMessage()
                                               ));			
			taskFlag= 0;
			throw ex;
		}
		finally
		{
			if(errorLogList.size() > 0)
    		{
        		insert errorLogList;
        		errorLogList.clear();
    		}
		}		
		try
		{
			if(taskFlag == 1)
			{	
				task_list  = [select id , ownerid  from task where Isclosed = false and CM_Case_Number_gne__c = :Casenum];
								
				for(integer k = 0; k<task_list.size();k++)
				{              
					task_list[k].OwnerId = caseItem.OwnerId ; 
					taskupdate_list.add(task_list[k]);
				}
				
				try
				{ 
					if(taskupdate_list.size()>0)
					{					
						GNE_CM_Request_Assignment_Helper.skipProfileValidation = true;
						update taskupdate_list;
						GNE_CM_Request_Assignment_Helper.skipProfileValidation = false;					
					}
				}
				catch(DMLException ex)
				{
			        errorLogList.add(new Error_log_gne__c(Error_Level_gne__c = 'Low',
		                                       Code_Type__c       = 'Apex Class',
                                               Snippet_Name__c    = 'GNE_CM_FRM_Alignment_Helper.changeOwner',
                                               User_Name__c       = UserInfo.getUserName(),
                                               Object_Name__c     = 'Case',    
                                               Error_Description__c  = ex.getMessage()
                                               ));						
					throw ex;
				}
				finally
				{
					if(errorLogList.size() > 0)
		    		{
		        		insert errorLogList;
		        		errorLogList.clear();
		    		}
				}				
			}
		}
		catch(exception e)
		{
	        errorLogList.add(new Error_log_gne__c(Error_Level_gne__c = 'Low',
                                       Code_Type__c       = 'Apex Class',
                                       Snippet_Name__c    = 'GNE_CM_FRM_Alignment_Helper.changeOwner',
                                       User_Name__c       = UserInfo.getUserName(),
                                       Object_Name__c     = 'Case',    
                                       Error_Description__c  = e.getMessage()
                                       ));			
			throw e;
		}
		finally
		{
			if(errorLogList.size() > 0)
    		{
        		insert errorLogList;
        		errorLogList.clear();
    		}
		}		
	}   
}