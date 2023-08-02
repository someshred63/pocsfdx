public class SCM_MF_PriorAuth_Short extends SCM_MergeField{
public SCM_MF_PriorAuth_Short(Case SelectedCase)
	{
		 Case SelCase = SelectedCase;
		checked = false;
		displayCheck = false;
		displayTextBox = false;
		key = 'AA_PriorAuth';
		displayLabel = false;
		fieldvalue = '';
		try 
		{
			List<Insurance_gne__c> Ins = [ Select id from Insurance_gne__c where Case_Insurance_gne__c = :selectedCase.id and Bill_Level_gne__c = '1' limit 1 ];
			if (Ins.size() == 1 ) 
			{
				List<Benefit_Investigation_gne__c> BIs = [select Prior_Authorization_Required_gne__c,Benefit_Type_gne__c  from Benefit_Investigation_gne__c where BI_Insurance_gne__c = :Ins[0].id and Print_on_BI_Report_gne__c = 'Yes'];
				if (BIs.size() == 1)
				{
					
				 if (bis[0].Prior_Authorization_Required_gne__c != null) {
					fieldValue = bis[0].Prior_Authorization_Required_gne__c;
				 }
						
				}
				else if (BIs.size() > 1)
				{
					boolean IsYes = false;
					boolean IsNo = false;
					for(Benefit_Investigation_gne__c bi : BIs)
					{
						
						if (bi.Benefit_Type_gne__c != null && bi.Prior_Authorization_Required_gne__c != null)
						{					
						
						if (bi.Prior_Authorization_Required_gne__c == 'Yes')
							IsYes = true;
										
						}
						if (bi.Prior_Authorization_Required_gne__c == 'No')
							IsYes = true;
										
						}					
					
					
					 if (IsYes)
						 {
						 	fieldValue = 'Yes';
						 }
						 else {
						 	if (isNo){
						 		fieldValue = 'No';
						 	}
						 }
						 
				}
				else if (bis.size() == 0)
				{
					fieldValue = '';
				}			
			}		
			else if (ins.size() == 0)
			{
				fieldValue = '';
			}
		
		}
		catch (Exception ex)
		{
			fieldValue = '';
		}
	}
		
}