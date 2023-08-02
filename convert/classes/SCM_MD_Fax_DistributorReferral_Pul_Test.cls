@isTest
private class SCM_MD_Fax_DistributorReferral_Pul_Test {

    static testMethod void myUnitTest() {
    	
    	   String caseId;
        String argLookupID;       
        
         //First Test C&R 
        //caseId = '500S0000000gmN0';
        Case documentCase = SCM_CreateTestData.CreateCase();
		caseId = documentCase.Id;
        //caseId = '500S0000000gnnc';
        argLookupID = '';  
        SCM_MD_Fax_DistributorReferral_Pul mergeDoc = new SCM_MD_Fax_DistributorReferral_Pul(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;

       
        //test for Case_Number
        System.assertEquals(fields[5].getFieldValue(), '');
        /**
         //test for name
        System.assertEquals(fields[5].getFieldValue(), '');
        
         //test for MALE
        System.assertEquals(fields[6].getFieldValue(), 'R');
        
         //test for female
        System.assertEquals(fields[7].getFieldValue(), '');
        
         //test for PatientStAddress2
        System.assertEquals(fields[21].getFieldValue(), '');
        
        //test for PatientStAddress2
        System.assertEquals(fields[24].getFieldValue(), '');
        **/
    }
}