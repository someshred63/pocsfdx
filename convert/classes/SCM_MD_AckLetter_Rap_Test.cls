//Added: Paras Sharma
//Document: RAP - CMGT-FAX-41A Acknowledgement Letter (SPOC) final.doc
//Test class for DERMATOLOGY/ RAPTIVA
@isTest
private class SCM_MD_AckLetter_Rap_Test {

    static testMethod void AckLetter_Rap_Test() {
		
		List<SCM_Merge_Document__c>docs=[Select Product__c, Id 
										 from SCM_Merge_Document__c 
										 where Merge_Class_Name__c='SCM_MD_AckLetter_Rap'];
        Case documentCase = SCM_CreateTestData.CreateCase('C&R - Standard Case','Raptiva');
        String caseId = documentCase.Id;
        String argLookupId = '';
        if(docs.size()>0)
        	argLookupId=docs[0].Id;  
        SCM_MD_AckLetter_Rap mergeDoc = new SCM_MD_AckLetter_Rap(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
	}

}