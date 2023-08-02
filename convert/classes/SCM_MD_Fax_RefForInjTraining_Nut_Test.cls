@isTest
private class SCM_MD_Fax_RefForInjTraining_Nut_Test {

    static testMethod void testRefForInjTraining_Nut() {
    	
		/**
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        String argLookupId = '';

        SCM_MD_Fax_RefForInjTraining_Nut mergeDoc =
        new SCM_MD_Fax_RefForInjTraining_Nut(caseId, argLookupId);

        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        String test = mergeDoc.getXMLString();
		**/
		
		  String caseId;
        String argLookupID;       
        
        //First Test GATCF 
        caseId = '500S0000000gnxa';
        //caseId = '500S0000000gnnc';
        argLookupID = '';  
        SCM_MD_Fax_RefForInjTraining_Nut mergeDoc = new SCM_MD_Fax_RefForInjTraining_Nut(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;

       
        //test for All Fields
        System.assertEquals(fields[19].getFieldValue(), '');
        
         
    }
}