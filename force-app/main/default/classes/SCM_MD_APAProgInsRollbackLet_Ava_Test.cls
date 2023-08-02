@isTest
private class SCM_MD_APAProgInsRollbackLet_Ava_Test {

    static testMethod void APAProgInsRollbackLetTest() {
        String caseId;
        String argLookupID;  
        
        //caseId = '500S0000000gAU5';                
        //caseId = '500S0000000gk4g';
        //argLookupID = '';       
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
      
        SCM_MD_APAProgInsRollbackLet_Ava mergeDoc = 
        		new SCM_MD_APAProgInsRollbackLet_Ava(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
       
    
        String Attn = fields[0].getFieldValue(); 
        System.assertEquals(Attn , '0010016489');
        
        String Attn1 = fields[1].getFieldValue(); 
        System.assertEquals(Attn1 , '0010003994');
        
        String Attn2 = fields[2].getFieldValue(); 
        System.assertEquals(Attn2 , '(888) 249-4919');
        String Attn3 = fields[3].getFieldValue(); 
        System.assertEquals(Attn3 , '(888) 249-4918');
        String Attn4 = fields[4].getFieldValue(); 
       
        String Attn6 = fields[6].getFieldValue(); 
        System.assertEquals(Attn6 , 'Eric Rumsey');
        String Attn7 = fields[7].getFieldValue(); 
        System.assertEquals(Attn7 , 'Sharon Ponder');
        String Attn8 = fields[8].getFieldValue(); 
        System.assertEquals(Attn8 , '');
        String Attn9 = fields[9].getFieldValue(); 
        System.assertEquals(Attn9 , 'Frankfort, KY');
        String Attn10 = fields[10].getFieldValue(); 
        System.assertEquals(Attn10 , 'Rita Egan');
        
        
    }
}