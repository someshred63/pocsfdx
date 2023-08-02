public class SCM_MF_Physician_Fax extends SCM_MergeField
{
protected String selectedCaseId;
	public Account acc;
	public Case cid;
	
	public SCM_MF_Physician_Fax(String caseId)
	{
		selectedCaseId=caseId;
	}
	public override String getFieldValue()
	{
		String iid=getPhysicianId(selectedCaseId);
		//SCM_MergeField_PhysicianDEA ob=new SCM_MergeField_PhysicianDEA(selectedCaseId);
		List<Account> af=[Select a.Fax From Account a where a.Id=:iid LIMIT 10];
		//String val=String.valueOf(af.Fax);
		if(af !=null && !af.isEmpty())
		{
			acc=af[0];
			if(acc.Fax !=null)
			{			
			    return String.valueof(acc.Fax);
			}
			else
			{
				return '';
			}
		}
		else
		{
			return '';
		}
	}
	public String getPhysicianId(String caseId)
	{
		//List<Case> c=[select c.Case_Treating_Physician_gne__r.Id from Case c where c.Id=:caseId LIMIT 10];
		List<Case> c=[Select c.Case_Treating_Physician_gne__c From Case c where c.Id=:caseId LIMIT 10];
		if(c !=null && !c.isEmpty()) 
		{
			cid=c[0];
			if(cid.Case_Treating_Physician_gne__c !=null)
			{
				return String.valueOf(cid.Case_Treating_Physician_gne__c);
			}
			else
			{
				return '';
			}
			
		}
		else
		{
			return '';
		}
	}

}