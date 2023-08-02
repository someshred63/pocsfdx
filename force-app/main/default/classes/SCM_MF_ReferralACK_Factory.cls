public class SCM_MF_ReferralACK_Factory {
private static List<Contact> CRcontactList;
private static List<Contact> CRPrimarycontactList;
private static List<Contact> GATCFcontactList;
private static List<Contact> GATCFPrimarycontactList;

private static List<Contact> CRcontactListH;
private static List<Contact> CRPrimarycontactListH;
private static List<Contact> GATCFcontactListH;
private static List<Contact> GATCFPrimarycontactListH;
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
           c.Address_gne__c From Contact c where  GATCF_Specific_gne__c = true
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
private static Contact getCRContactH(Case Selectedcase)
    {
        if( CRcontactListH == null )
        {
        
            try
            {
                CRcontactListH = [Select c.Phone,c.Name,c.fax, c.Is_Primary_for_gne__c, c.HCP_gne__r.Id, c.HCP_gne__c,
                c.Address_gne__c From Contact c where c.Is_Primary_for_gne__c includes ('C&R') 
                and c.AccountId=:Selectedcase.Referred_By_Party_gne__c and c.Address_gne__c = :SelectedCase.Referral_Address_Line_1_gne__c
                order by c.LastModifiedDate desc LiMIT 500 ];                                           
            }
            catch(Exception ex)
            {
                return null;
            } 
            
            if(CRcontactListH.size()==1)
            {
                return CRcontactListH[0];
            }
            else
                return null;
        }
        else if(CRcontactListH.size()>0)
            return CRcontactListH[0];
        else
            return null;
    }
    
        private static Contact getPrimaryCRContactH(Case Selectedcase)
    {
        if( CRPrimarycontactListH == null )
        {
            try
            {
            CRPrimarycontactListH = [Select c.Phone,c.Name,c.fax,c.Is_Primary_for_gne__c, c.HCP_gne__r.Id, c.HCP_gne__c,
           c.Address_gne__c From Contact c where c.AccountId=:Selectedcase.Referred_By_Party_gne__c and c.C_R_Specific_gne__c = true and c.Address_gne__c = :SelectedCase.Referral_Address_Line_1_gne__c
           order by  c.LastModifiedDate desc  LiMIT 500    ];
              
              }
            catch(Exception ex)
            {
                return null;
            }                                   
                 
            if(CRPrimarycontactListH.size()==1)
            {
                return CRPrimarycontactListH[0];
            }
            else
                return null;
        }
        else if(CRPrimarycontactListH.size()>0)
            return CRPrimarycontactListH[0];
        else
            return null;
    } 
   
           private static Contact getPrimaryGATCFContactH(Case Selectedcase)
    {
        if( GATCFPrimarycontactListH == null )
        {
            try
            { 
            GATCFPrimarycontactListH = [Select c.Phone,c.Name,c.fax,c.Is_Primary_for_gne__c, c.HCP_gne__r.Id, c.HCP_gne__c,
           c.Address_gne__c From Contact c where c.GATCF_Specific_gne__c = true  and GATCF_Specific_gne__c = true and c.Address_gne__c = :SelectedCase.Referral_Address_Line_1_gne__c
           and c.AccountId=:Selectedcase.Referred_By_Party_gne__c
           
           order by  c.LastModifiedDate desc LiMIT 1 ];
             }
            catch(Exception ex)
            {
                return null;
            }                                    
                 
            if(GATCFPrimarycontactListH.size()==1)
            {
                return GATCFPrimarycontactListH[0];
            }
            else
                return null;
        }
        else if(GATCFPrimarycontactListH.size()>0)
            return GATCFPrimarycontactListH[0];
        else
            return null;
    } 
    
           private static Contact getGATCFcontactListH(Case Selectedcase)
    {
        if( GATCFcontactListH == null )
        {
            try
            {
            GATCFcontactListH = [Select c.Phone,c.Name,c.fax, c.Is_Primary_for_gne__c, c.HCP_gne__r.Id, c.HCP_gne__c,
           c.Address_gne__c From Contact c where c.Is_Primary_for_gne__c includes ('GATCF') 
           and c.AccountId=:Selectedcase.Referred_By_Party_gne__c and c.Address_gne__c = :SelectedCase.Referral_Address_Line_1_gne__c
           order by c.LastModifiedDate desc LiMIT 500 ];
               }
            catch(Exception ex)
            {
                return null;
            }                                        
                 
            if(GATCFcontactListH.size()==1)
            {
                return GATCFcontactListH[0];
            }
            else
                return null;
        }
        else if(GATCFcontactListH.size()>0)
            return GATCFcontactListH[0];
        else
            return null;
    } 

    public static SCM_MergeField ReferralPhone(Case Selectedcase)
    {
        SCM_MergeField mf = createMergeField('ReferralPhone_ack');
       try
        {
        	String returnString='';
        
        String recordType = selectedCase.RecordType.Name;
      if (SelectedCase.Referred_By_Type_gne__c == 'Physician/MDO' || SelectedCase.Referred_By_Type_gne__c == 'Nurse Practitioner') {       
    	  
        
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
      else if (SelectedCase.Referred_By_Type_gne__c == 'Hospital'){
           
        	if (recordType.startsWith('C&R'))
        	{
             
            	getCRContactH(Selectedcase);
            	if (CRcontactListH != null && CRcontactListH.SIZE()>=1){
                	returnString=CRcontactListH[0].Phone; 
	            }
             
    	     else
        	    { 
            	   getPrimaryCRContactH(Selectedcase);
               		if (CRPrimarycontactListH != null && CRPrimarycontactListH.Size()>0) {                                 
               			 returnString=CRPrimarycontactListH[0].Phone;
             	 	} 
        	}
         	}else if (recordType.startsWith('GATCF'))
        	{
        	getGATCFContactListH(Selectedcase);
            	if (GATCFcontactListH != null && GATCFcontactListH.SIZE()>=1){
                	returnString=GATCFcontactListH[0].Phone; 
            	}
             
         	else
            { 
               	getPrimaryGATCFContactH(Selectedcase);
            	    if (GATCFPrimarycontactListH != null && GATCFPrimarycontactListH.Size()>0) {                                 
               			 returnString=GATCFPrimarycontactListH[0].Phone;
             	 	} 
        	}	
        	
        	
        	}
        

            	    mf.FieldValue = returnString; 	
            
            
            }
            else {
            	
            	mf.fieldValue = '';
            }
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

    public static SCM_MergeField ReferralFax(Case Selectedcase)
    {
        SCM_MergeField mf = createMergeField('ReferralFax_ack');
       try
        {
        	String returnString='';
        
        String recordType = selectedCase.RecordType.Name;
      if (SelectedCase.Referred_By_Type_gne__c == 'Physician/MDO' || SelectedCase.Referred_By_Type_gne__c == 'Nurse Practitioner') {       
    	  
        
        	if (recordType.startsWith('C&R'))
        	{
             
            	getCRContact(Selectedcase);
            	if (CRcontactList != null && CRcontactList.SIZE()>=1){
                	returnString=CRcontactList[0].Fax; 
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
      else if (SelectedCase.Referred_By_Type_gne__c == 'Hospital'){
           
        	if (recordType.startsWith('C&R'))
        	{
             
            	getCRContactH(Selectedcase);
            	if (CRcontactListH != null && CRcontactListH.SIZE()>=1){
                	returnString=CRcontactListH[0].fax; 
	            }
             
    	     else
        	    { 
            	   getPrimaryCRContactH(Selectedcase);
               		if (CRPrimarycontactListH != null && CRPrimarycontactListH.Size()>0) {                                 
               			 returnString=CRPrimarycontactListH[0].fax;
             	 	} 
        	}
         	}else if (recordType.startsWith('GATCF'))
        	{
        	getGATCFContactListH(Selectedcase);
            	if (GATCFcontactListH != null && GATCFcontactListH.SIZE()>=1){
                	returnString=GATCFcontactListH[0].fax; 
            	}
             
         	else
            { 
               	getPrimaryGATCFContactH(Selectedcase);
            	    if (GATCFPrimarycontactListH != null && GATCFPrimarycontactListH.Size()>0) {                                 
               			 returnString=GATCFPrimarycontactListH[0].fax;
             	 	} 
        	}	
        	
        	
        	}
        

            	    mf.FieldValue = returnString; 	
            
            
            }
            else {
            	
            	mf.fieldValue = '';
            }
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