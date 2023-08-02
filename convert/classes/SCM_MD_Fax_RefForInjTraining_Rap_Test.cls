@isTest
private class SCM_MD_Fax_RefForInjTraining_Rap_Test {

    static testMethod void myUnitTest() {
    	
    	String caseId;
        String argLookupID;  
        
        //caseId = '500S0000000gjmDIAQ';
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        argLookupID = '';       
        SCM_MD_Fax_RefForInjTraining_Rap mergeDoc = new SCM_MD_Fax_RefForInjTraining_Rap(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        
        String caseNumber = fields[0].fieldValue; 
        System.assertEquals(caseNumber , '00001703');
        
        String patientId = fields[1].fieldValue; 
        System.assertEquals(patientId , '0010004165');
       
        String phone = fields[2].fieldValue; 
        System.assertEquals(phone , '(866) 480-7762');
        
        String fax = fields[3].fieldValue; 
        System.assertEquals(fax , '(866) 481-7762');
        
        //String url = fields[4].fieldValue; 
        //System.assertEquals(url , 'www.RAPTIVAAccessSolutions.com');
        
        String attn = fields[5].fieldValue; 
        System.assertEquals(attn , '');
        
        String to = fields[13].fieldValue; 
        System.assertEquals(to , ''); 
        /**
        String faxNo = fields[7].fieldValue; 
        System.assertEquals(faxNo , '');
        
        String from1 = fields[8].fieldValue; 
        System.assertEquals(from1 , 'Aftan Allard');
        
        String extNo = fields[9].fieldValue; 
        System.assertEquals(extNo , '1234');
        
        String currentDate = fields[10].fieldValue; 
        System.assertEquals(currentDate , '1/27/2009');
        
        String patFullName = fields[11].fieldValue; 
        System.assertEquals(patFullName , 'Alfred Dorso');
        
        String parDOB = fields[12].fieldValue; 
        System.assertEquals(parDOB , '');
         
        String patAdd = fields[13].fieldValue; 
        System.assertEquals(patAdd , '');
        **/
    }
}