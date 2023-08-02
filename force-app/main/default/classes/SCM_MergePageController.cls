public class SCM_MergePageController {
  
    private final String docTypeFaxCover = 'Fax Cover Sheet';
    private final String docTypeSystemDocument  = 'System Document';
    
    public Integer totalSteps{get;set;}
    public Integer currentStep{get; set;}
    public String wizardType{get; set;}
    private Boolean initialized = false;
    
    private SCM_FaxSender_WebService.MergeJobStatus jobStatus;
    public Boolean mergeDocCreated{ get; set;}
    public List<SelectOption> docIdList{get; set;}
    private string selmdid ;
    private boolean setid = false;
    public String selectedSCMMergeDocumentID {
    
        get {
            if (setid){
            return  selectedSCMMergeDocumentID;
            }
        if (setid == false) {
            setid = true;
                selmdid = selectedSCMMergeDocumentID;
            setid = false;
            }
                
            
            
            string tst = '';
            tst =  selmdid.split(';')[0];
            return tst;
            }
             
        set {selectedSCMMergeDocumentID = value;}} 
    
    
    public String objectNumber {get;set;}
    public String objectId {get;set;}
    public String objectType {get; set;}
    
    private SCM_Merge_Document__c mergeDocumentRecord=null;
    
   public string xml {
    get {
    return  mergeDoc.setXMLExcapeCharacters(mergeDoc.getXMLString());
    }
    set{
    xml = value;    
    }
   }
      public string Username {
    get {return SCM_Security.getEnvironmentVariable('SCM_Username');}
    set{Username = value;}
   }
    
     public string password {
    get {return SCM_Security.getEnvironmentVariable('SCM_Password');}
    set{password = value;}
   }
      public string acctid {
    get {return SCM_Security.getEnvironmentVariable('SCM_AccountID');}
    set{acctid = value;}
   }
       public string springendpoint {
    get {return SCM_Security.getEnvironmentVariable('SCM_WebserviceURL');}
    set{springendpoint = value;}
   }
        public string solendpoint {
    get {return SCM_Security.getEnvironmentVariable('SCM_URL');}
    set{solendpoint = value;}
   }
       public string orgid {
    get {return UserInfo.getorganizationid();}
    set{orgid = value;}
       }
        public string Product {
    get {return mergedoc.selectedProduct;}
    set{Product = value;}
        }
       public string CaseNumber {
    get {return mergedoc.selectedObjectNumber;}
    set{CaseNumber = value;}
       }
           public string CaseID {
    get {return mergedoc.selectedObjectId;}
    set{CaseID = value;}
           }
      public string DocName {
    get {return mergedoc.sfDocumentRecord.Name;}
    set{DocName = value;}
           }
        public string MetaDataKey {
    get {return mergedoc.sfDocumentRecord.Metadata_Key__c;}
    set{DocName = MetaDataKey;}
           }
   
    public String createDocumentButtonLabel
    {
        get
        {
            if(wizardType=='System Document')
                return 'Create System Document';
            else
                return 'Create Fax Cover';
        }
    }

    public Boolean getDisplayMessages()
    {
        String orgId = UserInfo.getOrganizationId();
        return orgId== '00DS0000000CzhfMAC';
    }

    
    
    
   // public String htmlTest{ get{ return '<span id="theText" style="font-style:italic">This is my text with <b>style</b>.</span> and this is without style';} set;}

    public Boolean stepNextDisabled 
    {
        get
        {
            if(docIdList!=null && docIdList.size()==0)
                return true;
            else if(ApexPages.hasMessages(ApexPages.Severity.ERROR) || 
                    ApexPages.hasMessages(ApexPages.Severity.FATAL))
                return true;
            else
                return false;
        } 
    } 
    
    private SCM_MergeDocument mergeDoc;
    public SCM_MergeDocument getMergeDoc()
    {
        return mergeDoc;  
    }
    
    private void createMergeDoc()
    {
        try 
        {
            if(objectID==null || objectID=='' || 
               selectedSCMMergeDocumentID==null || selectedSCMMergeDocumentID=='')
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                                                   'objectID or selectedSCMMergeDocumentID can not be null beforce creating SCM_MergeDocument!'));
                mergeDoc=null;
            }
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 
                                                   'CreateMergeDoc -> SelectedSCMMergeDocumentID : ' + selectedSCMMergeDocumentID ));
            String className = null;
            List<SCM_Merge_Document__c> mergeDocList=[Select Case_Type_Name__c, Label__c,Merge_Class_Name__c, Product__c , Metadata_Key__c 
                                From SCM_Merge_Document__c 
                                Where Id=:selectedSCMMergeDocumentID limit 1];
            if(mergeDocList.size()>0)
                className=mergeDocList[0].Merge_Class_Name__c;
                
            if(className!=null)
            {  
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 
                                                   'CreateMergeDoc -> ClassName : ' + className ));
                ApexPages.Message myMsg1 = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Class Name : ' + className + ' Object ID: ' + objectID + ' DocumentId :' + selectedSCMMergeDocumentID);
                ApexPages.addMessage(myMsg1);
                mergeDoc = SCM_MergeDocumentFactory.createMergeDocument(className, objectID,selectedSCMMergeDocumentID);
                if(mergeDoc==null)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Merge Document could not be created! Please check if the instantiation statement exists in SCM_MergeDocumentFactory!'));
                }
                 
                return;
            }
            else
            {
                mergeDoc=null;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Merge Document class name can not be null!'));
                //return null;
            }
            
        }
        catch(Exception exp)
        {
            mergeDoc=null;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'CreateMergeDoc :' + exp.getMessage()));            
        }
        
    }        
   // public String getXMLString() 
   //{ 
   //   return mergeDoc.getXMLString();
   //}
    
    
    public SCM_Merge_Document__c SCMMergeDocument
    {
        get
        {
            if(SCMMergeDocument==null)
                SCMMergeDocument= [select Id ,Case_Type_Name__c, 
                                          Label__c, Merge_Class_Name__c,
                                        Product__c, Metadata_Key__c 
                                   from SCM_Merge_Document__c 
                                   where Id=:selectedSCMMergeDocumentID];                               
            return SCMMergeDocument;
        }
        set;                                       
    }
    
    public List<SCM_MergeField> mergeRecipientInfo
    {
        get
        {
            if(mergeDoc!=null && mergeDoc.mergeRecipientInfo!=null)
                return mergeDoc.mergeRecipientInfo;
            else
                return new List<SCM_MergeField>();
        }
        set
        {
            if(mergeDoc!=null)
                mergeDoc.mergeRecipientInfo=value;
        }  
    }

    public List<SCM_MergeField> mergeFields
    {
        get
        {
            if(mergeDoc!=null && mergeDoc.mergeFields!=null)
                return mergeDoc.mergeFields;
            else
                return new List<SCM_MergeField>();
        }
        set
        {
            if(mergeDoc!=null)
                mergeDoc.mergeFields=value;
        }  
    }    

    public String selectedContact{get;  set;}
    public List<SCM_ContactInfo> getContactOptions()
    {
        return mergeDoc.getContactOptions();
    }
    
    List<SelectOption> options = new List<SelectOption>();
    public List<SelectOption> getContactSelectOptions()
    {
        options.clear();
        for(SCM_ContactInfo contact: mergeDoc.getContactOptions())
        {
            options.add(new SelectOption(contact.faxNumber,contact.attention));
        }
        return options;
    }
    
    public Boolean getDisplayContactDropdown()
    {
        return mergeDoc.displayContactDropdown;
    }
    
    public Integer getFaxNumberIndex()
    {
        return mergeDoc.getIndexInMergeFieldList('RECFAX_', mergeDoc.mergeRecipientInfo);
    }
    
    public Integer getRecipientIndex()
    {
        return mergeDoc.getIndexInMergeFieldList('RECNAME_', mergeDoc.mergeRecipientInfo);
    }
      
    public Integer getAttentionIndex()
    {
        return mergeDoc.getIndexInMergeFieldList('ATTN_', mergeDoc.mergeRecipientInfo);
    }

    private void initializeDocIdList_Case(Case docCase)
    {
            docIdList =  new List<SelectOption>();
            String caseTypeId=docCase.RecordTypeId;
            String productId= docCase.Product_gne__c;
            String caseTypeName = [Select Name From RecordType where Id=:caseTypeId].Name;
            for(SCM_Merge_Document__c doc : [select Id , Label__c ,Metadata_Key__c,Require_UI_SystemDoc__c
                                             from SCM_Merge_Document__c 
                                             where Document_Type__c=:wizardType and 
                                                   Case_Type_Name__c=:caseTypeName and 
                                                   Product__c = :productId and Case_Document__c=true
                                             Order by Label__c])
            {
                docIdList.add(new SelectOption(doc.Id + ';' + doc.Require_UI_SystemDoc__c, doc.Label__c));
            }    
    }
    
    private void initializeDocIdList_Hotline(Hotline_gne__c selectedHotline)
    {	   String caseTypeId=selectedHotline.RecordTypeId;
            docIdList =  new List<SelectOption>();
            String caseTypeName = 'Call';
            try{
            	caseTypeName = [Select Name From RecordType where Id=:caseTypeId].Name;
            }
            catch(exception e){
            	system.debug('no record type found using default.')	;
            }
           if (CaseTypeName == Null || CaseTypeName == ''){
           	CaseTypeName = 'Call';
           }
            for(SCM_Merge_Document__c doc : [select Id , Label__c ,Metadata_Key__c, Product__c
                                             from SCM_Merge_Document__c 
                                             where Hotline_Document__c=true and Case_Type_Name__c=:caseTypeName and Document_Type__c=:wizardType 
                                             Order by Label__c])
            {
                if(selectedHotline!=null && selectedHotline.Product_gne__c!=null)
                {
                    if(selectedHotline.Product_gne__c=='Rituxan RA') 
                    {
                        if(selectedHotline.Product_gne__c==doc.Product__c)
                            docIdList.add(new SelectOption(doc.Id, doc.Label__c));
                    }
                    else if(selectedHotline.Product_gne__c=='Rituxan')
                    { 
                        if(selectedHotline.Product_gne__c==doc.Product__c)
                            docIdList.add(new SelectOption(doc.Id, doc.Label__c));
                    }
                    else if(selectedHotline.Product_gne__c.contains(doc.Product__c))
                        docIdList.add(new SelectOption(doc.Id, doc.Label__c));
                }
                else
                    docIdList.add(new SelectOption(doc.Id, doc.Label__c));
            }    
    }
    
    
    private String mailMergeStatus='';
    public String getMailMergeStatus()
    {
        return mailMergeStatus;
    }
    public void setMailMergeStatus(String val)
    {
        //mailMergeStatus=val;
    }

    public String mailMergeJobKey 
    {
        get
        { 
            //if(mergeDoc!=null && mergeDoc.mailMergeJobKey!=null && )
               // return mergeDoc.mailMergeJobKey;
               return apexpages.currentpage().getParameters().get('Jobkey');
            //else
              //  return ''; 
        } 
        set;
    }
     
    
    private void printValues()
    {
        try
        {
            for(SCM_MergeField mField:mergeDoc.mergeRecipientInfo)
            {
                String message='RecipientInfo -> ';
                if(mField.key!=null)
                    message +=' Key : '+ mField.key;
                if(mField.getMergeValue()!=null)
                    message += ' MergeValue :' + mField.getMergeValue();
                if(mField.className!=null)
                    message +=' ClassName : ' + mField.className;  
                    
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,  message));
            }   
            for(SCM_MergeField mField:mergeDoc.mergeFields)
            { 
                String message='MergeFields -> ';
                if(mField.key!=null)
                    message +=' Key : ' +mField.key;
                if(mField.getMergeValue()!=null)
                    message += ' MergeValue :' + mField.getMergeValue();
                if(mField.className!=null)
                    message +=' ClassName : ' + mField.className;           
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
            }
            
            for(SCM_MergeImage mImage:mergeDoc.mergeImages)
            { 
                String message='MergeImages -> ';
                if(mImage.key!=null)
                    message +=' Key : ' +mImage.key;
                if(mImage.getValue()!=null)
                    message += ' ImageValue :' + mImage.getValue();         
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
            }       
            
            for(SCM_MergeSection mSection:mergeDoc.mergeSections)
            { 
                String message='MergeSections -> ';
                if(mSection.key!=null)
                    message +=' Key : ' +mSection.key;
                if(mSection.visible!=null)
                    message += ' Visible :' + mSection.visible;         
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
            }           
        }
        catch(Exception exp)
        {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Exception while printing collection values -> Message : ' + exp.getMessage()));
        }
    }
    
    /********************************************************************/
    // Function Name    : sendError
    
    // Argument         : 
    // Return Type      : 
    // Description      : This function sends the error email. It is called 
    //                    whenever an error occurs in the code. 
    /********************************************************************/ 
    private String sendErrorEmail()
    { 
      try {
        // Specify the text content of the email.
        SCM_Mail_Merge_Log__c log=new SCM_Mail_Merge_Log__c();
        
        log.User__c= UserInfo.getUserId();
        
        if(objectType!=null && 
           objectType.equalsIgnoreCase('case'))
        {
            log.Object_Type__c='Case';
            log.Case__c=objectId;
        }
        else if(objectType!=null && 
                objectType.equalsIgnoreCase('hotline'))
        {
            log.Object_Type__c='Hotline';
            log.Hotline__c=objectId;
        }
        log.Object_Id__c=objectId;
        String mailBody = ' Following Errors Occurred in Mail Merge Wizard\n';
        mailBody += '   Object Type : ' + objectType + '\n';
        mailBody += '   Object Id : ' + objectId + '\n';
        if(mergeDoc!=null)
        {
            mailBody += '     Number : ' + mergeDoc.selectedObjectNumber + '\n';
        }
        if(selectedSCMMergeDocumentID!=null && selectedSCMMergeDocumentID!='')
        {
            SCM_Merge_Document__c mergeDocument = null;
            if(mergeDoc!=null && mergeDoc.sfDocumentRecord!=null)
                mergeDocument = mergeDoc.sfDocumentRecord;
            else
            {
                if(selectedSCMMergeDocumentID!=null)
                {
                    List<SCM_Merge_Document__c> docs=[Select s.Document_Type__c, s.Label__c, 
                                                             s.Merge_Class_Name__c, s.Metadata_Key__c, s.Product__c 
                                                      from SCM_Merge_Document__c s 
                                                      where Id=:selectedSCMMergeDocumentID
                                                      limit 1];
                    if(docs.size()>0)
                        mergeDocument=docs[0];
                }
            }

            if(mergeDocument!=null)
            {
                log.SCM_Merge_Document__c=mergeDocument.Id;
                log.Document_Type__c=mergeDocument.Document_Type__c;
                log.Document_Name__c=mergeDocument.Label__c ;
                log.Class_Name__c=mergeDocument.Merge_Class_Name__c;
                mailBody += '   Document Type : ' + mergeDocument.Document_Type__c + '\n';
                mailBody += '   Document Name : ' + mergeDocument.Label__c + '\n'; 
                mailBody += '      Class Name : ' + mergeDocument.Merge_Class_Name__c + '\n';
            }
        }
        mailBody += '\n     APEX CODE MESSAGES\n\n';    
        for(ApexPages.Message msg :ApexPages.getMessages())
        {
            mailBody += '   * Severity : ' + msg.getSeverity() + '\n    Summary : ' + msg.getSummary() + '\n';
            mailBody += '\n';           
        } 
        
        try
        {
            log.Log__c=mailBody;
            insert log;
        }
        catch(Exception exp)
        {
            System.debug('Exception while logging the message : ' + exp.getMessage());
        }
        
        if(SCM_Security.SendExceptionEmail) {
            try {
                if(Limits.getEmailInvocations()<Limits.getLimitEmailInvocations()) {
                    SCM_LogError.sendEmail('Mail Merge Code Error!',mailBody,true);
                }
            }
            catch(Exception exp)
            {
                System.debug('Exception while sending email : ' + exp.getMessage());
                
            }
        }
        
        return mailBody;
      }catch(Exception exp3454)
        {
            return '';
            //System.debug('Exception while sending email : ' + exp3454.getMessage());
            
        }
    }
    
    
    private void populateDocumentDropdown()
    {
            if(ApexPages.currentPage()!=null)
            {
                if(ApexPages.currentPage().getParameters().get('objectid')!=null)
                    objectID = ApexPages.currentPage().getParameters().get('objectid');
            
                if(ApexPages.currentPage().getParameters().get('type')!=null)
                    objectType = ApexPages.currentPage().getParameters().get('type');

                if(ApexPages.currentPage().getParameters().get('wizard')!=null)
                {
                    String wizard = ApexPages.currentPage().getParameters().get('wizard');
                    if(wizard.equalsIgnoreCase('1'))
                        wizardType = docTypeFaxCover;
                    else if(wizard.equalsIgnoreCase('2'))
                        wizardType = docTypeSystemDocument;
                    else
                        wizardType = docTypeFaxCover;
                }
            }
            
            if(objectType.equalsIgnoreCase('case'))
            {
                Case docCase=null;
                try
                {
                    List<Case> caseList = [Select Id, CaseNumber, RecordTypeId, Product_gne__c FROM Case WHERE id=:objectID];
                    if(caseList.size()>0)
                        docCase=caseList[0];
                }
                catch(Exception exp)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Exception in Initialize SCM_MergePageController. ' +
                                                                                     'Exception Message :' + exp.getMessage()));
                }
                if(docCase!=null) 
                    initializeDocIdList_Case(docCase); 
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Object cannot be null!'));
            }
            
            else if(objectType.equalsIgnoreCase('hotline'))
            {
                
                
                Hotline_gne__c docHotline=null;
                try
                {
                    List<Hotline_gne__c> hotlineList = [Select Id, Name,Product_gne__c, Drug_Type_gne__c,RecordTypeId FROM Hotline_gne__c WHERE id=:objectID];
                    if(hotlineList.size()>0)
                        docHotline=hotlineList[0];
                }
                catch(Exception exp)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Exception in Initialize SCM_MergePageController. ' +
                                                                                     'Exception Message :' + exp.getMessage()));
                }
                if(docHotline!=null) 
                    initializeDocIdList_Hotline(docHotline); 
                else
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Object cannot be null!'));
                
                
                 
            }
    }
    
    
    /********************************************************************/
    // Function Name    : initialize
    // Argument         : String caseNum
    // Return Type      : PageReference
    // Description      : This function initializes the process by populating 
    //                    the available documents for that case
    /********************************************************************/ 
    public PageReference initialize()
    {  
        try
        {
        if(!initialized)
        {
            currentStep=1;
            wizardType = docTypeFaxCover;
            mergeDocCreated= false;
            selectedSCMMergeDocumentID='';
            populateDocumentDropdown();
            initialized = true;
        }
        }
        catch(Exception exp)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Exception in Initialize SCM_MergePageController. ' +
                                                                                     'Exception Message :' + exp.getMessage()));
        }
        if(ApexPages.hasMessages(ApexPages.Severity.ERROR) ||
           ApexPages.hasMessages(ApexPages.Severity.FATAL))
                    sendErrorEmail();
               
        return null;
    }
    
     /********************************************************************/
    // Function Name    : initializeSystemDoc
    // Argument         : 
    // Return Type      : PageReference
    // Description      : This function initializes the 'Create System Document' process by populating 
    //                    the available documents for that case
    /********************************************************************/    
   /* public PageReference initializeSystemDoc()
    {  
        if(!initialized)
        {
            currentStep=1;
            wizardType = docTypeSystemDocument;
            mergeDocCreated= false;
            selectedSCMMergeDocumentID='';
            populateDocumentDropdown();
                
            initialized = true;
        }
        return null;
    }*/
    
    public PageReference initialize(String objId, String objType)
    {  
        if(!initialized)
        {
            mergeDocCreated= false;
            selectedSCMMergeDocumentID='';
            objectId = objId;
            objectType = objType;
            wizardType = docTypeFaxCover;
            populateDocumentDropdown();
            if(objectType.equalsIgnoreCase('case'))
            {
                Case docCase = null;
                
                List<Case> caseList=[select Id, CaseNumber, RecordTypeId, Product_gne__c 
                                from Case 
                                where Id=:objectId];
                if(caseList.size()>0)
                    docCase=caseList[0];
                if(docCase!=null)
                {   
                    objectNumber = docCase.CaseNumber;
                    initializeDocIdList_Case(docCase); 
                } 
            }
            else if(objectType.equalsIgnoreCase('hotline'))
            {
                Hotline_gne__c docHotline = null;
                List<Hotline_gne__c> hotlineList = [Select Id, Name,Product_gne__c, Drug_Type_gne__c,RecordTypeId FROM Hotline_gne__c WHERE id=:objectID];
                if(hotlineList.size()>0)
                    docHotline=hotlineList[0];
                if(docHotline!=null)
                {   
                    objectNumber = docHotline.Name;
                    initializeDocIdList_Hotline(docHotline); 
                }
                initializeDocIdList_Hotline(null);
            }
            initialized = true;
        }   
        return null;
    }

    /********************************************************************/
    // Function Name    : previous
    // Argument         : 
    // Return Type      : PageReference
    // Description      : This function is called from the wizard pages and it redirects
    //                    the user to the previous page in the process
    /********************************************************************/ 
    public PageReference previous()
    {
        if(currentStep==2)
        {
            currentStep=1;
            mergeDocCreated=false;
           
            return Page.SCM_Fax_Cover_Step1;
            
        } 
        else if(currentStep==3)
        {
            currentStep=2;
            return Page.SCM_Fax_Cover_Step2;
        }
        else
            return Page.SCM_Fax_Cover_Step1;
    } 
    
    /********************************************************************/
    // Function Name    : checkMailMergeJob
    // Argument         : 
    // Return Type      : PageReference
    // Description      : This function is called from the poller page and it
    //                    checks the current mail merge job status
    /********************************************************************/ 
    private Boolean mailMergeJobCreated=true;
    private String mailMergeStatusMessage='The document is being created...';
    public String getMailMergeStatusMessage()
    {
        return mailMergeStatusMessage;
    }
    private String mailMergeStatusTitle='Processing...';
    public String getMailMergeStatusTitle()
    {
        return mailMergeStatusTitle;
    }
    public PageReference checkMailMergeJob() 
    {

        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 
                                            'Checking Mail Merge Job... MergeDocCreate :' + mergeDocCreated));  
        if(mergeDoc!=null)
        {
            
        
            if(!mailMergeJobCreated)
            {
                
                if(wizardType==docTypeSystemDocument)
                {
                     //mergeDocCreated = !mergeDocCreated;
                     //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 
                        //                  'MergeDoc created!'));            
                //    mailMergeJobKey = mergeDoc.createMergedDocument();
                  //  if(mailMergeJobKey!=null || mailMergeJobKey!='')
                    //  mailMergeJobCreated=true;
                    //if(!ApexPages.hasMessages(ApexPages.Severity.ERROR) && 
                    //      !ApexPages.hasMessages(ApexPages.Severity.FATAL) && mailMergeJobKey!=null)                          
                }
                else
                {
                    //mailMergeJobCreated=createMailMergeJob();
                    //mailMergeJobKey = mergeDoc.MailMergeJobKey;
                }
            }
            
            if(mailMergeJobKey!=null && mailMergeJobKey!='') {
                        mailMergeJobCreated=true;
            }
          /*
            if (mailMergeJobKey==null || mailMergeJobKey=='') {
                jobstatus=new SCM_FaxSender_WebService.MergeJobStatus();
                jobstatus.Status='Failed';
                jobstatus.Error= 'There was an internal error.';
                mailMergeStatus=jobStatus.status;
                SCM_logerror.sendEmail('There was an error with the merge document wizard', 'The job key was null for the mail merge poll page', true);
                        mailMergeStatusMessage='Error occurred during document creation!';
        return new PageReference(Page.SCM_Fax_Cover_Step4.getURL() + '?wizard_error=true');       
           
                
            }
            */   
                    
                    
            if(!ApexPages.hasMessages(ApexPages.Severity.ERROR) && 
                    !ApexPages.hasMessages(ApexPages.Severity.FATAL) && mailMergeJobKey!=null)                          
            {
                jobstatus=new SCM_FaxSender_WebService.MergeJobStatus();
                jobstatus.Status='Failed';
                for(ApexPages.Message msg :ApexPages.getMessages())
                {
                    if(msg.getSeverity()==ApexPages.Severity.ERROR || 
                       msg.getSeverity()==ApexPages.Severity.FATAL)
                    {
                        jobstatus.Error= 'Severity : ' + msg.getSeverity() + ' Summary : ' + msg.getSummary();           
                        break;
                    }
                }    
            }
            
            if(mailMergeJobCreated && !(mailMergeStatus=='Failed' || mailMergeStatus=='Success'))
            {try {
                jobStatus = mergeDoc.checkMailMergeJob();
            
          
                mailMergeStatus=jobStatus.status;
            }catch (exception ex){
            
            }
                //if(mailMergeStatus=='Failed')
                    
                if(mailMergeStatus=='Failed')
                {
                    if (jobStatus.Error.contains('The document is taking longer to create')) {
                    mailMergeStatusMessage = jobStatus.Error;
                    
                }else {
                    mailMergeStatusMessage = 'Document creation failed! Error Message : ' + jobStatus.Error;
                }
                    mailMergeStatusTitle='Result';
                }
                else if(mailMergeStatus=='Success')
                {
                    mailMergeStatusMessage = 'Document created successfully!';
                    mailMergeStatusTitle='Result';
                }
            }
       
        }
        else  
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,
                                 'SCM_MergeDocument cannot be null! Please try again!'));
        }

        if(ApexPages.hasMessages(ApexPages.Severity.ERROR) ||
               ApexPages.hasMessages(ApexPages.Severity.FATAL))
               {
                    sendErrorEmail();
               }
        return null;
        
    }

       /********************************************************************/
    // Function Name    : step1
    // Argument         : 
    // Return Type      : PageReference
    // Description      : This function is called from the SCM_Fax_Cover_Step1 page when
    //                    next button is clicked. It gets the selected document and 
    //                    creates the field values by instantiating the related 
    //                    SCM_MergeDocument subclass then redirects the wizard to 
    //                    SCM_Fax_Cover_Step2 page.
    /********************************************************************/ 
    public PageReference step1()
    {
        currentStep=2;
        totalSteps=3;    
        try
        {
            if(!mergeDocCreated)
            {
                createMergeDoc();
                mergeDocCreated = true;
           } 
            printValues();
            if(mergeDoc!=null)
            {  
                if(mergeDoc.mergeRecipientInfo==null || mergeDoc.mergeRecipientInfo.size()==0)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No recipient info merge field could be found!'));
                if(mergeDoc.mergeFields==null)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'SCM_MergeDocument.mergeFields cannot be null!'));

                mergeDoc.load();
            }
            if(!ApexPages.hasMessages(ApexPages.Severity.ERROR) && 
               !ApexPages.hasMessages(ApexPages.Severity.FATAL))
               {
                    printValues();
                    Integer currentQueryCount = Limits.getQueries();
                    Integer currentQueryLimit = Limits.getLimitQueries();
                    Integer availableQueries = currentQueryLimit - currentQueryCount;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 
                                         'Query Limit :' + currentQueryLimit +
                                         ' Issued Query : '+ currentQueryCount + 
                                         ' Available Queries : ' + availableQueries));
                    if(mergeDoc.mergeFields.size()==0)
                        totalSteps = 2;
                    
                    if(wizardType==docTypeFaxCover)
                        return Page.SCM_Fax_Cover_Step2;
                    else if(wizardType==docTypeSystemDocument)
                    {
                        if(!mergeDoc.getRequireSystemDocUI()) {
                            printValues();  
                            mergeDocCreated = !mergeDocCreated;    
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, mergeDoc.getXMLString()));
      // if(mergeDoc.checkRequiredFields() && ) 
      
       mailMergeJobKey = mergeDoc.createMergedDocument();
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, mergeDoc.getXMLString()));
       string loc = SCM_Security.getEnvironmentVariable('SCM_URL');
        	loc = loc.replace('FaxSender.asmx','');
         return new PageReference(loc + 'MergeDocumentPoll.aspx' + '?Jobkey=' + mergeDoc.mailMergeJobKey + '&redir=https://' + ApexPages.currentPage().getHeaders().get('Host') + Page.SCM_OpenerRefresh.getURL() ); //Page.SCM_Mail_Merge_Poll.getURL() 
                        }
                        else
                        {
                            totalSteps=2;
                            currentStep=2;
                            return Page.SCM_Fax_Cover_Step3;
                        }
                    }
                        
               }
        }
        catch(Exception exp)
        {
            System.debug('EXCEPTION in Step 1 : ' + exp.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Step1 ' + exp.getMessage()));            
        }
        sendErrorEmail(); 
        //return null;
        mailMergeStatusMessage='Error occurred during document creation!';
        return new PageReference(Page.SCM_Fax_Cover_Step4.getURL() + '?wizard_error=true');       
    }
   
   /********************************************************************/
    // Function Name    : step2
    // Argument         : 
    // Return Type      : PageReference
    // Description      : This function is called from the SCM_Fax_Cover_Step2 page when
    //                    next button is clicked and it redirects the wizard to 
    //                    SCM_Fax_Cover_Step3 page.
    /********************************************************************/   
    public PageReference step2()
    {
        try
        {
            currentStep=3;
            printValues();
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, mergeDoc.getXMLString()));
            
            if(!ApexPages.hasMessages(ApexPages.Severity.ERROR) && 
               !ApexPages.hasMessages(ApexPages.Severity.FATAL))
               {
                    if(mergeDoc.mergeFields.size()==0)
                        return step3();
                    else
                        return Page.SCM_Fax_Cover_Step3;
               }
           
        }   
        catch(Exception exp)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Step2 ' + exp.getMessage()));           
        }
        sendErrorEmail();
        mailMergeStatusMessage='Error occurred during document creation!';
        return new PageReference(Page.SCM_Fax_Cover_Step4.getURL() + '?wizard_error=true');        
    }
    
    /********************************************************************/
    // Function Name    : step3
    // Argument         : 
    // Return Type      : PageReference
    // Description      : This function is called from the SCM_Fax_Cover_Step3 page when
    //                    next button is clicked. It calls the createMergedDocument method of mergeDoc
    //                    and redirects the SCM_Mail_Merge_Poll page.
    /********************************************************************/ 

  

    public PageReference step3()
    {
        printValues();      
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, mergeDoc.getXMLString()));
      // if(mergeDoc.checkRequiredFields() && ) 

       string jk = mergeDoc.createMergedDocument();

       if (jk ==null || jk=='') {
        sendErrorEmail();
        if(SCM_Security.SendExceptionEmail) {
            SCM_logerror.sendEmail('There was an error with the merge document wizard', 'The job key was null for the mail merge poll page', true);
        }

        mailMergeStatusMessage='Error occurred during document creation!';
        return new PageReference(Page.SCM_Fax_Cover_Step4.getURL() + '?wizard_error=true');
       }
        mergeDoc.save(true);
         string loc = SCM_Security.getEnvironmentVariable('SCM_URL');
        	loc = loc.replace('FaxSender.asmx','');
         return new PageReference(loc + 'MergeDocumentPoll.aspx' + '?Jobkey=' + mergeDoc.mailMergeJobKey + '&redir=https://' + ApexPages.currentPage().getHeaders().get('Host') + Page.SCM_OpenerRefresh.getURL() );
    }

   
   
   public PageReference clickOK()
   {
        if(mailMergeStatus!=null && 
           mailMergeStatus=='Success' && 
           mergeDoc!=null)
            mergeDoc.save(true);
            
        return null;
   }
   
   
   private Boolean createMailMergeJob()
   {
        try
        {         
            mailMergeJobKey =mergeDoc.createMergedDocument();
            if(mailMergeJobKey==null)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'MailMergeJobKey cannot be null!'));
 
            if(mailMergeJobKey.trim()=='')
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'MailMergeJobKey cannot be empty string!'));
            if(!ApexPages.hasMessages(ApexPages.Severity.ERROR) && 
               !ApexPages.hasMessages(ApexPages.Severity.FATAL)) 
               {
                    return true;
               }
        }
        catch(Exception exp)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Create Fax Cover : ' + exp.getMessage()));
        }

        sendErrorEmail();
        return false;
   }
   
}