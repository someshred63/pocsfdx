@isTest
private class SCM_MD_Fax_ChangeOfInsurance_Nut_Test {

    static testMethod void testFax_ChangeOfInsurance_Nut_Test() {
    	 //local variables
        String caseId;
        String argLookupID;       
         
         //First Test
        //caseId = '500S0000000g9HZIAY'; 
        caseId = '500S0000000gelZ';
        argLookupID = '';  
        SCM_MD_Fax_ChangeOfInsurance_Nut mergeDoc = new SCM_MD_Fax_ChangeOfInsurance_Nut(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        
        
        //2 Phone Nutropin
        String phone = fields[2].fieldValue;
        System.assertEquals(phone, '(866) 688-7674');
        
         //3 Fax Nutropin
        String fax = fields[3].fieldValue;
        System.assertEquals(fax, '1-800-545-0612');
        
         //4 Url Nutropin
        //String url = fields[4].fieldValue;
        //System.assertEquals(url, '');
      
        
         //5 Attn
        String attn = fields[5].fieldValue;
        System.assertEquals(attn, '');
       
         //6 Addressed To
       // String to = fields[6].fieldValue;
       // System.assertEquals(to, 'Lance Briggs Jr., M.D.');
      
         //7 RECFax Number
        String no = fields[12].fieldValue;
        System.assertEquals(no, '');
        
         //8 Patient Full Name
        String name = fields[11].fieldValue;
        System.assertEquals(name, 'Sachin Tendulkar');
        
      
    }
}