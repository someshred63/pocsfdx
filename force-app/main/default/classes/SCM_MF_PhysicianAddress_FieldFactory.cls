public class SCM_MF_PhysicianAddress_FieldFactory {
	 private static List<Address_vod__c> physicianAddressList;
	 private static List<Address_vod__c> caseAddressList;
	 private static Address_vod__c physicianAddress;
	  private static Address_vod__c caseAddress;
	 
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
     
	 private static List<Address_vod__c> getPhysicianAddressList(String physicianId) {
        if(physicianAddressList==null)
        {
        	try
        	{
         physicianAddressList = [Select a.Zip_vod__c, a.Zip_4_vod__c, 
         								a.Wait_Time_gne__c, a.Wait_List_gne__c, 
         								a.UNKNOWN_gne__c, a.Toll_Free_gne__c, 
         								a.Third_Party_gne__c, a.Third_Party_Index_gne__c, 
         								a.Third_Party_Id_gne__c, a.TLX_Address_Id_gen__c, 
         								a.Status_gne__c, a.State_vod__c, 
         								a.Staff_notes_vod__c, a.Special_instructions_gne__c, 
         								a.Source_vod__c, a.Shipping_vod__c, 
         								a.Service_Quality_Survey_Offered_Date_gne__c, 
         								a.Satellite_gne__c, a.Sample_Status_vod__c, 
         								a.SOLD_TO_gne__c, a.SAP_ID_gne__c, a.RecordTypeId, 
         								a.Proactive_BI_Opt_In_gne__c, a.Primary_vod__c, 
         								a.Practice_Type_gne__c, a.Practice_Size_gne__c, 
         								a.Phone_vod__c, a.Phone_2_vod__c, a.Phone_2_Ext_gne__c, 
         								a.Phone_1_Ext_gne__c, a.Operating_Hours_Start_gne__c, 
         								a.Operating_Hours_End_gne__c, a.Office_gne__c, 
         								a.Office_Notes_vod__c, a.Offered_To_gne__c,  a.Name, 
         								a.Mobile__c, a.MayEdit, a.Map_vod__c, a.Mailing_vod__c, 
         								a.MDM_GLID_gne__c, a.MDM_Address_ID_gne__c, a.Longitude_vod__c, 
         								a.Location_Specific_Preferences_gne__c, a.License_vod__c, 
         								a.License_Valid_To_Sample_vod__c, a.License_Status_vod__c, 
         								a.License_Expiration_Date_vod__c, a.Latitude_vod__c, 
         								a.LastModifiedDate,  a.IsLocked,
         								a.Injection_Training_gne__c, a.Infusion_Services_gne__c, 
         								a.Infusion_Hours_Start_gne__c, a.Infusion_Hours_End_gne__c, 
         								a.Infusion_Chairs_gne__c, a.Include_in_Territory_Assignment_vod__c, 
         								a.Inactive_vod__c, a.Inactivate_User_gne__c, 
         								a.Inactivate_Reason_gne__c, a.Inactivate_Count_gne__c, 
         								a.Id, a.Hospital_gne__c, a.Home_vod__c, 
         								a.Genentech_Product_Experience_gne__c, 
         								a.Gatekeeper_gne__c, a.GOLD_RECORD_gne__c, 
         								a.Fax_vod__c, a.Fax_2_vod__c, a.FORWARD_TO_gne__c, 
         								a.External_ID_vod__c, a.Email_gne__c,  
         								a.Date_Last_Offered_gne__c, a.Date_Inactive_gne__c, 
         								a.Data_Source_gne__c, a.DEA_vod__c, a.DEA_gne__c, 
         								a.DEA_License_Address_vod__c, a.DEA_Expiration_Date_vod__c, 
         								a.CreatedDate, a.CreatedById, a.Country_gen__c, a.Comment_vod__c, 
         								a.Clinic_gne__c, a.City_vod__c, a.Choose_to_Take_Survey_gne__c, 
         								a.Buy_and_Bill_gne__c, a.Business_vod__c, a.Billing_vod__c, 
         								a.Best_Times_vod__c, a.BI_Interval_gne__c, a.Appt_Required_vod__c, 
         								a.Appointment_Type_gne__c,  a.Address_line_2_vod__c, a.Address_Type_gne__c, 
         								a.Address_Line_4_gne__c, a.Address_Line_3_gne__c, a.Address_1_gne__c, 
         								a.Account_vod__c, a.Accepting_New_Patients_gne__c, 
         								a.AMS_gold_record_gne__c, a.AIC_Services_gne__c, 
         								a.AIC_Instructions_gne__c 
         						from Address_vod__c a      
         						Where a.Account_vod__c = :physicianId  order by a.LastModifiedDate desc limit 100];
        	}
        	catch(Exception ex)
        	{
        		return null;
        	}
        }       
        
		return physicianAddressList;
    }
    
    private static Address_vod__c getPhysicianAddress(String physicianId) 
    {
        if(physicianAddress==null)
        {
        	if(getPhysicianAddressList(physicianId)!=null)
        	{
        		if(physicianAddressList.size()>=1)
            		physicianAddress= physicianAddressList[0];
        		else 
        			physicianAddress = null;            
        	}
        }
        
        return physicianAddress;
    }
    
    private static List<Address_vod__c> getCaseAddressList(String caseId)
    {
    	if(caseAddressList == null)
    	{
    		try
    		{
    			String strcaseAddress = [Select c.Address_gne__c From Case c where c.Id= :caseId].Address_gne__c;
    			//'500S0000000gnsZ'    			
    			
    			caseAddressList = [Select a.Zip_vod__c,
    									  a.State_vod__c,
    									  a.Id, a.City_vod__c,
    									  a.Address_line_2_vod__c, 
    									  a.Name,
    									  a.Address_1_gne__c, 
    									  a.Account_vod__c 
    									  From Address_vod__c a where a.Id =:strcaseAddress
    									  order by a.LastModifiedDate desc limit 100];
    		}
    		catch(Exception ex)
    		{
    			//'a01S0000000GEsvIAG' 
    			return null;
    		}
    	}
    		return caseAddressList;    	
    }
    
    private static Address_vod__c getCaseAddress(String caseId) 
    {
        if(caseAddress==null)
        {
        	if(getCaseAddressList(caseId)!=null)
        	{
        		if(caseAddressList.size()>=1)
            		caseAddress= caseAddressList[0];
        		else 
        			caseAddress = null;            
        	}
        }        
        return caseAddress;
    }
    
        public static List<SCM_MergeField> GetAll(string CaseId) {
    
    	List<SCM_MergeField> Fields = new List<SCM_MergeField>();
    	fields.add(PhysicianAddress_Street(caseid));
    	fields.add(PhysicianAddress_CityStateZip(caseid));
    	fields.add(PhysicianAddress_City(caseid));
    	fields.add(PhysicianAddress_State(caseid));
    	fields.add(PhysicianAddress_Zip(caseid));
    	return Fields;
    	
    }
    
    //public static SCM_MergeField PhysicianAddress_Street(String physicianId)
    public static SCM_MergeField PhysicianAddress_Street(String caseId)
    {
    	SCM_MergeField mf = createMergeField('PhysicianStreetAddrs');
    	mf.fieldValue='';
    	try {
    	if(getCaseAddress(caseId)!= null)
        {
        	if(caseAddress.Name!=null)
        		mf.fieldValue = caseAddress.Name;
        }
    	
    	/**
    	if(getPhysicianAddress(physicianId)!= null)
        {
        	if(physicianAddress.Name!=null)
        		mf.fieldValue = physicianAddress.Name;
        }
        */
         }catch (exception ex){
    mf.fieldValue = '';	
    }
        return mf;
    }
    
    //public static SCM_MergeField PhysicianAddress_CityStateZip(String physicianId)   
    public static SCM_MergeField PhysicianAddress_CityStateZip(String caseId)
    {
    	SCM_MergeField mf = createMergeField('PhyCityStateZip');
    	mf.fieldValue='';
    try {	
    	
    	if(getCaseAddress(caseId)!= null)
        {
        	if(caseAddress.City_vod__c!=null)
        		mf.fieldValue += caseAddress.City_vod__c + ' ';
        	if(caseAddress.State_vod__c!=null)
        		mf.fieldValue += caseAddress.State_vod__c + ' ';
        	if(caseAddress.Zip_vod__c!=null)
        		mf.fieldValue += caseAddress.Zip_vod__c;
        }
    	/**
    	if(getPhysicianAddress(physicianId)!= null)
        {
        	if(physicianAddress.City_vod__c!=null)
        		mf.fieldValue += physicianAddress.City_vod__c + ' ';
        	if(physicianAddress.State_vod__c!=null)
        		mf.fieldValue += physicianAddress.State_vod__c + ' ';
        	if(physicianAddress.Zip_vod__c!=null)
        		mf.fieldValue += physicianAddress.Zip_vod__c;
        }
        */
         }catch (exception ex){
    mf.fieldValue = '';	
    }
        return mf;
    }
    
    //public static SCM_MergeField PhysicianAddress_City(String physicianId)  
    public static SCM_MergeField PhysicianAddress_City(String caseId)
    {
    	SCM_MergeField mf = createMergeField('PhyCity');
    	mf.fieldValue='';
    	
    	try {
    	if(getCaseAddress(caseId)!= null)
        {
        	if(caseAddress.City_vod__c!=null)
        		mf.fieldValue = caseAddress.City_vod__c;
        }
    	/**
    	if(getPhysicianAddress(physicianId)!= null)
        {
        	if(physicianAddress.City_vod__c!=null)
        		mf.fieldValue = physicianAddress.City_vod__c;
        }
        */
         }catch (exception ex){
    mf.fieldValue = '';	
    }
        return mf;
    }

    //public static SCM_MergeField PhysicianAddress_State(String physicianId)
    public static SCM_MergeField PhysicianAddress_State(String caseId)  
    {
    	SCM_MergeField mf = createMergeField('PhyState');
    	mf.fieldValue='';
    try {	
    	if(getCaseAddress(caseId)!= null)
        {
        	if(caseAddress.State_vod__c!=null)
        		mf.fieldValue = caseAddress.State_vod__c;
        }
    	
    	/**
    	if(getPhysicianAddress(physicianId)!= null)
        {
        	if(physicianAddress.State_vod__c!=null)
        		mf.fieldValue = physicianAddress.State_vod__c;
        }
        */
         }catch (exception ex){
    mf.fieldValue = '';	
    }
        return mf;
    }

    //public static SCM_MergeField PhysicianAddress_Zip(String physicianId)
    public static SCM_MergeField PhysicianAddress_Zip(String caseId)  
     {
    	SCM_MergeField mf = createMergeField('PhyZip');
    	mf.fieldValue='';
    	try {
    	if(getCaseAddress(caseId)!= null)
        {
        	if(caseAddress.Zip_vod__c!=null)
        		mf.fieldValue = caseAddress.Zip_vod__c;
        }
        /**
    	if(getPhysicianAddress(physicianId)!= null)
        {
        	if(physicianAddress.Zip_vod__c!=null)
        		mf.fieldValue = physicianAddress.Zip_vod__c;
        }
        */
         }catch (exception ex){
    mf.fieldValue = '';	
    }
        return mf;
    }
    
}