@isTest
// Developer Name    : Jatin Setia
// Document Name     : LUC-CMGT-FAX-53_GATCF_Rx_Prefill.doc
private class SCM_MD_GATCFRxPrefill_Lucentis_Test {

    static testMethod void testGATCFRxPrefill_Lucentis() {
        String argLookupID; 
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        argLookupID = '';  
             
        SCM_MD_GATCFRxPrefill_Lucentis mergeDocument=new SCM_MD_GATCFRxPrefill_Lucentis(caseId, argLookupID); 
   	    mergeDocument.createMergeFields();
   	    SCM_MergeField[] fields = mergeDocument.mergeRecipientInfo;
   	    string test = mergeDocument.getXMLString(); 
   	    for(SCM_MergeField mf:mergeDocument.mergeRecipientInfo)
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