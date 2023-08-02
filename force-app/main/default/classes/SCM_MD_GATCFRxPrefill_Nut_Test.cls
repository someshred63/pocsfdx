@isTest
// Developer Name    : Deepak Yadav
// Document Name     : NUT-CMGT-FAX-53_GATCF_Rx_Prefill.doc
private class SCM_MD_GATCFRxPrefill_Nut_Test {
static testMethod void testGATCFRxPrefill_Lucentis() {
        String caseId;
        String argLookupID; 
        
        caseId = '500S0000000gnt9';
        argLookupID = '';  
             
        SCM_MD_GATCFRxPrefill_Nut mergeDocument=new SCM_MD_GATCFRxPrefill_Nut(caseId, argLookupID); 
   	    mergeDocument.createMergeFields();
   	    SCM_MergeField[] fields = mergeDocument.mergeRecipientInfo;
   	    string test = mergeDocument.getXMLString();
   	  
   	    //test for GATCF_Fax
        String attn = fields[2].fieldValue; 
        System.assertEquals(attn , '');
        
        /**
        //test for GATCF URL
        String to = fields[3].fieldValue; 
        System.assertEquals(to , '');

        //test for Product
        String fax = fields[4].getfieldValue(); 
        System.assertEquals(fax , '');
       
        // test for Patient Full Name
        String fro = fields[5].fieldValue; 
        System.assertEquals(fro , 'John Abraham');
       
        // test for Date Of Birth
        String ext = fields[6].fieldValue; 
        System.assertEquals(ext , '1/13/1980');
        
        // test for PhysicianFullName
        String casNo = fields[7].fieldValue; 
        System.assertEquals(casNo , 'JIM Prendergast');
     
        // test for PhysicianStAddress
        String patId = fields[8].fieldValue; 
        System.assertEquals(patId , '');
 
        // test for PhysicianCityStateZip
        String nutPh = fields[9].fieldValue; 
        System.assertEquals(nutPh , '');
        
        // test forPhysicianPhone
        String nutfax = fields[10].fieldValue; 
        System.assertEquals(nutfax , '');
        
        // test for PhysicianDEA
        String nutUrl = fields[11].fieldValue; 
        System.assertEquals(nutUrl , '');
      
        //test for GATCF_Disclaimer
        String patName = fields[12].getfieldValue(); 
        System.assertEquals(patName , '');
          
        //test for Attn
        String dob = fields[13].fieldValue; 
        System.assertEquals(dob , '');
        **/
    }
}