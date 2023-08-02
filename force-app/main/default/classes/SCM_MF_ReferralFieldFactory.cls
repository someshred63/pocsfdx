public class SCM_MF_ReferralFieldFactory {
    private static SCM_MergeField createMergeField(String key) {
        SCM_MergeField mf = new SCM_MergeField();
        mf.key = key;
        mf.checked = false;
        mf.displayCheck = false;
        mf.displayTextBox = false;
        mf.displayLabel = false;
        mf.fieldValue =''; 
        return mf;
    }

    private static List<Account> accountList;
    private static List<Address_vod__c> addressList;
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
                c.Address_gne__c From Contact c where c.Is_Primary_for_gne__c includes ('C&R') 
                and c.HCP_gne__r.Id=:Selectedcase.Referred_By_Party_gne__c and c.Address_gne__c = :SelectedCase.Referral_Address_Line_1_gne__c
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
           c.Address_gne__c From Contact c where C_R_Specific_gne__c = true and c.HCP_gne__r.Id=:Selectedcase.Referred_By_Party_gne__c and c.C_R_Specific_gne__c = true and c.Address_gne__c = :SelectedCase.Referral_Address_Line_1_gne__c
           order by  c.LastModifiedDate desc  LiMIT 500       ];
              
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
           c.Address_gne__c From Contact c where c.GATCF_Specific_gne__c = true  and GATCF_Specific_gne__c = true
           and c.HCP_gne__r.Id=:Selectedcase.Referred_By_Party_gne__c and c.Address_gne__c = :SelectedCase.Referral_Address_Line_1_gne__c
           
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
           c.Address_gne__c From Contact c where c.Is_Primary_for_gne__c includes ('GATCF') 
           and c.HCP_gne__r.Id=:Selectedcase.Referred_By_Party_gne__c and c.Address_gne__c = :SelectedCase.Referral_Address_Line_1_gne__c
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
    
    private static Address_vod__c getAddress(Case selectedCase) {
        if (addressList == null) {
            try
            {           
            addressList = [Select a.Address_1_gne__c, a.Address_line_2_vod__c,
                a.City_vod__c, a.State_vod__c, a.Zip_vod__c, a.Name
                From Address_vod__c a
                Where a.Id = :selectedCase.Referral_Address_Line_1_gne__c
                And a.Account_vod__c = :selectedCase.Referred_By_Party_gne__c];
            }
            catch(Exception ex)
            {
                addressList=null;
            }
        }
        
        if (!addressList.isEmpty())
            return addressList[0];
        else
            return null;
    }
    
    public static SCM_MergeField ReferralOffice(Case selectedCase) {
        SCM_MergeField mf = createMergeField('ReferralOffice');
        try {
        String referredBy = selectedCase.Referred_By_Party_gne__c;
        
        if (accountList == null) {
            accountList = [Select a.Name from Account a
                Where a.Id = :referredBy];
        }
            
        if (!accountList.isEmpty()) {
            mf.fieldValue = accountList[0].Name ==null?'':accountList[0].Name;
            if (mf.fieldValue == null)
                mf.fieldValue = '';
        }   
         }
        catch (exception ex){
        mf.fieldvalue = '';	
        }
        return mf;
    }
    
    public static SCM_MergeField ReferralAttn(Case selectedCase) {
        SCM_MergeField mf = createMergeField('ReferralAttn');
        String recordType = selectedCase.RecordType.Name;
        try {
        mf.fieldValue = '';
        String refType = selectedCase.Referred_By_Type_gne__c;
        
        
        if (refType == null)
            mf.fieldValue = '';
       
        else if (refType.equals('Physician/MDO') || refType.equals('Nurse Practitioner'))
        {        if (recordType.startsWith('C&R'))
        {
            getCRContact(Selectedcase);                                                
            if(CRcontactList.size()>=1)
            {
             mf.fieldValue=CRcontactList[0].name; 
            } 
            else if(CRcontactList.size()==0)
            {
               getPrimaryCRContact(Selectedcase);
                                                  
               if(CRPrimarycontactList.size()==0)
               {
                //do nothing
               } 
               else
               {                                  
                mf.fieldValue=CRPrimarycontactList[0].name; 
               }
            
            }
        }
        else if (recordType.startsWith('GATCF'))
        {
        	System.debug('in GATCF');
            getGATCFcontactList(Selectedcase);
                                                  
            if(GATCFcontactList.size()>=1)
            {
            	System.debug('size >= 1');
             mf.fieldValue=GATCFcontactList[0].name; 
            } 
            else if(GATCFcontactList.size()==0)
            {
               System.debug('size = 0');
               getPrimaryGATCFContact(Selectedcase); 
                                                  
               if(GATCFPrimarycontactList.size()==0)
               {
                //do nothing
               } 
               else
               {                                  
                mf.fieldValue=GATCFPrimarycontactList[0].name; 
               }
            
            }
            
        }

        
		        }
		        else if (refType.equals('Hospital')) {
		            mf.fieldValue = selectedCase.Referred_By_Person_gne__c;
		            if (mf.fieldValue == null)
		                mf.fieldValue = '';
		        }
        
        
              }
        catch (exception ex){
        mf.fieldvalue = '';	
        }    
        
        return mf;

    }
    
    public static SCM_MergeField ReferralStAddress(Case selectedCase) {
        SCM_MergeField mf = createMergeField('ReferralStAddress');
        try {
        mf.fieldValue = '';
        String refType = selectedCase.Referred_By_Type_gne__c;
        if (refType == null)
            mf.fieldValue = '';
        else if (refType.equals('Physician/MDO') || refType.equals('Nurse Practitioner') || refType.equals('Hospital')) {
            Address_vod__c address = getAddress(selectedCase);
            if (address != null) {
                mf.fieldValue = address.Name == null?'':address.Name; //changed from Address_1_gne__c;
                if (mf.fieldValue == null)
                    mf.fieldValue = '';
            }
        }
         }
        catch (exception ex){
        mf.fieldvalue = '';	
        }
        return mf;
    }
    
    public static SCM_MergeField ReferralSuiteFlUnit(Case selectedCase) {
        SCM_MergeField mf = createMergeField('ReferralSuiteFlUnit');
        try {
        mf.fieldValue = '';
        String refType = selectedCase.Referred_By_Type_gne__c;
        if (refType == null)
            mf.fieldValue = '';
        else if (refType.equals('Physician/MDO') || refType.equals('Nurse Practitioner') || refType.equals('Hospital')) {
            Address_vod__c address = getAddress(selectedCase);
            if (address != null) {
                mf.fieldValue = address.Address_line_2_vod__c == null?'':address.Address_line_2_vod__c;
                if (mf.fieldValue == null)
                    mf.fieldValue = '';
            }
        }
         }
        catch (exception ex){
        mf.fieldvalue = '';	
        }
        return mf;

    }
    
    public static SCM_MergeField ReferralCityStateZip(Case selectedCase) {
        SCM_MergeField mf = createMergeField('ReferralCityStateZip');
        try {
        mf.fieldValue = '';
        String refType = selectedCase.Referred_By_Type_gne__c;
        if (refType == null)
            mf.fieldValue = '';
        else if (refType.equals('Physician/MDO') || refType.equals('Nurse Practitioner') || refType.equals('Hospital')) {
            Address_vod__c address = getAddress(selectedCase);
            if (address != null) {
                String city = address.City_vod__c;
                String state = address.State_vod__c;
                String zip = address.Zip_vod__c;
                
                if (city == null)
                    city = '';
                if (state == null)
                    state = '';
                if (zip == null)
                    zip = '';
                    
                mf.fieldValue = city + ' ' + state + ' ' + zip;
            }
        }
         }
        catch (exception ex){
        mf.fieldvalue = '';	
        }
        return mf;
    }
    
    public static SCM_MergeField ReferredDate(Case selectedCase) {
        SCM_MergeField mf = createMergeField('RefDate');
        try {
        if(selectedCase.Referred_By_Date_gne__c != null)
        {
            mf.fieldValue = selectedCase.Referred_By_Date_gne__c==null?'':selectedCase.Referred_By_Date_gne__c.format();
        }
             }
        catch (exception ex){
        mf.fieldvalue = '';	
        }
        return mf;
    }
    
     public static SCM_MergeField ReferredBy(Case selectedCase) {
        SCM_MergeField mf = createMergeField('ReferredBy');
        try {
        	if(selectedCase.Referred_By_Party_gne__c != null)
        	{
        		Account act = [select Name from Account where id = :selectedCase.Referred_By_Party_gne__c Limit 1];
        		
            	mf.fieldValue = act.Name;
        	}
        	else if(selectedCase.Referred_By_Person_gne__c != null){
        		mf.fieldValue = selectedCase.Referred_By_Person_gne__c;
       		}
        }
        catch (exception ex){
        mf.fieldvalue = '';	
        }
        return mf;
    }
}