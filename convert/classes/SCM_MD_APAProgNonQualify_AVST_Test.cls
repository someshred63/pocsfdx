//Added: Rajesh Sinha
//Document: AVA-CMGT-FAX-68_APA Program Non Qualify Letter.doc
//Test Class for Avastin
@isTest

private class SCM_MD_APAProgNonQualify_AVST_Test {

    static testMethod void APAProgNonQualify_AVST_Test() {
    	// TO DO: implement unit test
        String caseId;
        String argLookupID;  
        
        //caseId = '500S0000000gnnc';
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
      
        argLookupID = '';       
        SCM_MD_APAProgNonQualify_AVST mergeDoc = new SCM_MD_APAProgNonQualify_AVST(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
         /**
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        
        //test for InfusionTotal
        String InfusionTotal = fields[0].fieldValue; 
        System.assertEquals(InfusionTotal , '');
       
        //test for CR_Fax
        String fax = fields[1].fieldValue; 
        System.assertEquals(fax , '(888) 249-4919');
        
        //test for CR_Phone
        String phone = fields[2].fieldValue; 
        System.assertEquals(phone , '(888) 249-4918');
        
        //test for Case Number
        String caseno = fields[3].fieldValue; 
        System.assertEquals(caseno , '0010008059');
        
        //test for CaseWorker
        String CaseWorker = fields[4].fieldValue; 
        System.assertEquals(CaseWorker , 'Aftan Allard');
        
        //test for DateLong
        String DateLong = fields[5].fieldValue; 
        System.assertEquals(DateLong , '2/5/2009');
        
        //test for Patient Full Name
        String patName = fields[6].fieldValue; 
        System.assertEquals(patName , '');
        
        //test for PhysicianCityStateZip
        String phyCSZ = fields[7].fieldValue; 
        System.assertEquals(phyCSZ , 'testing, KY 32434-3432');
        
        //test for PhysicianName
        String phyName = fields[8].fieldValue; 
        System.assertEquals(phyName , 'Lance Briggs Jr.');
        
        //test for PhysicianStAddress
        String phyStAdd = fields[9].fieldValue; 
        System.assertEquals(phyStAdd , '');
        */
    }
}