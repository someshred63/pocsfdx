public class SCM_MF_InsuranceAppealName extends SCM_MergeField 
{
  	public SCM_MF_InsuranceAppealName(Case selectedCase) 
  	{
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        setKey('InsuranceAppealName');
        fieldValue = getFieldValue(selectedCase);
        className = 'SCM_MF_InsuranceAppealName';
  	}
  	
  	public SCM_MF_InsuranceAppealName() 
  	{
        //checked = false;
        //displayCheck = false;
        //displayTextBox = false;
        //displayLabel = false;
        //setKey('InsuranceAppealName');
        //fieldValue = getFieldValue(selectedCase);
        //className = 'SCM_MF_InsuranceAppealName';
  	}

	public List<Account> getAppealInfo(Case selectedCase)
	{
		List<Insurance_gne__c> ins;	
		List<Benefit_Investigation_gne__c> bi;
		List<Appeal_Level_gne__c> appeals;
		List<Account> account;
		try
		{
			// Get List of all Insurance_gne__c on insurnace.Case_Insurance_gne__c = Case.Id
			ins = [Select i.Id, i.Case_Insurance_gne__c,i.Payer_gne__c From Insurance_gne__c i 
					where i.Case_Insurance_gne__c = :selectedCase.Id order by 
					lastmodifieddate desc limit 5];
			
			if(ins.size() >0)
			{								
			// Get List of BI on BI_Insurance_gne__c  = Insurance_gne__c.Id
			 bi = [Select b.Id, b.BI_Insurance_gne__c, b.BI_BI_Status_gne__c From 
					Benefit_Investigation_gne__c b where b.BI_Insurance_gne__c in :ins  
					order by lastmodifieddate desc limit 5];
			}
			else
				account = null;									
		//and a.Appeal_Status_gne__c like '%Denied' 
								
			if (bi.size() >0)
			{			
			// Get List of Appeal_Level_gne__c on Appeal_Level_gne__c in BI and Appeal_Status_gne__c Contains Denied or Approved		
			appeals =[Select a.Name, a.Benefit_Investigation_gne__c, a.Appeal_Status_gne__c, a.Appeal_ID_gne__c 
						From Appeal_Level_gne__c a where (a.Appeal_Status_gne__c  like '%Denied' 
						or a.Appeal_Status_gne__c like '%Not Appealable'
						or a.Appeal_Status_gne__c  like '%Approved') 
						and a.Benefit_Investigation_gne__c in :bi 
						order by lastmodifieddate desc ];
			}
			else
				account = null;
				
		
			
			if (appeals.size() >0)
			{	
				// Get List of Appeal_Level_gne__c on Appeal_Level_gne__c in BI and Appeal_Status_gne__c Contains Denied or Approved
				account=[Select a.Name, a.LastName, a.Id, a.FirstName From Account a 
							where a.Id = :ins[0].Payer_gne__c limit 1];
				// Get List of Appeal_Level_gne__c on Appeal_Level_gne__c in BI and Appeal_Status_gne__c Contains Denied or Approved		
				//appeals =[Select a.Name, a.Benefit_Investigation_gne__c, a.Appeal_Status_gne__c, a.Appeal_ID_gne__c 
				//			From Appeal_Level_gne__c a where (a.Appeal_Status_gne__c  like '%Denied' 
				//			or a.Appeal_Status_gne__c like '%Not Appealable'
				//			or a.Appeal_Status_gne__c  like '%Approved') 
				//			and a.Benefit_Investigation_gne__c in :bi 
				//			order by lastmodifieddate desc ];
			}
			else
				account = null;
			
		
		}
		catch(Exception ex)
		{
			account = null;
		}
		return account;							
	}
	
	public List<Account> getApprovedAppealedList(Case selectedCase)
	{
		List<Insurance_gne__c> ins;	
		List<Benefit_Investigation_gne__c> bi;
		List<Appeal_Level_gne__c> appeals;
		List<Account> account;
		
		try
		{
				ins = [Select i.Id, i.Case_Insurance_gne__c,i.Payer_gne__c From Insurance_gne__c i 
					where i.Case_Insurance_gne__c = :selectedCase.Id order by 
					lastmodifieddate desc limit 5];
			
			if(ins.size() >0)
			{								
			// Get List of BI on BI_Insurance_gne__c  = Insurance_gne__c.Id
			 bi = [Select b.Id, b.BI_Insurance_gne__c, b.BI_BI_Status_gne__c From 
					Benefit_Investigation_gne__c b where b.BI_Insurance_gne__c in :ins  
					order by lastmodifieddate desc limit 5];
			}
			else
				account = null;									
		//and a.Appeal_Status_gne__c like '%Denied' 
								
			if (bi.size() >0)
			{			
			// Get List of Appeal_Level_gne__c on Appeal_Level_gne__c in BI and Appeal_Status_gne__c Contains Denied or Approved		
			// Get List of Appeal_Level_gne__c on Appeal_Level_gne__c in BI and Appeal_Status_gne__c Contains Denied or Approved		
			appeals =[Select a.Name, a.Benefit_Investigation_gne__c, a.Appeal_Status_gne__c, a.Appeal_ID_gne__c 
						From Appeal_Level_gne__c a where (
						//a.Appeal_Status_gne__c  like '%Denied' 
						//or
						 a.Appeal_Status_gne__c like '%Not Appealable'
						or a.Appeal_Status_gne__c  like '%Approved') 
						and a.Benefit_Investigation_gne__c in :bi 
						order by lastmodifieddate desc ];
		}
			else
				account = null;
		
				
			if (appeals.size() >0)
			{	
				// Get List of Appeal_Level_gne__c on Appeal_Level_gne__c in BI and Appeal_Status_gne__c Contains Denied or Approved
				account=[Select a.Name, a.LastName, a.Id, a.FirstName From Account a 
							where a.Id = :ins[0].Payer_gne__c limit 1];
				// Get List of Appeal_Level_gne__c on Appeal_Level_gne__c in BI and Appeal_Status_gne__c Contains Denied or Approved		
				//appeals =[Select a.Name, a.Benefit_Investigation_gne__c, a.Appeal_Status_gne__c, a.Appeal_ID_gne__c 
				//			From Appeal_Level_gne__c a where (a.Appeal_Status_gne__c  like '%Denied' 
				//			or a.Appeal_Status_gne__c like '%Not Appealable'
				//			or a.Appeal_Status_gne__c  like '%Approved') 
				//			and a.Benefit_Investigation_gne__c in :bi 
				//			order by lastmodifieddate desc ];
			}
			else
				account = null;
				
		}
		catch(Exception ex)
		{
			account = null;
		}
		
		return account;
	
	
	
	}
	private String getFieldValue(Case selectedCase)
	{
		String ret ='';
		List<Account> ins =getAppealInfo(selectedCase);
		if( null !=  ins)
		{
			if (ins.size() > 0)
			{
				ret = ins[0].Name;
			}	
		}
		return ret;
	}

}