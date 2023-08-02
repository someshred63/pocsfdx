/**
 Test Class for SCM_MD_Shipping_Address_Veri.cls..
 Recreated by Sridhar.vangala
 */
@isTest
private class SCM_MD_Shipping_Add_veri_Test
 {

    static testMethod void SCM_MD_Shipping_Add_veri_Test()
     {
        //local variables
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        String argLookupID = '';       
        
        SCM_MD_Shipping_Address_Veri mergeDoc = 
            new SCM_MD_Shipping_Address_Veri(caseId, argLookupId);
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