public class SCM_MF_PhysicianContactFactory {
private static List<Contact> CRcontactList;
private static List<Contact> CRPrimarycontactList;
private static List<Contact> GATCFcontactList;
private static List<Contact> GATCFPrimarycontactList;
    private static Contact getCRContact(Case Selectedcase)
    {
        if( CRcontactList == null )
        {
        
            try
            {
                CRcontactList = [Select c.Phone,c.Name,c.fax, c.Is_Primary_for_gne__c, c.HCP_gne__r.Id, c.HCP_gne__c,
                c.Address_gne__c From Contact c where c.Is_Primary_for_gne__c includes ('C&R') and c.Address_gne__c=:Selectedcase.Address_gne__c
                and c.HCP_gne__r.Id=:Selectedcase.Case_Treating_Physician_gne__r.Id
                order by c.LastModifiedDate desc LiMIT 500 ];                                           
            }
            catch(Exception ex)
            {
                return null;
            } 
            
            if(CRcontactList.size()==1)
            {
                return CRcontactList[0];
            }
            else
                return null;
        }
        else if(CRcontactList.size()>0)
            return CRcontactList[0];
        else
            return null;
    }
    
        private static Contact getPrimaryCRContact(Case Selectedcase)
    {
        if( CRPrimarycontactList == null )
        {
            try
            {
            CRPrimarycontactList = [Select c.Phone,c.Name,c.fax,c.Is_Primary_for_gne__c, c.HCP_gne__r.Id, c.HCP_gne__c,
           c.Address_gne__c From Contact c where  c.Address_gne__c=:Selectedcase.Address_gne__c
           and c.HCP_gne__r.Id=:Selectedcase.Case_Treating_Physician_gne__r.Id and c.C_R_Specific_gne__c = true
           order by  c.LastModifiedDate desc  LiMIT 500    ];
              
              }
            catch(Exception ex)
            {
                return null;
            }                                   
                 
            if(CRPrimarycontactList.size()==1)
            {
                return CRPrimarycontactList[0];
            }
            else
                return null;
        }
        else if(CRPrimarycontactList.size()>0)
            return CRPrimarycontactList[0];
        else
            return null;
    } 
   
           private static Contact getPrimaryGATCFContact(Case Selectedcase)
    {
        if( GATCFPrimarycontactList == null )
        {
            try
            { 
            GATCFPrimarycontactList = [Select c.Phone,c.Name,c.fax,c.Is_Primary_for_gne__c, c.HCP_gne__r.Id, c.HCP_gne__c,
           c.Address_gne__c From Contact c where c.GATCF_Specific_gne__c = true and c.Address_gne__c=:Selectedcase.Address_gne__c and GATCF_Specific_gne__c = true
           and c.HCP_gne__r.Id=:Selectedcase.Case_Treating_Physician_gne__r.Id
           
           order by  c.LastModifiedDate desc LiMIT 1 ];
             }
            catch(Exception ex)
            {
                return null;
            }                                    
                 
            if(GATCFPrimarycontactList.size()==1)
            {
                return GATCFPrimarycontactList[0];
            }
            else
                return null;
        }
        else if(GATCFPrimarycontactList.size()>0)
            return GATCFPrimarycontactList[0];
        else
            return null;
    } 
    
           private static Contact getGATCFcontactList(Case Selectedcase)
    {
        if( GATCFcontactList == null )
        {
            try
            {
            GATCFcontactList = [Select c.Phone,c.Name,c.fax, c.Is_Primary_for_gne__c, c.HCP_gne__r.Id, c.HCP_gne__c,
           c.Address_gne__c From Contact c where c.Is_Primary_for_gne__c includes ('GATCF') and c.Address_gne__c=:Selectedcase.Address_gne__c
           and c.HCP_gne__r.Id=:Selectedcase.Case_Treating_Physician_gne__r.Id
           order by c.LastModifiedDate desc LiMIT 500 ];
               }
            catch(Exception ex)
            {
                return null;
            }                                        
                 
            if(GATCFcontactList.size()==1)
            {
                return GATCFcontactList[0];
            }
            else
                return null;
        }
        else if(GATCFcontactList.size()>0)
            return GATCFcontactList[0];
        else
            return null;
    } 
    private static SCM_MergeField createMergeField(String key)
    {
        SCM_MergeField mf = new SCM_MergeField();
        mf.key = key;
        mf.checked = false;
        mf.displayCheck = false;
        mf.displayTextBox = false;
        mf.displayLabel = false;
        
        return mf;
    }
    
    public static SCM_MergeField PhysicianContactPhone(Case Selectedcase)
    {
        SCM_MergeField mf = createMergeField('PhysContactPh');
       try
        {
        	String returnString='';
        
        
              
      String recordType = selectedCase.RecordType.Name;
        
        if (recordType.startsWith('C&R'))
        {
             
            getCRContact(Selectedcase);
            if (CRcontactList != null && CRcontactList.SIZE()>=1){
                returnString=CRcontactList[0].Phone; 
            }
             
         else
            { 
               getPrimaryCRContact(Selectedcase);
                if (CRPrimarycontactList != null && CRPrimarycontactList.Size()>0) {                                 
               		 returnString=CRPrimarycontactList[0].Phone;
             	 } 
        }
         }else if (recordType.startsWith('GATCF'))
        {
        getGATCFContactList(Selectedcase);
            if (GATCFcontactList != null && GATCFcontactList.SIZE()>=1){
                returnString=GATCFcontactList[0].Phone; 
            }
             
         else
            { 
               getPrimaryGATCFContact(Selectedcase);
                if (GATCFPrimarycontactList != null && GATCFPrimarycontactList.Size()>0) {                                 
               		 returnString=GATCFPrimarycontactList[0].Phone;
             	 } 
        }	
        	
        	
        }
        

                mf.FieldValue = returnString;
            }
        
        catch(Exception ex)
        {
        	mf.fieldValue = '';
        }

        if(mf.FieldValue==null)
        {
            mf.FieldValue = '';
        }
        return mf;
    }
    
    public static SCM_MergeField PhysicianContactFax(Case Selectedcase)
    {
        SCM_MergeField mf = createMergeField('PhysContactFax');
       
        try
        {
        	String returnString='';
        
        
              
      String recordType = selectedCase.RecordType.Name;
        
        if (recordType.startsWith('C&R'))
        {
             
            getCRContact(Selectedcase);
            if (CRcontactList != null && CRcontactList.SIZE()>=1){
                returnString=CRcontactList[0].fax; 
            }
             
         else
            { 
               getPrimaryCRContact(Selectedcase);
                if (CRPrimarycontactList != null && CRPrimarycontactList.Size()>0) {                                 
               		 returnString=CRPrimarycontactList[0].fax;
             	 } 
        }
         }else if (recordType.startsWith('GATCF'))
        {
        getGATCFContactList(Selectedcase);
            if (GATCFcontactList != null && GATCFcontactList.SIZE()>=1){
                returnString=GATCFcontactList[0].fax; 
            }
             
         else
            { 
               getPrimaryGATCFContact(Selectedcase);
                if (GATCFPrimarycontactList != null && GATCFPrimarycontactList.Size()>0) {                                 
               		 returnString=GATCFPrimarycontactList[0].fax;
             	 } 
        }	
        	
        	
        }
        

                mf.FieldValue = returnString;
            }
        
        catch(Exception ex)
        {
        	mf.fieldValue = '';
        }

        if(mf.FieldValue==null)
        {
            mf.FieldValue = '';
        }
        return mf;
    }
    
    
    public static SCM_MergeField PhysicianContactFax_RECFAX(Case selectedCase)
    {
         SCM_MergeField mf = PhysicianContactFax(selectedCase);
         mf.displayLabel=true;
         mf.displayTextbox=true;
         mf.label = 'Fax:';
         mf.fieldType =  SCM_MergeField.FieldTypes.phoneNumberField;
         mf.key ='RECFAX_Fax';
         
        if(mf.FieldValue==null)
        {
            mf.FieldValue = '';
        }
        return mf;
    }
    
    
    public static SCM_MergeField PhysicianContactFullName(Case Selectedcase)
    {
        SCM_MergeField mf = createMergeField('PhysContactFullName');
        try
        {
        	String returnString='';
        
        
              
      String recordType = selectedCase.RecordType.Name;
        
        if (recordType.startsWith('C&R'))
        {
             
            getCRContact(Selectedcase);
            if (CRcontactList != null && CRcontactList.SIZE()>=1){
                returnString=CRcontactList[0].name; 
            }
             
         else
            { 
               getPrimaryCRContact(Selectedcase);
                if (CRPrimarycontactList != null && CRPrimarycontactList.Size()>0) {                                 
               		 returnString=CRPrimarycontactList[0].name;
             	 } 
        }
         }else if (recordType.startsWith('GATCF'))
        {
        getGATCFContactList(Selectedcase);
            if (GATCFcontactList != null && GATCFcontactList.SIZE()>=1){
                returnString=GATCFcontactList[0].name; 
            }
             
         else
            { 
               getPrimaryGATCFContact(Selectedcase);
                if (GATCFPrimarycontactList != null && GATCFPrimarycontactList.Size()>0) {                                 
               		 returnString=GATCFPrimarycontactList[0].name;
             	 } 
        }	
        	
        	
        }
        

                mf.FieldValue = returnString;
            }
        
        catch(Exception ex)
        {
        	mf.fieldValue = '';
        }

        if(mf.FieldValue==null)
        {
            mf.FieldValue = '';
        }
        return mf;
            }

}