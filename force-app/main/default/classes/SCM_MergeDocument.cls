public abstract class SCM_MergeDocument {
     
    // An interface that flags merge documents that need the standard combo box.
    public interface IStandardComboBox {
        // no methods needed
    } 
    
    
    
    /********************************************************************/
    // Public Properties
    // mergeRecipientInfo : List of merge fields that has recipient information like 
    //                      Name, Attention, Fax Number etc.
    // mergeFields        : List of all merge fields that is not related to fax recipient info.
    // mergeLookupID      : SF row ID of the SCM_MergeDocument__c object related to the document.
    // selectedCase       : SF Case with all necessary fields related to the document.  
    /********************************************************************/
    public SCM_MergeField[] mergeRecipientInfo{get;  set;}
    public SCM_MergeField[] mergeFields{get; set;}
    public SCM_MergeSection[] mergeSections{get; set;}
    public SCM_MergeImage[] mergeImages{get; set;}
    public SCM_MergeRepeater[] mergeRepeaters{get; set;}
    public String mergeLookupID{get; set;}
    public Case selectedCase {get; set;}
    public String mailMergeJobKey {get; set;}
    
    public String selectedObjectNumber{get; set;}
    public String selectedObjectId{get; set;} 
    public String selectedProduct{get; set;}   
    
    // This property is only used for system docs which 
    private Boolean requireSystemDocUI=false;
    public SCM_Merge_Document__c sfDocumentRecord=null;
    public Boolean getRequireSystemDocUI()
    { 
        return requireSystemDocUI;
    }
    public void setRequireSystemDocUI(Boolean value)
    {
        requireSystemDocUI = value;
    } 
   
    public virtual void getLatestValues(){}
    public Boolean displayContactDropdown{get; set;}
    
    protected void LogMessage(ApexPages.Severity severity, String message)
    {
         try
         {
            if (apexpages.currentpage() != null) {
            System.debug('Severity : ' + severity.name() + ' Message : ' + message);
            ApexPages.addMessage(new ApexPages.Message(severity,  message));
            }
         }
         catch(Exception exp)
         {
            System.debug('Exception in LogMessage : ' + exp.getMessage());
         }
    }
    /********************************************************************/
    // Function Name    : createMergeFields
    // Argument         : 
    // Return Type      : 
    // Description      : This method has to be implemented all sub-classes
    //                    of SCM_MergeDocument. It instantiates all the 
    //                    necessary fields in both mergeRecipientInfo and 
    //                    mergeFields collections.
    /********************************************************************/    
    protected abstract void createMergeFields();
    
    public String setXMLExcapeCharacters(String str)
    {
        if(str!=null)
        {
            String retVal = str;
            retVal = retVal.replace('&','&amp;');
            retVal = retVal.replace('"','&quot;');
            retVal = retVal.replace('>','&gt;');
            retVal = retVal.replace('<','&lt;');
            return retVal;
        }
        else
            return '';
    }
    
    
    public void printValues()
    {
        try
        {
            for(SCM_MergeField mField:mergeRecipientInfo)
            {
                String message='RecipientInfo -> ';
                if(mField.key!=null)
                    message +=' Key : '+ mField.key;
                if(mField.getMergeValue()!=null)
                    message += ' MergeValue :' + mField.getMergeValue();
                if(mField.className!=null)
                    message +=' ClassName : ' + mField.className;  
                
                LogMessage(ApexPages.Severity.INFO,  message);  
            }   
            for(SCM_MergeField mField:mergeFields)
            { 
                String message='MergeFields -> ';
                if(mField.key!=null)
                    message +=' Key : ' +mField.key;
                if(mField.getMergeValue()!=null)
                    message += ' MergeValue :' + mField.getMergeValue();
                if(mField.className!=null)
                    message +=' ClassName : ' + mField.className;           
               
                LogMessage(ApexPages.Severity.INFO,  message);  
            }  
            
            
            for(SCM_MergeImage mImage:mergeImages)
            { 
                String message='MergeImages -> ';
                if(mImage.key!=null)
                    message +=' Key : ' +mImage.key;
                if(mImage.getValue()!=null)
                    message += ' ImageValue :' + mImage.getValue();         
                
                LogMessage(ApexPages.Severity.INFO,  message);  
            }       
            
            for(SCM_MergeSection mSection:mergeSections)
            { 
                String message='MergeSections -> ';
                if(mSection.key!=null)
                    message +=' Key : ' +mSection.key;
                if(mSection.visible!=null)
                    message += ' Visible :' + mSection.visible;         
                
                LogMessage(ApexPages.Severity.INFO,  message);  
            }   
        }
        catch(Exception exp)
        {
            LogMessage(ApexPages.Severity.INFO,  exp.getMessage());    
        }
    }
    
    /********************************************************************/
    // Function Name    : getXMLString
    // Argument         : 
    // Return Type      : String
    // Description      : Creates an xml file that has the metadata key, field value and 
    //                    field group section visibility information to be used by the mail merge
    //                    process in SpringCM. 
    //        <fields>
    //            <field key="abc" value="345" />
    //            <field key="def" value="345" />
    //       </fields>
    //       <sections>
    //          <section key="key1" visible="true"/>
    //          <section key="key2" visible="false"/>
    //       </sections>
    //       <images>
    //          <image key="key1" visible="true"/>
    //          <image key="key2" visible="false"/>
    //       </images>
    /********************************************************************/    
    public String getXMLString()
    {
        getLatestValues();
        String xmlString='<fields> \n';
        xmlString +=getMergeFieldCollectionString(mergeRecipientInfo);
        xmlString +=getMergeFieldCollectionString(mergeFields);
        xmlString+= '</fields>';
        xmlString+='<sections>';
        xmlString +=getMergeFieldGroupVisibilityXML(mergeRecipientInfo);
        xmlString +=getMergeFieldGroupVisibilityXML(mergeFields);
        xmlString +=getMergeSectionXML(mergeSections);
        xmlString+='</sections>';
        xmlString+='<images>';
        xmlString+= getMergeImageXML(mergeImages);
        xmlString+='</images>';
        xmlString+='<repeaters>';
        xmlString+= getMergeRepeaterXML(mergeRepeaters);
        xmlString+='</repeaters>';
        return xmlString;

    }
    /********************************************************************/
    // Function Name    : getMergeFieldCollectionString
    // Argument         : List<SCM_MergeField>
    // Return Type      : String
    // Description      : 
    /********************************************************************/      
    private String getMergeFieldCollectionString(List<SCM_MergeField> mFieldList)
    {
        String xmlString='';
        for(SCM_MergeField mField:mFieldList)
        {
            if(mField.isFieldGroup)
            {
                xmlString += getMergeFieldCollectionString(mField.subFields);
            }
            else
            {
                xmlString+=getMergeFieldString(mField);
            }
        }
        return xmlString;
    }
    
    
    /********************************************************************/
    // Function Name    : getMergeFieldGroupVisibility
    // Argument         : List<SCM_MergeField>
    // Return Type      : String
    // Description      : 
    /********************************************************************/   
    private String getMergeFieldGroupVisibilityXML(List<SCM_MergeField> mFieldList)
    {
        String xmlString='';
        for(SCM_MergeField mField : mFieldList)
        {
            if(mField.isFieldGroup)
            {
                SCM_MergeFieldGroup mGroup = (SCM_MergeFieldGroup) mField;
                String keyValue = '';

                if(mField.key !=null)
                {
                    keyValue = mField.key;
                    keyValue = setXMLExcapeCharacters(keyValue);
                }
              
                xmlString+= '<section key="'+ keyValue + '" visible="'+ mGroup.getVisible() + '" />';  
            }
        }   
        return xmlString;
    }
    
    /********************************************************************/
    // Function Name    : getMergeSectionXML
    // Argument         : List<SCM_MergeSection>
    // Return Type      : String
    // Description      : 
    /********************************************************************/   
    private String getMergeSectionXML(List<SCM_MergeSection> mSectionList)
    {
        String xmlString='';
        for(SCM_MergeSection mSection : mSectionList)
        {
             String keyValue = '';
             if(mSection.key !=null)
             {
                keyValue = mSection.key;
                keyValue = setXMLExcapeCharacters(keyValue);
            }
              
            xmlString+= '<section key="'+ keyValue + '" visible="'+ mSection.visible + '" />';  
        }   
        return xmlString;
    }
    
    /********************************************************************/
    // Function Name    : getMergeImageXML
    // Argument         : List<SCM_MergeImage>
    // Return Type      : String
    // Description      : 
    /********************************************************************/   
    private String getMergeImageXML(List<SCM_MergeImage> mImageList)
    {
        String xmlString='';
        for(SCM_MergeImage mImage : mImageList)
        {
             String keyValue = '';
             if(mImage.key !=null)
             {
                keyValue = mImage.key;
                keyValue = setXMLExcapeCharacters(keyValue);
            }
              
            String mergeValue = '';
            if(mImage.getValue()!=null)
            {
                mergeValue = mImage.getValue();
                mergeValue = setXMLExcapeCharacters(mergeValue);
            }  
            xmlString+= '<image key="'+ keyValue + '" value="'+ mergeValue + '" />';  
        }   
        return xmlString;
    }
    
    /********************************************************************/
    // Function Name    : getMergeRepeaterXML
    // Argument         : List<SCM_MergeRepeater>
    // Return Type      : String
    // Description      : 
    /********************************************************************/   
    private String getMergeRepeaterXML(List<SCM_MergeRepeater> mRepeaterList)
    {
        String xmlString='';
        if(mRepeaterList!=null)
        {
            for(SCM_MergeRepeater mRepeater : mRepeaterList)
            {
                 String keyValue = '';
                 if(mRepeater.targetTextBox !=null)
                 {
                    keyValue = mRepeater.targetTextBox;
                    keyValue = setXMLExcapeCharacters(keyValue);
                }
                  if (mRepeater.AppendReturn== null) {
                    mRepeater.AppendReturn = false;
                  }
                  if (mRepeater.IsTableRow== null) {
                    mRepeater.IsTableRow = false;
                  }
                xmlString+= '<repeatingdata key="'+ keyValue + '" Appendline="' + mRepeater.AppendReturn + '" IsTableRow="'+ mRepeater.IsTableRow + '">'; 
                if(mRepeater.repeaterItems!=null)
                {
                    for(SCM_MergeRepeaterItem repeaterItem:mRepeater.repeaterItems)
                    {
                        if(repeaterItem.mergeFields!=null)
                        {
                            xmlString+= '<item>';
                            xmlString+= getMergeFieldCollectionString(repeaterItem.mergeFields);
                            xmlString+= '</item>';
                        }
                    }
                }
                xmlString+= '</repeatingdata>';  
            }   
        }
        return xmlString;
    }
    
    /********************************************************************/
    // Function Name    : getMergeFieldString
    // Argument         : SCM_MergeField
    // Return Type      : String
    // Description      : 
    /********************************************************************/     
    private String getMergeFieldString(SCM_MergeField mField)
    {
        String keyValue = '';
        String mergeValue = '';
        if(mField.key !=null)
        {
            keyValue = mField.key;
            keyValue = setXMLExcapeCharacters(keyValue);
        }

        mergeValue = mField.getMergeValue();

        if(mergeValue!=null)
        {
            if(mergeValue=='null')
                mergeValue='';
            mergeValue = setXMLExcapeCharacters(mergeValue);
            if(mergeValue.length()>0 && 
               !mergeValue.endsWith('\n\r') &&
               mField.requireNewLineInTemplate)
            {
                mergeValue+='\n';
            }
        }   
        return '<field key="'+ keyValue + '" value="'+ mergeValue + '" />';  

    }
    
    
    /********************************************************************/
    // Function Name    : getContactOptions
    // Argument         : 
    // Return Type      : List<SCM_ContactInfo>
    // Description      : This function is called by the SCM_MergePageController
    //                    in order to get all contact options available for the
    //                    document. This method is meant to be overridden in subclasses     
    /********************************************************************/ 
    protected List<SCM_ContactInfo> contactOptions;
    public virtual List<SCM_ContactInfo> getContactOptions()
    {
        if(contactOptions==null)
            initializeContactOptions();
            
        return contactOptions;
    }
    
    private List<Contact> GetPrimaryGATCFContacts(){
            if(selectedCase.Case_Treating_Physician_gne__c!=null && selectedCase.Address_gne__c != null)
            {
                LogMessage(ApexPages.Severity.INFO,  'Treating Physician Id: ' + selectedCase.Case_Treating_Physician_gne__c);  
                List<Contact> relatedContacts = [Select c.C_R_Specific_gne__c,c.GATCF_Specific_gne__c,  c.Is_Primary_for_gne__c,
                                                    c.FirstName,c.LastName, c.Fax 
                                                from Contact c
                                                 where   c.Address_gne__c = :selectedCase.Address_gne__c and Is_Primary_for_gne__c includes ('GATCF') 
                                                
                                                 order by FirstName
                                                 //or  AccountId=:selectedCase.Case_Treating_Physician_gne__c
                                                 limit 50];
                                                 return relatedContacts;
            }    	
    	return null;
    }
    private List<Contact> GetPrimaryCRContacts(){
            if(selectedCase.Case_Treating_Physician_gne__c!=null && selectedCase.Address_gne__c != null)
            {
                LogMessage(ApexPages.Severity.INFO,  'Treating Physician Id: ' + selectedCase.Case_Treating_Physician_gne__c);  
                List<Contact> relatedContacts = [Select c.C_R_Specific_gne__c,c.GATCF_Specific_gne__c,  c.Is_Primary_for_gne__c,
                                                    c.FirstName,c.LastName, c.Fax 
                                                from Contact c
                                                 where   c.Address_gne__c = :selectedCase.Address_gne__c and Is_Primary_for_gne__c includes ('C&R') 
                                                
                                                 order by FirstName
                                                 //or  AccountId=:selectedCase.Case_Treating_Physician_gne__c
                                                 limit 50];
                                                 return relatedContacts;
            }    	
    	return null;
    }
    private List<Contact> GetNonPrimaryGATCFContacts(){
            if(selectedCase.Case_Treating_Physician_gne__c!=null && selectedCase.Address_gne__c != null)
            {
                LogMessage(ApexPages.Severity.INFO,  'Treating Physician Id: ' + selectedCase.Case_Treating_Physician_gne__c);  
                List<Contact> relatedContacts = [Select c.C_R_Specific_gne__c,c.GATCF_Specific_gne__c,  c.Is_Primary_for_gne__c,
                                                    c.FirstName,c.LastName, c.Fax 
                                                from Contact c
                                                 where   c.Address_gne__c = :selectedCase.Address_gne__c and Is_Primary_for_gne__c excludes ('GATCF')
                                                
                                                 order by FirstName
                                                 //or  AccountId=:selectedCase.Case_Treating_Physician_gne__c
                                                 limit 50];
                                                 return relatedContacts;
            }    	
    	return null;
    } 
     private List<Contact> GetNonPrimaryCRContacts(){
            if(selectedCase.Case_Treating_Physician_gne__c!=null && selectedCase.Address_gne__c != null)
            {
                LogMessage(ApexPages.Severity.INFO,  'Treating Physician Id: ' + selectedCase.Case_Treating_Physician_gne__c);  
                List<Contact> relatedContacts = [Select c.C_R_Specific_gne__c,c.GATCF_Specific_gne__c,  c.Is_Primary_for_gne__c,
                                                    c.FirstName,c.LastName, c.Fax 
                                                from Contact c
                                                 where   c.Address_gne__c = :selectedCase.Address_gne__c and Is_Primary_for_gne__c excludes ('C&R')
                                                
                                                 order by FirstName
                                                 //or  AccountId=:selectedCase.Case_Treating_Physician_gne__c
                                                 limit 50];
                                                 return relatedContacts;
            }    	
    	return null;
    } 
    
    private void initializeContactOptions()
    {
        contactOptions = new List<SCM_ContactInfo>();
        displayContactDropDown = false;
        if(this instanceof IStandardComboBox)
        {
            displayContactDropDown = true;
            if(selectedCase.Case_Treating_Physician_gne__c!=null && selectedCase.Address_gne__c != null)
            {
                LogMessage(ApexPages.Severity.INFO,  'Treating Physician Id: ' + selectedCase.Case_Treating_Physician_gne__c);
                List<Contact> relatedContacts;
                List<Contact> relatedContacts2;
                  if ((selectedCase.RecordType.Name.contains('C&R - Standard')) || (selectedCase.RecordType.Name.contains('C&R - Continuous Care')))
                        {  
                 			   relatedContacts =  GetPrimaryCRContacts(); 
                 			   relatedContacts2 = GetNonPrimaryCRContacts();  	
                        }  
                        else {
                        	
                        	relatedContacts =  GetPrimaryGATCFContacts();
                        	relatedContacts2 = GetNonPrimaryGATCFContacts();
                        }
                 
            
                relatedContacts.addAll(relatedContacts2);
                //Select c.FirstName, c.LastName, c.Fax, c.Primary_Contact_gne__c ,c.Is_Primary_for_gne__c
                                                 
                
                LogMessage(ApexPages.Severity.INFO,'Related Contact Count: ' + relatedContacts.size());
                
               String firstName = '';
                String lastName = '';
                String fax= '';
                String fullName='';
               
                if(relatedContacts.size()>0)
                {
                        String caseType = selectedCase.RecordType.Name;
                                    
                        if ((caseType.contains('C&R - Standard')) || (caseType.contains('C&R - Continuous Care')))
                        {  
                            
                            for(Contact currentContact:relatedContacts)
                            {
                            	
                            	firstName = '';
                				lastName = '';
                				fax= '';
                				fullName='';
                                String strIsPrimary = currentContact.Is_Primary_for_gne__c == null ? '':currentContact.Is_Primary_for_gne__c;
                                if(currentContact.C_R_Specific_gne__c == true || strIsPrimary.contains('C&R')) 
                                {
                                    //if  (strIsPrimary.contains('C&R'))
                                    //{
                                        if(currentContact.FirstName!=null)
                                            firstName = currentContact.firstName;
                                        if(currentContact.lastName!=null)
                                            lastName = currentContact.lastName;
                                        if(currentContact.fax!=null)
                                            fax = currentContact.fax;
                                        
                                        if(firstName=='')
                                            fullName = lastName;
                                        else
                                            fullName = firstName+' '+lastName;
                                            
                                          if(currentContact.Fax!=null)
                                          {
                                            if (currentContact.Fax !='')                                            
                                            {
                                              fax = currentContact.Fax;
                                           }
                                          }
                                            else
                                            {
                                            fax = '';
                                            }
                                     
                                           
                                        contactOptions.add(new SCM_ContactInfo( fullName, lastName, fax));
                                       
                                        LogMessage(ApexPages.Severity.INFO,'Contact Option Added -> fullName : ' + fullName + ' fax: ' + fax );
                                    //} 
                                }
                            }
                        }
                        else if(caseType.startsWith('GATCF'))
                        { 
                            for(Contact currentContact:relatedContacts)
                            {
                                    //String strIsPrimary = currentContact.Is_Primary_for_gne__c == null ? '':currentContact.Is_Primary_for_gne__c;
                                //  if (strIsPrimary.contains('GATCF'))
                                //{
                                firstName = '';
                				lastName = '';
                				fax= '';
                				fullName='';
                				String strIsPrimary = currentContact.Is_Primary_for_gne__c == null ? '':currentContact.Is_Primary_for_gne__c;
                                    if (currentContact.GATCF_Specific_gne__c == true || strIsPrimary.contains('GATCF'))  
                                    {
                                        if(currentContact.FirstName!=null)
                                            firstName = currentContact.firstName;
                                        if(currentContact.lastName!=null)
                                            lastName = currentContact.lastName;
                                        if(currentContact.fax!=null)
                                            fax = currentContact.fax;
                                        
                                        if(firstName=='')
                                            fullName = lastName;
                                        else
                                            fullName = firstName+' '+lastName;
                                            
                                      if(currentContact.Fax!=null)
                                          {
                                            if (currentContact.Fax !='')                                            
                                            {
                                              fax = currentContact.Fax;
                                           }
                                          }
                                            else
                                            {
                                            fax = '';
                                            }
                                     
                                            
                                        contactOptions.add(new SCM_ContactInfo( fullName, lastName, fax));
                                        
                                        LogMessage(ApexPages.Severity.INFO,'Contact Option Added -> fullName : ' + fullName + ' fax: ' + fax );
                                    }
                                //} 
                            }
                        }  
                }
                /*              
                else if (relatedContacts.size() == 1)
                {
                            if(relatedContacts[0].FirstName!=null)
                                firstName = relatedContacts[0].firstName;
                            if(relatedContacts[0].lastName!=null)
                                lastName = relatedContacts[0].lastName;
                            if(relatedContacts[0].fax!=null)
                            {
                                if(relatedContacts[0].fax!='')
                                    fax = relatedContacts[0].fax;
                            }
                            else
                            {
                                fax = '';
                            }
                           
                            
                            if(firstName=='')
                                fullName = lastName;
                            else
                                fullName = firstName+' '+lastName;
                                
                                
                     contactOptions.add(new SCM_ContactInfo( fullName, lastName, fax));
                           
                }
                */
            } 
        }
        
        //if(contactOptions.size()>0)
        //  displayContactDropdown=true;
    }
    
    
    /********************************************************************/
    // Function Name    : checkMailMergeJob
    // Argument         : 
    // Return Type      : SCM_FaxSender_WebService.MergeJobStatus
    // Description      : This function is called by the SCM_MergePageController
    //                    in order to check the status of the mail merge job. 
    //                    It returns the job status. If the status is 'Success' 
    //                    then the state of the document is saved in the system
    /********************************************************************/ 
    public SCM_FaxSender_WebService.MergeJobStatus checkMailMergeJob()
    {

        SCM_FaxSender_WebService.FaxSenderSoap sender = new SCM_FaxSender_WebService.FaxSenderSoap(); 
        sender.timeout_x = integer.valueof(SCM_Security.getEnvironmentVariable('SCM_WS_Timeout'));
        SCM_FaxSender_WebService.MergeJobStatus jobStatus= sender.CheckMailMergeJob(mailMergeJobKey);
        if(jobStatus.status=='Success')
            save(true);
        return jobStatus;
    }
    
    
  
    /********************************************************************/
    // Function Name    : addTypeInfo2MergeList
    // Argument         : SCM_Merge_Document__c
    // Return Type      : 
    // Description      : This function adds 2 common invisible merge fields
    //                    just before merging. 
    //                    The keys are $$SCM_Document_Type$$ and $$SCM_Product$$
    /********************************************************************/   
    public void addTypeInfo2MergeList()
    {
        if(sfDocumentRecord==null)
            return;
            
        // Adding the invisible $$SCM_Document_Type$$
        if(sfDocumentRecord.Document_Type__c =='Fax Cover Sheet' || 
           sfDocumentRecord.Document_Type__c =='System Document')
           {
                SCM_MergeField mField1 = new SCM_MergeField();
                mField1.checked = false;
                mField1.displayCheck = false;
                mField1.displayTextBox = false;
                mField1.displayLabel = false;
                mField1.key = '$$SCM_Document_Type$$';
                
                if(sfDocumentRecord.Document_Type__c =='Fax Cover Sheet')
                {
                    mField1.setFieldValue('Draft Fax Coversheet');
                    //mField1.setMergeValue('Draft Fax Coversheet');
                }
                else if(sfDocumentRecord.Document_Type__c =='System Document')
                {
                    mField1.setFieldValue('Draft System Document');
                    //mField1.setMergeValue('Draft System Document'); 
                }
                mergeRecipientInfo.add(mField1);    
           }
          
        // Adding the invisible $$SCM_Product$$
        SCM_MergeField mField2 = new SCM_MergeField();
        mField2.checked = false;
        mField2.displayCheck = false;
        mField2.displayTextBox = false;
        mField2.displayLabel = false;
        mField2.key = '$$SCM_Product$$';
        mField2.setFieldValue(selectedProduct);
        mergeRecipientInfo.add(mField2);
        
        //Adding the invisible $$SCM_DocumentKey$$
        SCM_MergeField mField3 = new SCM_MergeField();
        mField3.checked = false;
        mField3.displayCheck = false;
        mField3.displayTextBox = false;
        mField3.displayLabel = false;
        mField3.key = '$$SCM_DocumentKey$$';
        mField3.setFieldValue(sfDocumentRecord.Metadata_Key__c);
        mergeRecipientInfo.add(mField3);
        
        if (selectedcase !=null && selectedcase.Patient_gne__c != null){
        //add $$Patient ID$$
        SCM_MergeField mField4 = new SCM_MergeField();
        mField4.checked = false;
        mField4.displayCheck = false;
        mField4.displayTextBox = false;
        mField4.displayLabel = false;
        mField4.key = '$$Patient Id$$';
        mField4.setFieldValue(selectedcase.Patient_gne__r.Patient_ID_gne__c);
        mergeRecipientInfo.add(mField4);  
        }
    }
      
    public Boolean checkRequiredFields()
    { 
        List<String> requiredFieldKeys = new List<String>();
        requiredFieldKeys.add('$$SCM_Product$$');
        requiredFieldKeys.add('$$SCM_Document_Type$$');
        requiredFieldKeys.add('RECFAX_');
        //requiredFieldKeys.add('RECNAME_');
        requiredFieldKeys.add('ATTN_');
        Boolean checkSuccess= true;
        for(String str : requiredFieldKeys)
        {
            if(getIndexInMergeFieldList(str, mergeRecipientInfo)==-1)
            {
                LogMessage(ApexPages.Severity.ERROR, 
                        'Required field with key including with ' + str + ' does not exist in mergeRecipientInfo');
                checkSuccess=false;
            }
        }
        return checkSuccess;
    }
    
    
    // Checks if a field starts with a certain string value in a SCM_MergeField list
    public Integer getIndexInMergeFieldList(String str, List<SCM_MergeField> mFields)
    {
        Integer index=0;
        for(SCM_MergeField mField : mFields)
        {
            if(mField.key.startsWith(str))
            {
                return index;
            }
            index++;
        }
        return -1;
    }
    
    /********************************************************************/
    // Function Name    : createMergedDocument
    // Argument         : 
    // Return Type      : String
    // Description      : This function creates mailMergeJobKey by calling 
    //                    the CreateMailMergeJob at springCM. 
    /********************************************************************/ 
    public virtual String createMergedDocument()
    {
        try
        {
            Datetime total_StartTime = System.now();
            if(sfDocumentRecord==null)
                return null;
            //declare webservice
          
            SCM_WebServices.SpringCMServiceSoap SCMsvc = new SCM_WebServices.SpringCMServiceSoap();
            SCMsvc.timeout_x = integer.valueof(SCM_Security.getEnvironmentVariable('SCM_WS_Timeout'));
            String fieldXML;
            
          
            fieldXML = getXMLString();
            
            Datetime token_StartTime = System.now();
            String token=SCM_Security.SCM_AuthenticateNonDefault();
            Datetime token_StopTime = System.now();
            String fileName = sfDocumentRecord.Name;
 
            //Call webservice to create the SpringCM file here....  
            SCM_FaxSender_WebService.FaxSenderSoap sender = new SCM_FaxSender_WebService.FaxSenderSoap();
            sender.timeout_x = integer.valueof(SCM_Security.getEnvironmentVariable('SCM_WS_Timeout'));
            String strFolderId = '';
            
            
            Datetime strFolderId_StartTime;
            Datetime strFolderId_StopTime;
            try
            {
             String body = '\nGetCaseFolderid Arguments : token->' + token + ' Number->'+selectedObjectNumber+' Product->'+ selectedProduct + 
                              ' SF Id->' + selectedObjectId ;
             LogMessage(ApexPages.Severity.INFO, body);
             strFolderId_StartTime = System.now();
             strFolderId = sender.GetCaseFolderid(token,selectedObjectNumber,selectedProduct,true, selectedObjectId, UserInfo.getOrganizationId());
             strFolderId_StopTime = System.now();
             LogMessage(ApexPages.Severity.INFO, 'Returned FolderId :' + strFolderId);
             
            }
            catch(Exception exp)
            {
                String body = 'Exception in webservice call sender.GetCaseFolderid';
                LogMessage(ApexPages.Severity.ERROR, body);
                LogMessage(ApexPages.Severity.ERROR, exp.getMessage());
            }
             
           // Integer folderId = Integer.valueOf(strFolderId);
           if(strFolderId == null || strFolderId.trim()=='')
           {
                String body = 'Folder Id cannot be empty! \n Arguments : token->' + token + ' Case Number->'+selectedObjectNumber+' Product->'+ selectedProduct + 
                              ' Case Id->' + selectedObjectId ;
                LogMessage(ApexPages.Severity.ERROR, body);
                return null;
           }
           
           
           String body = '\n CreateMailMergeJob Arguments : token->' + token + '    MetadataKey>'+sfDocumentRecord.Metadata_Key__c+
                            '   Folder Id->'+ strFolderId + '   File Name->' + fileName + '     FieldXML->'+ fieldXML ;
          LogMessage(ApexPages.Severity.INFO, body);
          
          if(sfDocumentRecord.Document_Type__c =='Fax Cover Sheet' &&  
            !checkRequiredFields())
            return null;
           Datetime mailMergeJobKey_StartTime = System.now();
           mailMergeJobKey = sender.CreateMailMergeJob(token,sfDocumentRecord.Metadata_Key__c,strFolderId,fileName,fieldXML);
           Datetime mailMergeJobKey_StopTime = System.now();
    		
           Datetime total_StopTime = System.now();

           if(SCM_Security.SendPerformanceEmail)
           {
               SCM_LogError.sendEmail('MergeDocument Performance Log', 'AuthenticateNonDefault() : Start time: ' + string.valueOf(token_StartTime) + ' Stop time: ' + string.valueOf(token_StopTime) + '  took - ' + string.valueOf(token_StopTime.getTime() - token_StartTime.getTime()) + 'ms\n' +
               'GetCaseFolderId()        : Start time: ' + string.valueOf(strFolderId_StartTime) + ' Stop time: ' + string.valueOf(strFolderId_StopTime) + '  took - ' + string.valueOf(strFolderId_StopTime.getTime() - strFolderId_StartTime.getTime()) + 'ms\n' +
               'CreateMailMergeJob()     : Start time: ' + string.valueOf(mailMergeJobKey_StartTime) + ' Stop time: ' + string.valueOf(mailMergeJobKey_StopTime) + '  took - ' + string.valueOf(mailMergeJobKey_StopTime.getTime() - mailMergeJobKey_StartTime.getTime()) + 'ms\n' +
               'Total                    : Start time: ' + string.valueOf(total_StartTime) + ' Stop time: ' + string.valueOf(total_StopTime) + '  took - ' + string.valueOf(total_StopTime.getTime() - total_StartTime.getTime()) + 'ms'
               ,true);
           }
           SCM_WSLogger.InsertLog(sender.log.MethodName__c,sender.log.Parameters__c);
           return mailMergeJobKey;
        }
        catch(Exception exp)
        {
            LogMessage(ApexPages.Severity.ERROR, 'CreateMergedDocument : '+ exp.getMessage());
            return null;
        }
 
    }
    
  
     public void setCacheMergeValue(SCM_MergeField cacheField)
    {
        LogMessage(ApexPages.Severity.INFO, 'Set cache field value: ' + cacheField.key);
        for(SCM_MergeField mField:mergeFields)
        {
            LogMessage(ApexPages.Severity.INFO,'MergeFields: ' + mField.key);
            if(mField.isFieldGroup)
            {
                LogMessage(ApexPages.Severity.INFO,'Groupfield');
                for(SCM_MergeField subField:mField.subFields)
                {
                    LogMessage(ApexPages.Severity.INFO,'SubFields : ' + subField.key);
                    if(subField.key==cacheField.key)
                    {
                    	
						if (subField.allowCache){                    
                        LogMessage(ApexPages.Severity.INFO,'Updating By cache value: ' + cacheField.getMergeValue());
                        subField.setMergeValue(cacheField.getMergeValue());
                        subField.checked = cacheField.checked;
                        subField.selectedValue = cacheField.selectedValue;
						}
                    }
                }
            }
            else
            {
                LogMessage(ApexPages.Severity.INFO,'SingleField');
                if(mField.key==cacheField.key)
                {
                	
                if (mField.allowCache){
                    LogMessage(ApexPages.Severity.INFO,'Updating By cache value: ' + cacheField.getMergeValue());
                    mField.checked = cacheField.checked;
                    
                    if(mField.selectionItems.size()>0)
                    {
                        for(SelectOption option:mField.selectionItems)
                        {
                            String oValue= option.getValue();
                            oValue = oValue.replace('\r','');
                            //oValue = oValue.replace('\t','');
                            String cValue= cacheField.getMergeValue();
                            Integer index=0;
                            Boolean indexFound=false;
                            for(SelectOption opt: cacheField.selectionItems)
                            {
                                if(opt.getLabel()==option.getLabel() && opt.getValue()==cacheField.getMergeValue())
                                {
                                    mField.selectedValue = option.getValue();
                                    mField.setFieldValue(option.getValue());
                                    break;
                                }
                                index++;
                            }
                        }   
                    }
                    else
                    {
                        //mField.selectedValue = cacheField.selectedValue;
                        mField.setMergeValue(cacheField.getMergeValue());
                    }
                }
            }
            }
        }
        
    } 

  
    /********************************************************************/
    // Function Name    : load
    // Argument         : String savedState
    // Return Type      : 
    // Description      : This loads the values saved in the last successful
    //                    mail merge process to mergeRecipientInfo and mergeFields
    //                    lists.
    /********************************************************************/ 
      
    public void load()
    { 
        String savedState = '';
        try
        {
            List<SCM_Mail_Merge_Cache__c> cacheList=[select Merge_Doc_State__c 
                                                     from SCM_Mail_Merge_Cache__c 
                                                     where ObjectId__c=:selectedObjectId and 
                                                           SCM_Merge_Document__c=:mergeLookupID];
            if(cacheList.size()>0)
            {
                savedState = cacheList[0].Merge_Doc_State__c;
                //mergeRecipientInfo.clear();
                //mergeFields.clear();
                //Blob decodedBlob= EncodingUtil.base64Decode(savedState);
                //String decodedSavedState = decodedBlob.ToString();
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Cache Found!'));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'SavedState : ' + savedState));
            //  mergeRecipientInfo =  SCM_MergeDocumentCaching.getSectionMergeFields(decodedSavedState,'RecipientInfo');
                List<SCM_MergeField> cachedMergeFields = SCM_MergeDocumentCaching.getSectionMergeFields(savedState,'MergeFields');
                for(SCM_MergeField mField:cachedMergeFields)
                {
                	
                	if (mField.allowCache){
                    	if(mField.isFieldGroup)
                    	{
                        	for(SCM_MergeField subField:mField.subFields)
                        	if (subField.allowCache){
                            	setCacheMergeValue(subField);
                        	}
                    	}
                    	else{
                        	setCacheMergeValue(mField);
                    	}             
                	}
                }
            }
        }
        catch(Exception exp)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 
                                'Exception  Occured while parsing the cache! Exception Message : ' + exp.getMessage()));
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Saved State : ' + savedState ));
            
        }
    }
    
    
    /********************************************************************/
    // Function Name    : save
    // Argument         : Boolean savePerm
    // Return Type      : String savedState
    // Description      : This saves the current values of mergeFields
    //                    list in case of a successful mail merge process 
    //                    in SCM_Mail_Merge_Cache__c object
    /********************************************************************/    
    public String save(Boolean savePerm)
    {  try {
        List<SCM_MergeField> visibleMergeFields= new List<SCM_MergeField>();
        for(SCM_MergeField mField:mergeFields)
        {
            if(mField.displayField)
            {
                visibleMergeFields.add(mField);
            }
        }
        String strViewState= SCM_MergeDocumentCaching.createViewStateXML(visibleMergeFields);
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'SavedState : ' + strViewState));
        //Blob blobToEncode = Blob.valueOf(strViewState);
        //String encodedViewState  = EncodingUtil.base64Encode(blobToEncode);
        if(savePerm)
        {  
            SCM_Mail_Merge_Cache__c history = new SCM_Mail_Merge_Cache__c(ObjectId__c=selectedObjectId,  
                                                                        Merge_Doc_State__c=strViewState, 
                                                                        SCM_Merge_Document__c=mergeLookupID);
           List<SCM_Mail_Merge_Cache__c> idList= [select Id 
                                                  from SCM_Mail_Merge_Cache__c 
                                                  where ObjectId__c=:selectedObjectId and 
                                                        SCM_Merge_Document__c=:mergeLookupID];
           if(idList.size()>0)
                delete  idList;
           
            insert history;
        }
        return strViewState;
    }Catch (exception ex){
    return '';	
    }
    }

    

    /********************************************************************/
    // Function Name    : SCM_MergeDocument  (constructor)
    // Argument         : String caseId, String argLookupId
    // Return Type      : SCM_MergeDocument
    // Description      : Given a caseId and SCM_MergeDocument__c Id, it 
    //                    queries and sets the selectedCase and mergeLookupID
    //                    then calls createMergeFields function in order to 
    //                    populate the merge fields in mergeRecipientInfo and
    //                    mergeFields lists. 
    /********************************************************************/    
    public SCM_MergeDocument(String caseId, String argLookupId)
    {
        mergeRecipientInfo= new List<SCM_MergeField>();
        mergeFields = new List<SCM_MergeField>(); 
        mergeSections = new List<SCM_MergeSection>();
        mergeImages = new List<SCM_MergeImage>();
        displayContactDropdown=false;
        List<Case>caseList = [select  
                    c.RecordType.Name , 
                    c.Patient_gne__r.Name, 
                    c.Patient_gne__r.Mid_Initial_gne__c, 
                    c.Patient_gne__r.pat_dob_gne__c,
                    c.Patient_gne__r.pat_first_name_gne__c,
                    c.Patient_gne__r.Patient_Id_gne__c,
                    c.Case_Manager__r.LastName,
                    c.Case_Manager__r.FirstName, 
                    c.Account.Name,
                    c.owner.Name, 
  
                 c.Access_Solutions_Online_Note_gne__c, c.AccountId, c.Account.Id, 
                 c.Address_gne__c, c.Address_gne__r.Id, c.After_Trigger_Flag_gne__c,
                  c.AGI_Qualified_gne__c, c.Alt_Cvg_Options_Discussed_Date_gne__c, 
                  c.Approval_Date_gne__c, c.AssetId, c.Asset.Id, c.C_R_Case__c, 
                  c.Case_Being_Worked_By_gne__c, c.Case_Count_gne__c, c.Case_Manager__c, 
                  c.Case_Manager__r.Id, c.case_referral_reason_gne__c, 
                  c.Case_Treating_Physician_gne__c, c.Case_Treating_Physician_gne__r.Id, 
                  c.CaseNumber, c.CCP_Approved_gne__c, c.City_gne__c, c.ClosedDate, 
                  c.Contacted_By_gne__c, c.Contacted_By_gne__r.Id, c.ContactId, 
                  c.Contact.Id, c.Contingent_Determination_gne__c, c.CoPay_Amount_gne__c, 
                  c.CoPay_Percent_gne__c, c.Counter_gne__c, c.Coverage_Denied_Calc_gne__c, 
                  c.Coverage_Established_Calc_gne__c, c.Coverage_Established_gne__c, 
                  c.Coverage_Options_gne__c, c.CreatedById, c.CreatedBy.Id, 
                  c.CreatedDate, c.Current_Tax_Return_gne__c, c.Cvg_gne__c, 
                  c.Date_Contacted_gne__c, c.Date_Discussed_gne__c, 
                  c.Date_Enrolled_gne__c, c.Date_gne__c, c.Date_Un_Enrolled_gne__c, 
                  c.Denial_Date_gne__c, c.Description, c.Diagnosis_gne__c, 
                  c.Distributor_Case_ID_gne__c, c.Documentation_gne__c, 
                  c.Eligibility_Determination_Date_gne__c, 
                  c.Eligibility_Document_Received_Date_gne__c, 
                  c.Eligibility_gne__c, c.Enroll_Comp_Original_Receipt_gne__c, 
                  c.Enroll_Date_Calc_gne__c, c.Enroll_SMN_Form_Signed_Date_gne__c, 
                   
                  c.Enrollment_Not_Complete_Reason_gne__c, c.Facility_gne__c, c.Facility_gne__r.Id, 
                  c.File_name_gne__c, c.Financial_Checklist_Mailed_Date_gne__c, 
                  c.Foundation_Specialist_gne__c, c.Foundation_Specialist_gne__r.Id, 
                  c.Foundation_Status_gne__c, c.Function_Performed_gne__c, 
                  c.GATCF_Status_gne__c, 
                  /* 
					Genentech_Owner_gne__c deleted - lookup reused                  
                  c.Genentech_Owner_gne__c, c.Genentech_Owner_gne__r.Id, 
                  */ 
                  c.HasCommentsUnreadByOwner, c.HasSelfServiceComments, 
                  c.ICD9_Code_2_gne__c, c.ICD9_Code_3_gne__c, c.Id, c.In_Network_gne__c, 
                  c.Income_gne__c, c.Income_Range_gne__c, c.Income_Source_gne__c, 
                  c.Infusions_Total_gne__c, c.Initial_Referral_gne__c, 
                  c.Injection_Training_Provided_By_gne__c, 
                  c.Injection_Training_Requested_gne__c, c.IsClosed, 
                  c.IsClosedOnCreate, c.IsDeleted, c.IsEscalated, 
                  c.IsLocked, c.IsSelfServiceClosed, c.IsVisibleInSelfService, 
                  c.LastModifiedById, c.LastModifiedBy.Id, c.LastModifiedDate, 
                  c.Legacy_Case_ID_gne__c, c.Mailbox_gne__c, c.Mailed_Date_gne__c, 
                  c.MayEdit, c.Medical_Eligibility_gne__c, 
                  c.Medical_Eligibility_Month_gne__c, c.Medical_Eligibility_Year_gne__c, 
                  c.Medical_History_gne__c, c.Medical_History_gne__r.Id, c.Medical_History_gne__r.Drug_gne__c,
                  c.New_Insurance_Coverage_Obtained_by_gne__c, 
                  c.New_Insurance_Coverage_Obtained_by_gne__r.Id, 
                  c.New_Insurance_Coverage_Obtained_Date_gne__c, 
                  c.New_Insurance_Coverage_Obtained_gne__c, 
                  c.New_Insurance_gne__c, c.OK_to_Contact_Patient_gne__c, 
                  c.Open_Enrollment_Date_gne__c, c.Origin, c.Other_Description_gne__c, 
                  c.Other_Injection_Training_Provided_By_gne__c, 
                  c.Out_of_Network_gne__c, c.OwnerId, c.PAN_gne__c, 
                  c.ParentId, c.Patient_gne__c, c.Practice_gne__c, c.Practice_gne__r.Id,  c.Priority, 
                  c.Product_gne__c, c.PT_MD_Notified_of_Resolution_gne__c, 
                  c.Reason, c.Received_Date_gne__c, c.RecordTypeId, 
                  c.Referred_By_Date_gne__c, c.Referred_By_Party_gne__c, 
                  c.Referred_By_Person_gne__c, c.Referred_By_Type_gne__c, 
                  c.Referred_to_Vendor_SP_gne__c, c.Reimbursement_Specialist_gne__c, 
                  c.Related_C_R_Case_gne__c, c.Release_gne__c, 
                  c.Roll_Up_Infuisons_To_gne__c, c.Sent_To_Vendor_gne__c, 
                  c.Services_Requested_gne__c, c.Special_Program_Name_gne__c, 
                  c.Special_Program_Note_gne__c, c.State_Treating_Physician_gne__c, 
                  c.Status, c.Sticker_Number_gne__c, c.Subject, c.SuppliedCompany, 
                  c.SuppliedEmail, c.SuppliedName, c.SuppliedPhone, c.SystemModstamp, 
                  c.Tax_Return_Year_gne__c, c.Therapy_Status_Id_gne__c, 
                  c.Time_at_Vendor_SP_gne__c, c.Time_to_Conversion__c, 
                  c.Type, c.Type_gne__c, c.Vendor_Case_ID_gne__c, c.Vendor_Name_gne__c, 
                  c.Verbal_Consent_gne__c, c.Verbal_Consent_Obtained_by_gne__c, 
                  c.Verbal_Consent_Obtained_On_gne__c, c.Verified_Income_gne__c, 
                  c.VIP_Note_gne__c, c.Web_Pat_ID_gne__c, c.Year_Screened_gne__c, 
                  c.Zip_gne__c,Referral_Address_Line_1_gne__c ,Referral_Address_Line_1_gne__r.Id ,
                  Referred_By_Party_gne__r.id
            from Case c
            Where c.Id=:caseId];
        if(caseList.size()>0)    
            selectedCase=caseList[0];
        
        selectedObjectId='';
        selectedObjectNumber='';
        selectedProduct='';
        if(selectedCase!=null)
        {
          selectedObjectId = selectedCase.Id;   
          if(selectedCase.Product_gne__c!=null)
            selectedProduct = selectedCase.Product_gne__c;
          if(selectedCase.CaseNumber !=null)
            selectedObjectNumber = selectedCase.CaseNumber;
        }
        
        LogMessage(ApexPages.Severity.INFO, 'selectedObjectId : ' + selectedObjectId);
        LogMessage(ApexPages.Severity.INFO, 'selectedProduct : ' + selectedProduct);
        LogMessage(ApexPages.Severity.INFO, 'selectedObjectNumber : ' + selectedObjectNumber);
        
        mergeLookupID = argLookupId;
        
        createMergeFields();
        getContactOptions();
        List<SCM_Merge_Document__c> documentList =  [Select Name, Document_Type__c, Product__c, Metadata_Key__c from SCM_Merge_Document__c where Id=:mergeLookupID Limit 1];
        //SCM_Merge_Document__c document=null;
        if(documentList.size()>0)
            sfDocumentRecord= documentList[0];

        addTypeInfo2MergeList();
    }
    
    
    // This is called from SCM_MergeDocument_Hotline
    // it gets only SCM_MergeDocument__c id as argument
    // there is no createMergeFields() and addTypeInfo2MergeList() calls in the end...
    
    public SCM_MergeDocument(String argLookupId)
    {
        mergeRecipientInfo= new List<SCM_MergeField>();
        mergeFields = new List<SCM_MergeField>(); 
        mergeSections = new List<SCM_MergeSection>();
        mergeImages = new List<SCM_MergeImage>();
        mergeLookupID = argLookupId;
        selectedObjectId='';
        selectedObjectNumber='';
        selectedProduct='';
        getContactOptions();
        
        List<SCM_Merge_Document__c> documentList =  [Select Name, Document_Type__c, Product__c, Metadata_Key__c from SCM_Merge_Document__c where Id=:mergeLookupID Limit 1];
        sfDocumentRecord=null;
        if(documentList.size()>0)
            sfDocumentRecord= documentList[0];

        
        //createMergeFields();
    }
    
}