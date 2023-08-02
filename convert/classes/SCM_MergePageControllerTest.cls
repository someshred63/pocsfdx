@isTest 
private class SCM_MergePageControllerTest {
    
    public static testMethod void  testControllerWithHotlineFaxCover()
    {
   		List<SCM_Merge_Document__c>docs=[Select Product__c, Id , Label__c,
											Metadata_Key__c, Merge_Class_Name__c
										   from SCM_Merge_Document__c 
										  where Merge_Class_Name__c='SCM_MD_Fax_Hot_MsgFromAccessSolutions' limit 1];
		Hotline_gne__c docHotline = SCM_CreateTestData.createHotline(true,'Ophthalmology','Lucentis 10 mg', false);
    	SCM_MergePageController controller = new SCM_MergePageController();
        controller.initialize(docHotline.Id, 'hotline');
        SCM_Merge_Document__c doc = docs[0];
        System.debug('\nHotline Id :'+ docHotline.Id +'\n'  );
	    System.debug('\nDocName :'+  doc.Label__c +'\n'  );
	    System.debug('\nClassName :'+  doc.Merge_Class_Name__c +'\n'  );
	    System.debug('\nMetadata_Key :'+  doc.Metadata_Key__c +'\n'  );
	        
	    controller.selectedSCMMergeDocumentID =doc.Id;
	    Boolean next = controller.stepNextDisabled;
	         
	        controller.SCMMergeDocument=null; 
	        SCM_Merge_Document__c mergeDocument = controller.SCMMergeDocument;
	        List<SelectOption> optionList= controller.docIdList;
	        controller.docIdList=optionList;
	         
	        controller.step1();
	        
	        

	        System.debug('\nController objectId : ' + controller.objectId + '\n'  );

	        List<SCM_MergeField> fields= controller.mergeRecipientInfo;
	        controller.mergeRecipientInfo=fields;
	        fields= controller.mergeFields;
	        controller.mergeFields=fields;
	      //  String tempHotlineNumber = controller.selectedHotline.CaseNumber; 
	        String mailMergeStatus = controller.getMailMergeStatus();
	           
	        //String viewState = SCM_MergeDocumentCaching.createViewStateXML(mergeDoc.mergeFields);
	    
	       // System.debug('\n Starting Merge Field Values \n'  );
	       // List<SCM_MergeField> mergeFieldsList = SCM_MergeDocumentCaching.getSectionMergeFields(viewState,'MergeFields');
	       // System.debug('\n MERGE FIELDS LIST SIZE : '+mergeFieldsList.size() +  ' ORIGINAL SIZE : '+ mergeDoc.mergeFields.size() + ' \n'  );
	        
	       // System.assert(mergeFieldsList.size()==mergeDoc.mergeFields.size(), 
	       //             'mergeFields must have the equal count');
	 
	        controller.previous();
	        String buttonLabel = controller.createDocumentButtonLabel; 
	        controller.step1();
	        controller.getDisplayMessages();
	       /* controller.getAttentionIndex();
	        controller.getContactOptions();
	        controller.getContactSelectOptions();
	        controller.getDisplayContactDropdown();
	        controller.getFaxNumberIndex();
	        controller.getRecipientIndex();
	        controller.getDisplayMessages();
	        controller.setMailMergeStatus(controller.getMailMergeStatus());
	        */
	        controller.step2();
	        controller.previous();
	        controller.step2(); 
	        
	        Boolean isDisabled= controller.stepNextDisabled;
	        String jobKey = controller.MailMergeJobKey;
	        SCM_MergeDocument mergeDoc = controller.getMergeDoc();
	        mergeDoc.save(true);
	        mergeDoc.setRequireSystemDocUI(mergeDoc.getRequireSystemDocUI());
	        mergeDoc.load();
	        List<SCM_MergeField> recipientInfoList = controller.mergeRecipientInfo;
	        List<SCM_MergeField> mergeFields = controller.mergeFields;
	            
	        System.debug('\n Starting Recipient Field Values \n'  );
	        controller.step3();
	        jobKey = controller.MailMergeJobKey;
	        mergeDoc.load(); 
	        mergedoc.getLatestValues();
	        mergedoc.printValues();
	        mergeDoc.checkRequiredFields();
	        try
	        {
	        	controller.checkMailMergeJob();
	        	
	        }
	        catch(Exception exp)
	        {
	        }
	        
	        try
	        {
	        	controller.checkMailMergeJob();
	        	
	        }
	        catch(Exception exp)
	        {
	        }
    }
    public static testMethod void  testControllerWithCaseFaxCover()
    {   
             
        SCM_MergeDocumentFactory.createMergeDocument(null, null, null); 
        SCM_MergePageController controller = new SCM_MergePageController();
        controller.initialize();
       // String currentVS = controller.viewState; 
        Boolean next = controller.stepNextDisabled;
        List<SCM_Merge_Document__c>docs=[Select Product__c, Id , Label__c, Metadata_Key__c,
        										Merge_Class_Name__c
										 from SCM_Merge_Document__c 
										 where Merge_Class_Name__c='SCM_MD_Fax_ClaimsFollowUp' limit 1];
		
		String argLookupId='';
		for(SCM_Merge_Document__c doc:docs)
		{
			if(doc.Product__c=='Lucentis')
				argLookupId=doc.Id;
		}
        
        Case docCase = SCM_CreateTestData.CreateCase('GATCF - Standard Case','Lucentis');
        controller = new SCM_MergePageController();
        controller.initialize(docCase.Id, 'case');
        
        //controller.caseNumber = docCase.caseNumber;
        //controller.initialize();
        List<SCM_MergeField> fields= controller.mergeRecipientInfo;
        //controller.mergeRecipientInfo=fields;
        //fields= controller.mergeFields;
        //controller.mergeFields=fields; 
        List<SelectOption> docList= controller.docIdList;
        System.assert(docList.size()>0, 'No available documents are found!');
        Integer index = 0;
        Integer maxDocument = 1;
            SCM_Merge_Document__c doc = docs[index];
            index++;
	        //[Select ID,Label__c,Merge_Class_Name__c,Metadata_Key__c from SCM_Merge_Document__c  where Id=:option.getValue()];
	        System.debug('\nCase Id :'+ docCase.Id +'\n'  );
	        System.debug('\nDocName :'+  doc.Label__c +'\n'  );
	        System.debug('\nClassName :'+  doc.Merge_Class_Name__c +'\n'  );
	        System.debug('\nMetadata_Key :'+  doc.Metadata_Key__c +'\n'  );
	        
	        controller.selectedSCMMergeDocumentID =doc.Id;
	        next = controller.stepNextDisabled;
	         
	        controller.SCMMergeDocument=null; 
	        SCM_Merge_Document__c mergeDocument = controller.SCMMergeDocument;
	        List<SelectOption> optionList= controller.docIdList;
	        controller.docIdList=optionList;
	         
	        controller.step1();
	        SCM_MergeDocument mergeDoc = controller.getMergeDoc();
	        
	        //controller.setMergeRecipientInfo(mergeDoc.mergeRecipientInfo);
	        //controller.setMergeFields(mergeDoc.mergeFields);
	        System.debug('\nController objectId : ' + controller.objectId + '\n'  );
	        
	       // if(mergeDoc==null)
	       // 	continue;
	       // System.assert(mergeDoc!=null, 'Merge Document cannot be null!'); 
	         
	        
	        fields= controller.mergeRecipientInfo;
	        controller.mergeRecipientInfo=fields;
	        fields= controller.mergeFields;
	        controller.mergeFields=fields;
	        String tempCaseNumber = mergeDoc.selectedCase.CaseNumber; 
	        String mailMergeStatus = controller.getMailMergeStatus();
	        controller.getContactSelectOptions();
	        String viewState = SCM_MergeDocumentCaching.createViewStateXML(mergeDoc.mergeFields);
	    
	        System.debug('\n Starting Merge Field Values \n'  );
	        List<SCM_MergeField> mergeFieldsList = SCM_MergeDocumentCaching.getSectionMergeFields(viewState,'MergeFields');
	        System.debug('\n MERGE FIELDS LIST SIZE : '+mergeFieldsList.size() +  ' ORIGINAL SIZE : '+ mergeDoc.mergeFields.size() + ' \n'  );
	        
	        System.assert(mergeFieldsList.size()==mergeDoc.mergeFields.size(), 
	                    'mergeFields must have the equal count');
	
	        controller.previous();
	        String buttonLabel = controller.createDocumentButtonLabel; 
	        controller.step1();
	        controller.getAttentionIndex();
	        controller.getContactOptions();
	        controller.getContactSelectOptions();
	        controller.getDisplayContactDropdown();
	        controller.getFaxNumberIndex();
	        controller.getRecipientIndex();
	        controller.getDisplayMessages();
	        controller.setMailMergeStatus(controller.getMailMergeStatus());
	        controller.getMailMergeStatusMessage();
	        controller.getMailMergeStatusTitle();
	        //controller.step2();
	        //controller.previous();
	        //controller.step2(); 
	         
	        //Boolean isDisabled= controller.stepNextDisabled;
	        //String jobKey = controller.MailMergeJobKey;
	        //mergeDoc.save(true);
	        //mergeDoc.setRequireSystemDocUI(mergeDoc.getRequireSystemDocUI());
	        //mergeDoc.load();
	        //List<SCM_MergeField> recipientInfoList = controller.mergeRecipientInfo;
	        //List<SCM_MergeField> mergeFields = controller.mergeFields;
	            
	        System.debug('\n Starting Recipient Field Values \n'  );
	        //controller.step3();
	        //jobKey = controller.MailMergeJobKey;
	        //mergeDoc.load(); 
	        //mergedoc.getLatestValues();
	        //mergedoc.printValues();
	        //mergeDoc.checkRequiredFields();
	        try
	        {
	        	controller.checkMailMergeJob();
	        	
	        }
	        catch(Exception exp)
	        {
	        }
	        
	        try
	        {
	        	controller.checkMailMergeJob();
	        	
	        }
	        catch(Exception exp)
	        {
	        }
 
    }
    
    
    
    public static testMethod void  testControllerWithCaseSystemDocument()
    {   
             
        SCM_MergeDocumentFactory.createMergeDocument(null, null, null); 
        SCM_MergePageController controller = new SCM_MergePageController();
        //controller.initialize();
       // String currentVS = controller.viewState; 
        Boolean next = controller.stepNextDisabled;
        List<SCM_Merge_Document__c>docs=[Select Label__c,Merge_Class_Name__c,Metadata_Key__c,
        										Product__c, Id 
										 from SCM_Merge_Document__c 
										 where Product__c='Lucentis' and Merge_Class_Name__c='SCM_MD_SMN_Lucentis'];
		
		String argLookupId='';
		for(SCM_Merge_Document__c doc:docs)
		{
			if(doc.Product__c=='Lucentis')
				argLookupId=doc.Id;
		}
        
        Case docCase = SCM_CreateTestData.CreateCase('GATCF - Standard Case','Lucentis');
        controller = new SCM_MergePageController();
        controller.initialize(docCase.Id, 'case');
        
        //controller.caseNumber = docCase.caseNumber;
        //controller.initialize();
        List<SCM_MergeField> fields= controller.mergeRecipientInfo;
        //controller.mergeRecipientInfo=fields;
        //fields= controller.mergeFields;
        //controller.mergeFields=fields; 
        List<SelectOption> docList= controller.docIdList;
        System.assert(docList.size()>0, 'No available documents are found!');
        Integer index = 0;
        Integer maxDocument = 2;
        for(SelectOption option: docList)
        {
            if(index>=maxDocument)
                break;
            SCM_Merge_Document__c doc =  docs[index];
            index++;
	        //[Select ID,Label__c,Merge_Class_Name__c,Metadata_Key__c from SCM_Merge_Document__c  where Id=:option.getValue()];
	        System.debug('\nCase Id :'+ docCase.Id +'\n'  );
	        System.debug('\nDocName :'+  doc.Label__c +'\n'  );
	        System.debug('\nClassName :'+  doc.Merge_Class_Name__c +'\n'  );
	        System.debug('\nMetadata_Key :'+  doc.Metadata_Key__c +'\n'  );
	         
	        controller.selectedSCMMergeDocumentID =doc.Id;
	        next = controller.stepNextDisabled;
	         
	        controller.SCMMergeDocument=null; 
	        SCM_Merge_Document__c mergeDocument = controller.SCMMergeDocument;
	        List<SelectOption> optionList= controller.docIdList;
	        controller.docIdList=optionList;
	         
	        SCM_MergeDocument mergeDoc = controller.getMergeDoc();
	        String buttonLabel = controller.createDocumentButtonLabel; 
	        //controller.setMergeRecipientInfo(mergeDoc.mergeRecipientInfo);
	        //controller.setMergeFields(mergeDoc.mergeFields);
	        System.debug('\nController objectId : ' + controller.objectId + '\n'  );
	        
	        if(mergeDoc==null)
	        	continue;
	       // System.assert(mergeDoc!=null, 'Merge Document cannot be null!'); 

	        
	        fields= controller.mergeRecipientInfo;
	        controller.mergeRecipientInfo=fields;
	        fields= controller.mergeFields;
	        controller.mergeFields=fields;
	        String tempCaseNumber = mergeDoc.selectedCase.CaseNumber; 
	        String mailMergeStatus = controller.getMailMergeStatus();
	        
	        String viewState = SCM_MergeDocumentCaching.createViewStateXML(mergeDoc.mergeFields);
	    
	        System.debug('\n Starting Merge Field Values \n'  );
	        List<SCM_MergeField> mergeFieldsList = SCM_MergeDocumentCaching.getSectionMergeFields(viewState,'MergeFields');
	        System.debug('\n MERGE FIELDS LIST SIZE : '+mergeFieldsList.size() +  ' ORIGINAL SIZE : '+ mergeDoc.mergeFields.size() + ' \n'  );
	        
	        System.assert(mergeFieldsList.size()==mergeDoc.mergeFields.size(), 
	                    'mergeFields must have the equal count');
	 
	  		//controller.createSystemDocument(); 
	        try
	        {
	        	controller.checkMailMergeJob();
	        	
	        }
	        catch(Exception exp)
	        {
	        }
	        
	        try
	        { 
	        	controller.checkMailMergeJob();
	        	
	        }
	        catch(Exception exp)
	        {
	        }
 			
        }
    }
    
     
  /*  
    public static testMethod void  testController2()
    {   
         
        SCM_MergeDocumentFactory.createMergeDocument(null, null, null); 
        SCM_MergePageController controller = new SCM_MergePageController();
        //controller.initialize();
       // String currentVS = controller.viewState; 
        Boolean next = controller.stepNextDisabled;
        
 
         
        Case docCase = [Select Id, CaseNumber, RecordType.Name, Product_gne__c FROM Case WHERE Product_gne__c='Lucentis' LIMIT 1][0];
        controller.initialize(docCase.Id, 'case');
        controller = new SCM_MergePageController();
        controller.objectId = docCase.Id;
        controller.initializeSystemDoc();
        controller.mergeDocCreated = false;
        List<SCM_MergeField> fields= controller.mergeRecipientInfo;
        controller.mergeRecipientInfo=fields;
        List<SCM_Merge_Document__c> docList= [SELECT Id , Label__c ,  Metadata_Key__c,Merge_Class_Name__c
                                         FROM SCM_Merge_Document__c 
                                         WHERE Case_Type_Name__c=:docCase.RecordType.Name and 
                                               Product__c = :docCase.Product_gne__c 
                                               and  Document_Type__c = 'System Document'
                                                ];
        System.assert(docList.size()>0, 'No available documents are found!');
        Integer index = 0;
        Integer maxDocument = 2;
        for(SCM_Merge_Document__c doc: docList)
        {
            if(index>=maxDocument)
                break;
            index++;
        System.debug('\nCase Id :'+ docCase.Id +'\n'  );
        System.debug('\nDocName :'+  doc.Label__c +'\n'  );
        System.debug('\nClassName :'+  doc.Merge_Class_Name__c +'\n'  );
        System.debug('\nMetadata_Key :'+  doc.Metadata_Key__c +'\n'  );
        
        controller.selectedSCMMergeDocumentID =doc.Id;
        next = controller.stepNextDisabled;
          
        controller.SCMMergeDocument=null; 
        SCM_Merge_Document__c mergeDocument = controller.SCMMergeDocument;
        List<SelectOption> optionList= controller.docIdList;
        controller.docIdList=optionList;
  
        System.debug('\nController objectId : ' + controller.objectId + '\n'  );
        
        controller.createSystemDocument();
        SCM_MergeDocument mergeDoc = controller.getMergeDoc();
        System.assert(mergeDoc!=null, 'Merge Document cannot be null!'); 
        
        fields= controller.mergeRecipientInfo;
        controller.mergeRecipientInfo=fields;
        fields= controller.mergeFields;
        controller.mergeFields=fields;
        String tempCaseNumber = mergeDoc.selectedCase.CaseNumber;
        controller.checkMailMergeJob();   
                
        }
    }
    */
}