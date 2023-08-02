//Added: Paras Sharma
//Document: CMGT-FAX-23 - Distributor Referral
//Test class for Lucentis
//Modified by Shobha Rawat

@isTest
private class SCM_MD_Fax_DistributorReferral_Luc_Test {

    static testMethod void Fax_DistributorReferral_Luc_Test() {
        String caseId;
        String argLookupID;  
        
        Case TestCase = SCM_CreateTestData.CreateCase('C&R - Standard Case','Lucentis');
        caseId = TestCase.Id;

        argLookupID = '';       
        SCM_MD_Fax_DistributorReferral_Luc mergeDoc = new SCM_MD_Fax_DistributorReferral_Luc(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;

        mergeDoc.getLatestValues();
 
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