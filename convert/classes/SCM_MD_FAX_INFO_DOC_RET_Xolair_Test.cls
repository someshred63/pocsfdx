@isTest
private class SCM_MD_FAX_INFO_DOC_RET_Xolair_Test {

    static testMethod void testINFO_DOC_RET_Xolair() {
    	
    		
    	   String caseId;
        String argLookupID;       
        
         //First Test C&R
        //caseId = '500S0000000gnt8';
        //caseId = '500S0000000gnnc';
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        argLookupID = '';  
        SCM_MD_FAX_INFO_DOC_RET_Xolair mergeDoc = new SCM_MD_FAX_INFO_DOC_RET_Xolair(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;

       
        //test for Case_Number
        System.assertEquals(fields[16].getFieldValue(), '');
       /** 
         //test for  Product Name
        System.assertEquals(fields[6].getFieldValue(), '');
        
         //test for PatientFullName
        System.assertEquals(fields[7].getFieldValue(), 'R');
        
         //test for Attn
        System.assertEquals(fields[8].getFieldValue(), '');
        **/
    	
    	
    	
   }
    	    
}