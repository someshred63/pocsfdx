public class SCM_MF_AA_CaCCP extends SCM_MergeField{
public SCM_MF_AA_CaCCP(Case SelectedCase)
    {
        Case SelCase = SelectedCase;
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        key = 'AcctCC_CCP';
        displayLabel = false;
        try {
        	
        	if (selectedcase.Product_gne__c == 'Nutropin') {
        		fieldvalue = 'C&R Continuous Care (CCP): NuAccess services were requested\r\n';        		
        	}
        	else if (selectedcase.Product_gne__c == 'Xolair')
        	{
        		fieldvalue = 'C&R Continuous Care (CCP):  Xolair Starter services were requested\r\n';
        	}
        	else if (selectedcase.Product_gne__c == 'Avasitn')
        	{
        		
        		fieldvalue = 'C&R Continuous Care (CCP):  Avastin Patient Assistance services were requested\r\n';
        	}
        	else {
        		fieldvalue = '';
        	}
        }
        catch (exception ex) {
        	
        	fieldvalue = '';
        	
        }
    }
}