//Added: Paras Sharma
//Document: HER-CMGT-FAX-08_Request_For_Additional_Information_FinalAnalysis.doc
//Test class for Herceptin

@isTest
private class SCM_MD_Fax_RequestForAddInfo_Her_Test {

	static testMethod void Fax_RequestForAddInfo_Her_Test() {
		
		List<SCM_Merge_Document__c>docs=[Select Product__c, Id 
										 from SCM_Merge_Document__c 
										 where Merge_Class_Name__c='SCM_MD_Fax_RequestForAddInfo_Her'];
        Case documentCase = SCM_CreateTestData.CreateCase('C&R - Standard Case','Herceptin');
        String caseId = documentCase.Id;
        String argLookupId = '';
        if(docs.size()>0)
        	argLookupId=docs[0].Id;  
        SCM_MD_Fax_RequestForAddInfo_Her mergeDoc = new SCM_MD_Fax_RequestForAddInfo_Her(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
	}
}