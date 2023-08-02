@isTest
private  class SCM_MD_Hotline_SMN_Test {
    
    static testMethod void test_HotLine_SMN()
    {
        List<SCM_Merge_Document__c>docs=[Select Product__c, Id 
                                         from SCM_Merge_Document__c 
                                         where Merge_Class_Name__c='SCM_MD_Hotline_SMN'];
        //Hotline_gne__c hot2 =createHotline(true,'Ophthalmology','Lucentis 10 mg', true);
        String argLookupId='';
        for(SCM_Merge_Document__c doc:docs)
        {
            if(doc.Product__c=='Avastin')
                argLookupId=doc.Id;
        }
        Hotline_gne__c hot1 = SCM_CreateTestData.createHotline(true,'Oncology','Avastin',false);
        System.assertEquals(hot1.Product_gne__c, 'Avastin');
        SCM_MD_Hotline_SMN mergeDoc = new SCM_MD_Hotline_SMN(hot1.Id, argLookupId);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        
        
        String argLookupId2='';
        for(SCM_Merge_Document__c doc:docs)
        {
            if(doc.Product__c=='Lucentis')
                argLookupId2=doc.Id;
        }
        Hotline_gne__c hot2 = SCM_CreateTestData.createHotline(false,'Ophthalmology','Lucentis 10 mg', true);
        System.assert(hot2.Product_gne__c==null, 'Product must be null!');
        SCM_MD_Hotline_SMN mergeDoc2 = new SCM_MD_Hotline_SMN (hot2.Id, argLookupId2);
        mergeDoc2.createMergeFields();
        System.assertEquals(mergeDoc2.selectedHotline.Product_gne__c, null);
        SCM_MergeField[] fields2 = mergeDoc2.mergeRecipientInfo;
        
        String argLookupId3='';
        for(SCM_Merge_Document__c doc:docs)
        {
            if(doc.Product__c=='Nutropin')
                argLookupId3=doc.Id;
        }
        Hotline_gne__c hot3 = SCM_CreateTestData.createHotline(false,'Oncology','Nutropin', true);
        System.assert(hot3.Product_gne__c==null, 'Product must be null!');
        SCM_MD_Hotline_SMN mergeDoc3 = new SCM_MD_Hotline_SMN (hot3.Id, argLookupId3);
        mergeDoc3.createMergeFields();
        System.assertEquals(mergeDoc2.selectedHotline.Product_gne__c, null);
        SCM_MergeField[] fields3 = mergeDoc3.mergeRecipientInfo;
        
        String argLookupId4='';
        for(SCM_Merge_Document__c doc:docs)
        {
            if(doc.Product__c=='Raptiva')
                argLookupId4=doc.Id;
        }
        Hotline_gne__c hot4 = SCM_CreateTestData.createHotline(false,'Dermatology','Raptiva', true);
        System.assert(hot4.Product_gne__c==null, 'Product must be null!');
        SCM_MD_Hotline_SMN mergeDoc4 = new SCM_MD_Hotline_SMN (hot4.Id, argLookupId4);
        mergeDoc4.createMergeFields();
        System.assertEquals(mergeDoc2.selectedHotline.Product_gne__c, null);
        SCM_MergeField[] fields4 = mergeDoc3.mergeRecipientInfo;
        
        
    }
}