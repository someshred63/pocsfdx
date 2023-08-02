//Added: Paras Sharma
//Document: NUT_CMGT_FAX_20_ RECERTIFICATION.doc
//Test class for Nutropin

@isTest
private class SCM_MD_Fax_Recertification_Nut_Test {

    static testMethod void Fax_Recertification_Nut_Test() {
        String caseId;
        String argLookupID;  
        
        caseId = '500S0000000gnt9';
        //caseId = '500S0000000g0iF';
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id; 
        argLookupID = '';       
        SCM_MD_Fax_Recertification_Nut mergeDoc = new SCM_MD_Fax_Recertification_Nut(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        
        //test for Attn
        String attn = fields[0].fieldValue; 
        System.assertEquals(attn , '');
        /**
        //test for Addressed To
        String to = fields[1].fieldValue; 
        System.assertEquals(to , 'JIM Prendergast');

        //test for Fax No
        String fax = fields[2].getfieldValue(); 
        System.assertEquals(fax , '');

        // test for From
        String fro = fields[3].fieldValue; 
        System.assertEquals(fro , 'Dinesh Raveendran');
        
        // test for Ext
        String ext = fields[4].fieldValue; 
        System.assertEquals(ext , '');
        
        // test for Case Number
        String casNo = fields[5].fieldValue; 
        System.assertEquals(casNo , '0010017449');
        
        // test for Patient Id
        String patId = fields[6].fieldValue; 
        System.assertEquals(patId , '0010004317');
        
        // test for NUT_Phone
        String nutPh = fields[7].fieldValue; 
        System.assertEquals(nutPh , '(866) Nutropin / (866) 688-7674');
        
        // test for NUT_Fax
        String nutfax = fields[9].fieldValue; 
        System.assertEquals(nutfax , '(800) 545-0612');
        
        // test for Nut_URL
        String nutUrl = fields[10].fieldValue; 
        System.assertEquals(nutUrl , 'www.NutropinAccessSolutions.com');
       
        //test for PatientFullName
        String patName = fields[12].getfieldValue(); 
        System.assertEquals(patName , 'John Abraham');
      
        //test for DOB
        String dob = fields[13].fieldValue; 
        System.assertEquals(dob , '');
    
        // test for Product
        String prod = fields[14].fieldValue; 
        System.assertEquals(prod , 'Nutropin');
        
        // test for Nut_PrivacyNotice
        String nutPrivyNot = fields[15].fieldValue; 
        System.assertEquals(nutPrivyNot , 'To help us protect your patient\'s privacy, please refer to this Case ID No. in all communications with Nutropin Access Solutions/Genentech Access to Care Foundation. Further, please provide this Case ID No. and NOT your patient\'s name when you request information regarding your patient\'s reimbursement status from Genentech, e.g., your clinical specialist or Nutropin Access Solutions/Genentech Access to Care Foundation.');
        
        // test for InsuranceName
        String insName = fields[16].getfieldValue(); 
        System.assertEquals(insName , '');
       
        // test for Confid Notice
        String conNot = fields[16].fieldValue; 
       **/
    }
}