//Added: Rajesh Sinha
//Document: AVST-CMGT-FAX-08_Request_For_Additional_Information_FinalAnalysis.DOC
//Test Class for Avastin

@isTest 
private class SCM_MD_Fax_ReqForAddInfo_AVST_Test {

    static testMethod void ReqForAddInfo_AVST_Test() {
        // TO DO: implement unit test
        String caseId;
        String argLookupID;  
        
        //caseId = '500S0000000gaWg';
        caseId = '500S0000000ggIe';
        
        argLookupID = '';       
        SCM_MD_Fax_ReqForAddInfo_AVST mergeDoc = new SCM_MD_Fax_ReqForAddInfo_AVST(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
        
        //SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        
        //test for DOB
        //String DOB = fields[12].fieldValue; 
        //System.assertEquals(DOB , '');
        
        //test for Attn
        //String attn = fields[0].fieldValue; 
        //System.assertEquals(attn , '');
        
        //test for Addressed To
        //String to = fields[1].fieldValue; 
        //System.assertEquals(to , '');
        
        //test for Fax No
        //String fax = fields[2].fieldValue; 
        //System.assertEquals(fax , '');
          
    }
}