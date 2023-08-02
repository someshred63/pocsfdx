//Added: Rajesh Sinha
//Document: LUC-CMGT-FAX-17_Req_For_prior_Auth_Pre_Det.doc
//Test class for Lucentis
@isTest
private class SCM_MD_Fax_ReqForPriAuthPreDet_Luc_Test {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test 
        String argLookupID;  
         
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        argLookupID = '';       
        SCM_MD_Fax_ReqForPriAuthPreDet_Luc mergeDoc = new SCM_MD_Fax_ReqForPriAuthPreDet_Luc(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
        System.debug(test); 
        for(SCM_MergeField mf:mergeDoc.mergeRecipientInfo)
        {
        	//if(mf instanceof )
        	if(mf.key=='Patient_DOB')
        		System.assertEquals(mf.getMergeValue(),'6/2/1981');
        	else if(mf.key=='CR_URL')
        		System.assertEquals(mf.getMergeValue(),'www.LUCENTISAccessSolutions.com');
        		
        	else if(mf.key=='CR_Phone')
        		System.assertEquals(mf.getMergeValue(),'(866) 724-9394');
        	else if(mf.key=='CR_Fax')
        		System.assertEquals(mf.getMergeValue(),'(866) 724-9412');
        	else if(mf.key=='Patient_First_And_Last_Name')
        		System.assertEquals(mf.getMergeValue(),'fname TestPatient');
        	else if(mf.key=='PhysicianFullName')
        		System.assertEquals(mf.getMergeValue(),'PhysicianFirst PhysicianLast, M.D.');
        	
        }
    }
}