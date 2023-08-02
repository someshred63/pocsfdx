//Added: Paras Sharma
//Document: RAP-CMGT-FAX-26 One Off.doc
//Test class for Raptiva

@isTest
private class SCM_MD_Fax_OneOff_Rap_Test {

    static testMethod void Fax_OneOff_Rap_Test() {
        String caseId;
        String argLookupID;  
        List<SCM_Merge_Document__c>docs=[Select Product__c, Id 
										 from SCM_Merge_Document__c 
										 where Merge_Class_Name__c='SCM_MD_Fax_OneOff_Rap' and Product__c='Raptiva'];
        //caseId = '500S0000000gjmDIAQ';
        Case documentCase= SCM_CreateTestData.createCase('C&R - Standard Case','Raptiva');
        caseId = documentCase.Id;
        argLookupID = '';
        if(docs.size()>0)
        	argLookupID = docs[0].Id;   
        SCM_MD_Fax_OneOff_Rap mergeDoc = new SCM_MD_Fax_OneOff_Rap(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
        System.debug(test);
        
        /**
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        
        //test for Attn
        String attn = fields[0].fieldValue; 
        System.assertEquals(attn , '');
        
        //test for Addressed To
        String to = fields[1].fieldValue; 
        System.assertEquals(to , 'Alexander Simms');
        
        //test for Fax No
        String fax = fields[2].fieldValue; 
        System.assertEquals(fax , '');
        
        // test for From
        String fro = fields[3].fieldValue; 
        System.assertEquals(fro , 'Aftan Allard');
        
        // test for Ext
        String ext = fields[4].fieldValue; 
        System.assertEquals(ext , '1234');
        
        // test for Case Number
        String casNo = fields[5].fieldValue; 
        System.assertEquals(casNo , '00001703');
        
        // test for Patient Id
        String patId = fields[6].fieldValue; 
        System.assertEquals(patId , '0010004165');
        
        // test for NUT_Phone
        String nutPh = fields[7].fieldValue; 
        System.assertEquals(nutPh , '(866) 480-7762');
        
        // test for NUT_Fax
        String nutfax = fields[8].fieldValue; 
        System.assertEquals(nutfax , '(866) 481-7762');
        
        // test for Nut_URL
        String nutUrl = fields[9].fieldValue; 
        System.assertEquals(nutUrl , 'www.RAPTIVAAccessSolutions.com');
        
        // test for PatientFullName
        String patName = fields[11].fieldValue; 
        System.assertEquals(patName , 'Alfred Dorso');
        
        // test for DOB
        String dob = fields[12].fieldValue; 
        System.assertEquals(dob , '');
        
        
        */
    }
}