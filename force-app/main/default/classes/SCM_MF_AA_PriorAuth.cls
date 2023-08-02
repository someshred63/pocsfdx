public class SCM_MF_AA_PriorAuth extends SCM_MergeField{
public SCM_MF_AA_PriorAuth(Case SelectedCase)
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
				List<Benefit_Investigation_gne__c> BIs = [select Prior_Authorization_Required_Formula_gne__c,Benefit_Type_gne__c  from Benefit_Investigation_gne__c where BI_Insurance_gne__c = :Ins[0].id and Print_on_BI_Report_gne__c = 'Yes'];
				if (BIs.size() == 1)
				{
					
				 if (bis[0].Prior_Authorization_Required_Formula_gne__c != null) {
					fieldValue = bis[0].Prior_Authorization_Required_Formula_gne__c;
				 }
					if (fieldvalue == 'Yes')
						fieldValue += '\r\n' + 'If the insurance requires additional documents for renewal of the prior-authorization, we will request those separately once they are identified';	
				}
				else if (BIs.size() > 1)
				{
					boolean IsYes = false;
					for(Benefit_Investigation_gne__c bi : BIs)
					{
						
						if (bi.Benefit_Type_gne__c != null && bi.Prior_Authorization_Required_Formula_gne__c != null)
						{					
						fieldValue += '\r\n' + bi.Benefit_Type_gne__c + ':' + bi.Prior_Authorization_Required_Formula_gne__c ;
						if (bi.Prior_Authorization_Required_Formula_gne__c == 'Yes')
							IsYes = true;
										
						}
											
					}
					//clean remove the \r\n at the start of the string
						fieldValue = fieldValue.replaceFirst('\r\n', '');
					 if (IsYes)
						 {
						 	fieldValue += '\r\n' + 'If the insurance requires additional documents for renewal of the prior-authorization, we will request those separately once they are identified';
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