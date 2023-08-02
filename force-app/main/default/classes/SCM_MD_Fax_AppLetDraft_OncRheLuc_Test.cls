@isTest
private class SCM_MD_Fax_AppLetDraft_OncRheLuc_Test {

    static testMethod void AppLetDraft_OncRheLucTest() {
    	 
       	String caseId;
        String argLookupID;    
         
        //caseId = '500S0000000gAU5';                
        caseId = '500S0000000gk4g'; 
        argLookupID = '';       
        SCM_MD_Fax_AppealLetterDraft_OncRheLuc mergeDoc = 
        		new SCM_MD_Fax_AppealLetterDraft_OncRheLuc(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        string test = mergeDoc.getXMLString();
       /**
    
        String Attn = fields[0].getFieldValue(); 
        System.assertEquals(Attn , '');
        
       	 String fax = fields[7].getFieldValue(); 
        System.assertEquals(fax , '');
        
         String from1  = fields[8].getFieldValue(); 
        System.assertEquals(from1 , '');
        
         String name = fields[11].getFieldValue(); 
        System.assertEquals(name , '');
        
        **/
        
    }
}