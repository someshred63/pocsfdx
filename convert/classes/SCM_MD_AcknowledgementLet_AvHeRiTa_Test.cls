public class SCM_MD_AcknowledgementLet_AvHeRiTa_Test {
	
	static testMethod void testAcknowledgementLetter_AvHeRiTa ()
    {
		String caseId;
        String argLookupID; 
        
        caseId = '500S0000000gnnc';
        argLookupID = '';  
             
        SCM_MD_AcknowledgementLet_AvHeRiTa mergeDocument=new SCM_MD_AcknowledgementLet_AvHeRiTa(caseId, argLookupID); 
   	    mergeDocument.createMergeFields();
   	    SCM_MergeField[] fields = mergeDocument.mergeRecipientInfo;
   	   // string test = mergeDocument.getXMLString();


        //test for Case_Number
       // System.assertEquals(fields[0].getFieldValue(), '0010017453');
         //test for name
        System.assertEquals(fields[12].getFieldValue(), '');
        
    }

}