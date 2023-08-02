public virtual class SCM_MergeDocument_Hotline extends SCM_MergeDocument /*implements IStandardComboBox */{
    
    public Hotline_gne__c selectedHotline{get; set;}
    public virtual override void createMergeFields() 
    {
        this.mergeRecipientInfo.add( new SCM_MF_HotlineID(selectedHotline));
    } 
     
     
    public SCM_MergeDocument_Hotline(String hotLineId,String docLookupId)
    { 
        super(docLookupId);
        List<Hotline_gne__c>hotlineList=[Select h.Asked_Co_Pay_Screening_Questions_gne__c, 
                h.Assigned_Userr_gne__c, h.Caller_First_Name_gne__c, 
                h.Caller_Last_Name_gne__c, h.Caller_Type_gne__c, 
                h.Comments_gne__c, h.Counter_gne__c, h.Diagnosis_gne__c, 
                h.Drug_Type_gne__c, h.Facility_Name_gne__c, h.Id, 
                h.Inquiry_Source_gne__c, h.Inquiry_Type_gne__c, 
                h.MayEdit, h.Name, h.Patient_First_Name_gne__c, 
                h.Patient_Last_Name_gne__c, h.Phone_gne__c, 
                h.Physician_Hospital_gne__c, h.Prefix_gne__c, 
                h.Product_gne__c, h.Related_Case_gne__c, h.Release_gne__c, 
                h.Service_Offered_gne__c, h.Status_gne__c 
        from Hotline_gne__c h  
        where Id=:hotLineId limit 1];
        
        selectedHotline=null;
        if(hotlineList.size()>0)
        	selectedHotline=hotlineList[0];
        selectedObjectId='';
       	selectedObjectNumber='';
       	selectedProduct='';
       	if(selectedHotline!=null)
       	{
       	  selectedObjectId = selectedHotline.Id;	
       	  selectedProduct =  'Hotline';
       	  if(selectedHotline.Name !=null)
       		selectedObjectNumber = selectedHotline.Name;
       	   createMergeFields();
       	   addTypeInfo2MergeList();
       	   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, getXMLString()));
       	}
        else
        {
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'selectedHotline cannot be null!'));
        }
        
    }
    
   
    
    //public override List<SCM_ContactInfo> getContactOptions()
    //{
    //  return new List<SCM_ContactInfo>();
    //}
        
}