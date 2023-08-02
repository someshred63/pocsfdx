//Created by : Deepti
//Test Classd For SCM_MD_Fax_DistributorReferral_Nut

@isTest
private class SCM_MD_Fax_DistributorReferral_Nut_Test {
       
    static testMethod void SCM_MD_Fax_DistributorReferral_Nut_Test() {
        String caseId;
        String argLookupID;  
        
        //caseId = '500S0000000gnt9';
        Case documentCase = SCM_CreateTestData.CreateCase();
		caseId = documentCase.Id;
		argLookupID = '';       
        SCM_MD_Fax_DistributorReferral_Nut mergeDoc = new SCM_MD_Fax_DistributorReferral_Nut(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        
        //test for CR_Phone
        String ph = fields[2].fieldValue; 
        System.assertEquals(ph , '');
        
        //test for CR_Fax
        String fax = fields[3].fieldValue; 
        System.assertEquals(fax , 'JIM Prendergast');

        //test for CR_URL
        String url = fields[4].getfieldValue(); 
        System.assertEquals(url , '');

        //test for DateShort
        String dat = fields[5].fieldValue; 
        System.assertEquals(dat , '');
        
        //test for PatientFullName
        String name = fields[6].fieldValue; 
        System.assertEquals(name , '');
        
        //test for DOB
        String dob = fields[7].fieldValue; 
        System.assertEquals(dob , '');
        
        //test for Drug
        String drug = fields[8].fieldValue; 
        System.assertEquals(drug , '');
        
        //test for PatientFullAddress
        String add = fields[9].fieldValue; 
        System.assertEquals(add , '');
        
        //test for PatientPrimeConFullName
        String conname= fields[10].fieldValue; 
        System.assertEquals( conname, '');
        
        //test for PatientPrimeConHmPh
        String conph = fields[11].fieldValue; 
        System.assertEquals( conph, 'm');
       
        //test for PatientPrimeConWkPh
        String conwrkph= fields[12].getfieldValue(); 
        System.assertEquals( conwrkph, '');
      
        //test for ProviderNPI
        String pNpi = fields[13].fieldValue; 
        System.assertEquals(pNpi , '');
    
        // test for FacilityNP
        String fNpi= fields[14].fieldValue; 
        System.assertEquals(fNpi , '');
        
        // test for ConfidNotice
        String confidN = fields[15].fieldValue; 
        System.assertEquals(confidN , '');
        
        // test for Physician Full Name
        String Phyname = fields[16].getfieldValue(); 
        System.assertEquals(Phyname , '');
       
        // test for Pediatric
        String Ped = fields[17].fieldValue; 
        System.assertEquals( Ped, '');
    }
 }