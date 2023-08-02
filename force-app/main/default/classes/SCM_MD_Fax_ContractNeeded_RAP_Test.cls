//Added: Rajesh Sinha
//Document: RAP-CMGT-FAX-27 Contract Needed for Raptiva
//Test class for Raptiva
 
@isTest
private class SCM_MD_Fax_ContractNeeded_RAP_Test {

    static testMethod void Fax_ContractNeeded_RAP_Test() {
        // TO DO: implement unit test
        
        String caseId;
        String argLookupID;  
        
        //caseId = '500S0000000gmAqIAI';
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id; 
        argLookupID = '';       
        SCM_MD_Fax_ContractNeeded_RAP mergeDoc = 
        	new SCM_MD_Fax_ContractNeeded_RAP(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
        
        /**
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        
        //test for Attn 
        String attn = fields[0].fieldValue; 
        System.assertEquals(attn , '');
        
        //test for Addressed To
        String to = fields[1].fieldValue; 
        System.assertEquals(to , 'Lance Briggs Jr., M.D.');
        
        //test for Fax No
        String fax = fields[2].fieldValue; 
        System.assertEquals(fax , '');
        
        //test for From
        String from1 = fields[3].fieldValue; 
        System.assertEquals(from1 , 'Aftan Allard');
        
        //test for Ext
        String Ext = fields[4].fieldValue; 
        System.assertEquals(Ext , '1234');
        
        
        // test for Case Number
        String casNo = fields[5].fieldValue; 
        System.assertEquals(casNo , '0010017206');
        
        // test for Patient Id
        String patId = fields[6].fieldValue; 
        System.assertEquals(patId , '0010004166');
         
         // test for RAP_CR_Phone
        String RAP_CR_Phone = fields[7].fieldValue; 
        System.assertEquals(RAP_CR_Phone , '(866) 480-7762');
         
         // test for RAP_CR_FAX
        String RAP_CR_FAX = fields[8].fieldValue; 
        System.assertEquals(RAP_CR_FAX , '(866) 481-7762');
                       
        // test for RAP_URL
        String RAP_URL = fields[9].fieldValue; 
        System.assertEquals(RAP_URL , 'www.RAPTIVAAccessSolutions.com');
        
        //test for DateShort
        //String Date = fields[10].fieldValue; 
        //System.assertEquals(Date , '');
        
        //test for Physician Full Name
        String PhyName = fields[11].fieldValue; 
        System.assertEquals(PhyName , 'Lance Briggs Jr.');
        
        // test for PatientFullName
        String patName = fields[12].fieldValue; 
        System.assertEquals(patName , 'Kishore Kumar');
        
        // test for DOB
        String dob = fields[13].fieldValue; 
        System.assertEquals(dob , '1/8/1980');
        
        //InsuranceName
        String InsuranceName = fields[14].fieldValue; 
        System.assertEquals(InsuranceName , '');
        
        //InsurancePhone
        String InsurancePhone = fields[15].fieldValue; 
        System.assertEquals(InsurancePhone , '');
        
        //InsuranceSubscriberName
        String InsSubName = fields[16].fieldValue; 
        System.assertEquals(InsSubName , '');
        
        //InsuranceSubscriberGroupNum
        String InsSubGroupNum = fields[17].fieldValue; 
        System.assertEquals(InsSubGroupNum , '');
        
        // SubscriberID
        //String SubscriberID = fields[19].fieldValue; 
        //System.assertEquals(SubscriberID , '');
        
         // InsuranceConFullName
        //String InsConFullName = fields[20].fieldValue; 
        //System.assertEquals(InsConFullName , '');
        
        // test for Confidentiality Notice
        //String ConfidNotice = fields[20].fieldValue; 
        //System.assertEquals(ConfidNotice , 'The documents accompanying this facsimile transmission contain information that is confidential or privileged.  This information is intended for the individual or entity named on this transmission sheet.  If you are not the intended recipient, be aware that any disclosure, copying, distribution or use of the contents of this faxed information is strictly prohibited.  If you received this fax in error, please notify us by telephone so that we can arrange for the return of the original documents to us and the re-transmission of them to the intended recipient.');        
        */
           
    }
}