//Created By : Sridhar
@isTest

private class SCM_MD_FAX_Wholesaler_Raptiva_Test 
{
    
    public static testMethod void Test_FAX_Wholesaler_Raptiva()
     {
       //local variables
        String caseId = '500S0000000goP2';
        String argLookupId = '';
        
        SCM_MD_FAX_Wholesaler_Raptiva mergeDoc = 
            new SCM_MD_FAX_Wholesaler_Raptiva(caseId, argLookupId);
        string test = mergeDoc.getXMLString();
        System.debug(test);    
        
    }
}