//Added: Rajesh Sinha
//Document: TNK_CMGT_FAX_01_GATCF_INFODOCRETRIEVAL.DOC
//Test Class for TNKase

@isTest
private class SCM_MD_FAX_INFDOC_RETRIEVAL_TNK_Test {

    static testMethod void INFDOC_RETRIEVAL_TNK_Test() {
        // TO DO: implement unit test
        String caseId;
        String argLookupID;  
        
        caseId = '500S0000000goEs';
        argLookupID = '';       
        SCM_MD_FAX_INFDOC_RETRIEVAL_TNK mergeDoc = 
        	new SCM_MD_FAX_INFDOC_RETRIEVAL_TNK(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
        
        /**
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        
        // test for Case Number
        String casNo = fields[6].fieldValue; 
        System.assertEquals(casNo , '0010017513');
        
        // test for Patient Id
        String patId = fields[7].fieldValue; 
        System.assertEquals(patId , '0010004317');
        
        // test for Tnk_Phone
        String tnkPh = fields[8].fieldValue; 
        System.assertEquals(tnkPh , '(800) 530-3083');
        
        // test for Tnk_Fax
        String tnkfax = fields[9].fieldValue; 
        System.assertEquals(tnkfax , '(650) 225-1366');
        
        // test for Tnk_URL
        String tnkUrl = fields[10].fieldValue; 
        System.assertEquals(tnkUrl , 'www.GenentechAccessSolutions.com');
        */
        
        // test for Confid Notice
        //String conNot = fields[15].fieldValue; 
        //System.assertEquals(conNot , 'This document contains confidential information and is intended solely for the use of the individual(s) or entity to which it is addressed.');
            
    }
}