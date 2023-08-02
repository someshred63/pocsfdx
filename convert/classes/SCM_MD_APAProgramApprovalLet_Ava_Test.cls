// Added By: Deepak Yadav

@isTest
private class SCM_MD_APAProgramApprovalLet_Ava_Test {

    static testMethod void APAProgramApprovalLetTest() {       
        String caseId;
        String argLookupID;  
        
        //caseId = '500S0000000gAU5';                
        caseId = '500S0000000gk4g';
        argLookupID = '';       
        SCM_MD_APAProgramApprovalLet_Ava mergeDoc = 
        		new SCM_MD_APAProgramApprovalLet_Ava(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();        
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        
       
    }
}