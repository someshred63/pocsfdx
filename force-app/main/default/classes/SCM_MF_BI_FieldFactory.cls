public class SCM_MF_BI_FieldFactory {



 	public static SCM_MergeField AppealContact(Benefit_Investigation_gne__c BI,integer Level)
    {
      SCM_MergeField mf = createMergeField('AppealContact');
      if (BI == null){
      	mf.fieldValue = '';
      	return mf;
      }
       try {
       		if (Level == 1){
       			mf.fieldValue = BI.Contact_Name_Appeal_1_gne__c;
       		}
      		else if (Level == 2){
       			mf.fieldValue = BI.Contact_Name_Appeal_2_gne__c;
       		}
       		else if (Level == 3){
       			mf.fieldValue = BI.Contact_Name_Appeal_3_gne__c;
       		}
       		else if (Level == 4){
       			mf.fieldValue = BI.Contact_Name_Appeal_4_gne__c;
       		}
       	else {
       			mf.fieldValue = '';
       		}
       		if (mf.fieldValue == null){
       			mf.fieldValue = '';	
       		}
       }
       catch(exception e){
       	mf.fieldValue = '';
       }
       return mf;
      }
    
    public static SCM_MergeField AppealPhone(Benefit_Investigation_gne__c BI,integer Level)
    {
      SCM_MergeField mf = createMergeField('AppealPhone');
      if (BI == null){
      	mf.fieldValue = '';
      	return mf;
      }
       try {
       		if (Level == 1){
       			mf.fieldValue = BI.Phone_Appeal_1_gne__c;
       		}
      		else if (Level == 2){
       			mf.fieldValue = BI.Phone_Appeal_2_gne__c;
       		}
       		else if (Level == 3){
       			mf.fieldValue = BI.Phone_Appeal_3_gne__c;
       		}
       		else if (Level == 4){
       			mf.fieldValue = BI.Phone_Appeal_4_gne__c;
       		}
       	else {
       			mf.fieldValue = '';
       		}
       		if (mf.fieldValue == null){
       			mf.fieldValue = '';	
       		}
       }
       catch(exception e){
       	mf.fieldValue = '';
       }
       return mf;
      }
    
     public static SCM_MergeField AppealFax(Benefit_Investigation_gne__c BI,integer Level)
    {
      SCM_MergeField mf = createMergeField('AppealFax');
      if (BI == null){
      	mf.fieldValue = '';
      	return mf;
      }
       try {
       		if (Level == 1){
       			mf.fieldValue = BI.Fax_Appeal_1_gne__c;
       		}
      		else if (Level == 2){
       			mf.fieldValue = BI.Phone_Appeal_2_gne__c;
       		}
       		else if (Level == 3){
       			mf.fieldValue = BI.Fax_Appeal_3_gne__c;
       		}
       		else if (Level == 4){
       			mf.fieldValue = BI.Fax_Appeal_4_gne__c;
       		}
       	else {
       			mf.fieldValue = '';
       		}
       		if (mf.fieldValue == null){
       			mf.fieldValue = '';	
       		}
       }
       catch(exception e){
       	mf.fieldValue = '';
       }
       return mf;
      }
    
     public static SCM_MergeField AppealAttention(Benefit_Investigation_gne__c BI,integer Level)
    {
      SCM_MergeField mf = createMergeField('Attention');
      if (BI == null){
      	mf.fieldValue = '';
      	return mf;
      }
       try {
       		if (Level == 1){
       			mf.fieldValue = BI.Attention_Appeal_1_gne__c;
       		}
      		else if (Level == 2){
       			mf.fieldValue = BI.Attention_Appeal_2_gne__c;
       		}
       		else if (Level == 3){
       			mf.fieldValue = BI.Attention_Appeal_3_gne__c;
       		}
       		else if (Level == 4){
       			mf.fieldValue = BI.Attention_Appeal_4_gne__c;
       		}
       	else {
       			mf.fieldValue = '';
       		}
       		if (mf.fieldValue == null){
       			mf.fieldValue = '';	
       		}
       }
       catch(exception e){
       	mf.fieldValue = '';
       }
       return mf;
      }
    
     public static SCM_MergeField AppealDeadlineCriteria(Benefit_Investigation_gne__c BI,integer Level)
    {
      SCM_MergeField mf = createMergeField('DeadlineCriteria');
      if (BI == null){
      	mf.fieldValue = '';
      	return mf;
      }
       try {
       		if (Level == 1){
       			mf.fieldValue = BI.Appeal_Level_1_Deadline_Criteria_gne__c;
       		}
      		else if (Level == 2){
       			mf.fieldValue = BI.Appeal_Level_2_Deadline_Criteria_gne__c;
       		}
       		else if (Level == 3){
       			mf.fieldValue = BI.Appeal_Level_3_Deadline_Criteria_gne__c;
       		}
       		else if (Level == 4){
       			mf.fieldValue = BI.Appeal_Level_4_Deadline_Criteria_gne__c;
       		}
       	else {
       			mf.fieldValue = '';
       		}
       		if (mf.fieldValue == null){
       			mf.fieldValue = '';	
       		}
       }
       catch(exception e){
       	mf.fieldValue = '';
       }
       return mf;
      }    
    
     public static SCM_MergeField AppealCity(Benefit_Investigation_gne__c BI,integer Level)
    {
      SCM_MergeField mf = createMergeField('AppealCity');
      if (BI == null){
      	mf.fieldValue = '';
      	return mf;
      }
       try {
       		if (Level == 1){
       			mf.fieldValue = BI.City_Appeal_1_gne__c;
       		}
      		else if (Level == 2){
       			mf.fieldValue = BI.City_Appeal_2_gne__c;
       		}
       		else if (Level == 3){
       			mf.fieldValue = BI.City_Appeal_3_gne__c;
       		}
       		else if (Level == 4){
       			mf.fieldValue = BI.City_Appeal_4_gne__c;
       		}
       	else {
       			mf.fieldValue = '';
       		}
       		if (mf.fieldValue == null){
       			mf.fieldValue = '';	
       		}
       }
       catch(exception e){
       	mf.fieldValue = '';
       }
       return mf;
      }    
    
     public static SCM_MergeField AppealState(Benefit_Investigation_gne__c BI,integer Level)
    {
      SCM_MergeField mf = createMergeField('AppealState');
      if (BI == null){
      	mf.fieldValue = '';
      	return mf;
      }
       try {
       		if (Level == 1){
       			mf.fieldValue = BI.State_Appeal_1_gne__c;
       		}
      		else if (Level == 2){
       			mf.fieldValue = BI.State_Appeal_2_gne__c;
       		}
       		else if (Level == 3){
       			mf.fieldValue = BI.State_Appeal_3_gne__c;
       		}
       		else if (Level == 4){
       			mf.fieldValue = BI.State_Appeal_4_gne__c;
       		}
       	else {
       			mf.fieldValue = '';
       		}
       		if (mf.fieldValue == null){
       			mf.fieldValue = '';	
       		}
       }
       catch(exception e){
       	mf.fieldValue = '';
       }
       return mf;
      }   
    
     public static SCM_MergeField ReqdVsVolunatry(Benefit_Investigation_gne__c BI)
    {
      SCM_MergeField mf = createMergeField('ReqdVsVolunatry');
      if (BI == null){
      	mf.fieldValue = '';
      	return mf;
      }
       try {
       		mf.fieldValue = '';
       		
       		
       	if (BI.Prior_Authorization_Required_gne__c == 'Yes'){
       		mf.fieldValue = 'required';
       	}	
       	else {
       		
       	string s = '';
       
       		mf.fieldValue = BI.Is_Pre_D_Required_or_Voluntary_gne__c.toLowerCase();
       		
       	}
       	
       	
       	
       	
       		if (mf.fieldValue == null){
       			mf.fieldValue = '';	
       		}
       }
       catch(exception e){
       	mf.fieldValue = '';
       }
       return mf;
      }   
    
    
    public static SCM_MergeField AppealZip(Benefit_Investigation_gne__c BI,integer Level)
    {
      SCM_MergeField mf = createMergeField('AppealZip');
      if (BI == null){
      	mf.fieldValue = '';
      	return mf;
      }
       try {
       		if (Level == 1){
       			mf.fieldValue = BI.Zip_Appeal_1_gne__c;
       		}
      		else if (Level == 2){
       			mf.fieldValue = BI.Zip_Appeal_2_gne__c;
       		}
       		else if (Level == 3){
       			mf.fieldValue = BI.Zip_Appeal_3_gne__c;
       		}
       		else if (Level == 4){
       			mf.fieldValue = BI.Zip_Appeal_4_gne__c;
       		}
       	else {
       			mf.fieldValue = '';
       		}
       		if (mf.fieldValue == null){
       			mf.fieldValue = '';	
       		}
       }
       catch(exception e){
       	mf.fieldValue = '';
       }
       return mf;
      }   
    
    public static SCM_MergeField AppealLevel1TAT(Benefit_Investigation_gne__c BI,integer Level)
    {
      SCM_MergeField mf = createMergeField('Level1TAT');
      if (BI == null){
      	mf.fieldValue = '';
      	return mf;
      }
       try {
       	              
       		if (Level == 1){
       			mf.fieldValue = BI.Level_1_Estimated_Appeal_TAT_gne__c.format();
       		}
      		else if (Level == 2){
       			mf.fieldValue = BI.Level_2_Estimated_Appeal_TAT_gne__c.format();
       		}
       		else if (Level == 3){
       			mf.fieldValue = BI.Level_3_Estimated_Appeal_TAT_gne__c.format();
       		}
       		else if (Level == 4){
       			mf.fieldValue = BI.Level_4_Estimated_Appeal_TAT_gne__c.format();
       		}
       	else {
       			mf.fieldValue = '';
       		}
       		if (mf.fieldValue == null){
       			mf.fieldValue = '';	
       		}
       }
       catch(exception e){
       	mf.fieldValue = '';
       }
       return mf;
      }   
    
    
    public static SCM_MergeField AppointmentofRepresentative(Benefit_Investigation_gne__c BI)
    {
      SCM_MergeField mf = createMergeField('ApptRep');
      if (BI == null){
      	mf.fieldValue = '';
      	return mf;
      }
       try {
       	              
       		
       		mf.fieldValue = BI.Appointment_of_Representative_gne__c;
       		
       		if (mf.fieldValue == null){
       			mf.fieldValue = '';	
       		}
       }
       catch(exception e){
       	mf.fieldValue = '';
       }
       return mf;
      }   
    
     public static SCM_MergeField AppealComments(Benefit_Investigation_gne__c BI)
    {
      SCM_MergeField mf = createMergeField('AppealComments');
      if (BI == null){
      	mf.fieldValue = '';
      	return mf;
      }
       try {
       	              
       		
       		mf.fieldValue = BI.AOR_Comments_gne__c;
       		
       		if (mf.fieldValue == null){
       			mf.fieldValue = '';	
       		}
       }
       catch(exception e){
       	mf.fieldValue = '';
       }
       return mf;
      }   
    
     public static SCM_MergeField P2Preview(Benefit_Investigation_gne__c BI)
    {
      SCM_MergeField mf = createMergeField('P2Preview');
      if (BI == null){
      	mf.fieldValue = '';
      	return mf;
      }
       try {
       	              
       		
       		mf.fieldValue = BI.Peer_to_Peer_Review_Available_gne__c;
       		
       		if (mf.fieldValue == null){
       			mf.fieldValue = '';	
       		}
       }
       catch(exception e){
       	mf.fieldValue = '';
       }
       return mf;
      }   
      
      public static SCM_MergeField AppealApplicationForm(Benefit_Investigation_gne__c BI)
    {
      SCM_MergeField mf = createMergeField('AppealApplicationForm');
      if (BI == null){
      	mf.fieldValue = '';
      	return mf;
      }
       try {
       		mf.fieldValue = '';
       		
       		
       	if (BI.Appeal_Application_Form_gne__c != null){
       		mf.fieldValue = BI.Appeal_Application_Form_gne__c;
       	}	
       	
       		if (mf.fieldValue == null){
       			mf.fieldValue = '';	
       		}
       }
       catch(exception e){
       	mf.fieldValue = '';
       }
       return mf;
      }   
    
     public static SCM_MergeField ExternalReviewForm(Benefit_Investigation_gne__c BI)
    {
      SCM_MergeField mf = createMergeField('ExternalReviewForm');
      if (BI == null){
      	mf.fieldValue = '';
      	return mf;
      }
       try {
       		mf.fieldValue = '';
       		
       		
       	if (BI.External_Review_Form_gne__c != null){
       		mf.fieldValue = BI.External_Review_Form_gne__c;
       	}	
       	
       		if (mf.fieldValue == null){
       			mf.fieldValue = '';	
       		}
       }
       catch(exception e){
       	mf.fieldValue = '';
       }
       return mf;
      }  
      
 public static SCM_MergeField P2PPhone(Benefit_Investigation_gne__c BI)
    {
      SCM_MergeField mf = createMergeField('P2PPhone');
      if (BI == null){
      	mf.fieldValue = '';
      	return mf;
      }
       try {
       	              
       		
       		mf.fieldValue = BI.Peer_to_Peer_Phone_gne__c;
       		
       		if (mf.fieldValue == null){
       			mf.fieldValue = '';	
       		}
       }
       catch(exception e){
       	mf.fieldValue = '';
       }
       return mf;
      }   

public static SCM_MergeField P2PContact(Benefit_Investigation_gne__c BI)
    {
      SCM_MergeField mf = createMergeField('P2PContact');
      if (BI == null){
      	mf.fieldValue = '';
      	return mf;
      }
       try {
       	              
       		
       		mf.fieldValue = BI.Peer_to_Peer_Contact_Department_gne__c;
       		
       		if (mf.fieldValue == null){
       			mf.fieldValue = '';	
       		}
       }
       catch(exception e){
       	mf.fieldValue = '';
       }
       return mf;
      } 
    
    public static SCM_MergeField P2PTAT(Benefit_Investigation_gne__c BI)
    {
      SCM_MergeField mf = createMergeField('P2PTAT');
      if (BI == null){
      	mf.fieldValue = '';
      	return mf;
      }
       try {
       	              
       		
       		mf.fieldValue = BI.Peer_to_Peer_Estimated_TAT_gne__c;
       		
       		if (mf.fieldValue == null){
       			mf.fieldValue = '';	
       		}
       }
       catch(exception e){
       	mf.fieldValue = '';
       }
       return mf;
      } 
 
 public static SCM_MergeField P2PComments(Benefit_Investigation_gne__c BI)
    {
      SCM_MergeField mf = createMergeField('P2PComments');
      if (BI == null){
      	mf.fieldValue = '';
      	return mf;
      }
       try {
       	              
       		
       		mf.fieldValue = BI.Peer_to_Peer_Comments_gne__c;
       		
       		if (mf.fieldValue == null){
       			mf.fieldValue = '';	
       		}
       }
       catch(exception e){
       	mf.fieldValue = '';
       }
       return mf;
      }    
    
    public static SCM_MergeField AppealAddress(Benefit_Investigation_gne__c BI,integer Level)
    {
      SCM_MergeField mf = createMergeField('AppealAddress');
      if (BI == null){
      	mf.fieldValue = '';
      	return mf;
      }
       try {
       		if (Level == 1){
       			if (BI.AddrLine1_Appeal_1_gne__c != null && BI.AddrLine1_Appeal_1_gne__c !=''){
   					mf.fieldValue = BI.AddrLine1_Appeal_1_gne__c + ' ';    				
       			}
       			if (BI.AddrLine2_Appeal_1_gne__c != null && BI.AddrLine2_Appeal_1_gne__c !=''){
   					mf.fieldValue += BI.AddrLine2_Appeal_1_gne__c;    				
       			}
       			
       		}
      		else if (Level == 2){
       			if (BI.AddrLine1_Appeal_2_gne__c != null && BI.AddrLine1_Appeal_2_gne__c !=''){
   					mf.fieldValue = BI.AddrLine1_Appeal_2_gne__c + ' ';    				
       			}
       			if (BI.AddrLine2_Appeal_2_gne__c != null && BI.AddrLine2_Appeal_2_gne__c !=''){
   					mf.fieldValue += BI.AddrLine2_Appeal_2_gne__c;    				
       			}
       		}
       		else if (Level == 3){
       			if (BI.AddrLine1_Appeal_3_gne__c != null && BI.AddrLine1_Appeal_3_gne__c !=''){
   					mf.fieldValue = BI.AddrLine1_Appeal_3_gne__c + ' ';    				
       			}
       			if (BI.AddrLine2_Appeal_3_gne__c != null && BI.AddrLine2_Appeal_3_gne__c !=''){
   					mf.fieldValue += BI.AddrLine2_Appeal_3_gne__c;    				
       			}
       		}
       		else if (Level == 4){
       			if (BI.AddrLine1_Appeal_4_gne__c != null && BI.AddrLine1_Appeal_4_gne__c !=''){
   					mf.fieldValue = BI.AddrLine1_Appeal_4_gne__c + ' ';    				
       			}
       			if (BI.AddrLine2_Appeal_4_gne__c != null && BI.AddrLine2_Appeal_4_gne__c !=''){
   					mf.fieldValue += BI.AddrLine2_Appeal_4_gne__c;    				
       			}
       		}
       	else {
       			mf.fieldValue = '';
       		}
       		if (mf.fieldValue == null){
       			mf.fieldValue = '';	
       		}
       }
       catch(exception e){
       	mf.fieldValue = '';
       }
       return mf;
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
}