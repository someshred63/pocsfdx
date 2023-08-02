@isTest
private  class SCM_MD_Fax_Hot_InoResourceLetter_Test {
	
	static testMethod void test_Hot_InoResourceLetter()
	{
		List<SCM_Merge_Document__c>docs=[Select Product__c, Id 
										 from SCM_Merge_Document__c 
										 where Merge_Class_Name__c='SCM_MD_Fax_Hot_InoResourceLetter'];
		//Hotline_gne__c hot2 =createHotline(true,'Ophthalmology','Lucentis 10 mg', true);
		String argLookupId='';
		for(SCM_Merge_Document__c doc:docs)
		{
			if(doc.Product__c=='Avastin')
				argLookupId=doc.Id;
		}
		Hotline_gne__c hot1 = SCM_CreateTestData.createHotline(true,'Oncology','Avastin',false);
        System.assertEquals(hot1.Product_gne__c, 'Avastin');
        SCM_MD_Fax_Hot_InoResourceLetter mergeDoc = new SCM_MD_Fax_Hot_InoResourceLetter(hot1.Id, argLookupId);
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
        SCM_MD_Fax_Hot_InoResourceLetter mergeDoc2 = new SCM_MD_Fax_Hot_InoResourceLetter(hot2.Id, argLookupId2);
        mergeDoc2.createMergeFields();
        System.assertEquals(mergeDoc2.selectedHotline.Product_gne__c, null);
        SCM_MergeField[] fields2 = mergeDoc2.mergeRecipientInfo;
	}
}