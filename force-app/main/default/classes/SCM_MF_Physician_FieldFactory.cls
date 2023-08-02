public class SCM_MF_Physician_FieldFactory {

    private static Contact contact;
    private static Account Addressee;
    private static ProfileID_License_gne__c profileId;
    private static List<ProfileID_License_gne__c> phyProfileLicenseIdList;
    private static List<ProfileID_License_gne__c> phyTaxIdList;
   
    private static Contact getPhysician(String physicianId)
    {
        if( contact == null )
        {
            try{
                contact = [Select c.Id,
                               c.HCP_gne__r.FirstName,
                               c.HCP_gne__r.Fax
                               From Contact c
                               where c.HCP_gne__r.Primary_Contact_gne__pc = true 
                               and c.HCP_gne__r.Id=:physicianId Limit 1];
                
                return contact;
            }catch(Exception e){
                return null;
            }      
        }
        return contact;
    }
    
        public static List<SCM_MergeField> GetAllNames(string physicianId) {
    
    	List<SCM_MergeField> Fields = new List<SCM_MergeField>();
    	fields.add(PhysicianLastName(physicianId));
    	fields.add(PhysicianFirstName(physicianId));
    	fields.add(PhysicianFirstMidAndLastName(physicianId));
    	fields.add(PhysicianFirstLastName(physicianId));
    	fields.add(PhysicianFirstLastName(physicianId));
    	
    	return Fields;
    	
    }
    
    
    private static ProfileID_License_gne__c getProfileId(String physicianId)
    {
        if (profileId == null)
        {
            phyProfileLicenseIdList = [select p.ID_License_gne__c from  ProfileID_License_gne__c p     
                        where p.Account_Name_gne__c=:physicianId                        
                        and p.ID_License_Type_gne__c = 'DEA #'  order by p.LastModifiedDate desc limit 1];
                    
        }
        if (!phyProfileLicenseIdList.isEmpty())
            profileId =  phyProfileLicenseIdList[0];
        else
            profileId =  null;
            
            
        return profileId ;
    }
    
    private static ProfileID_License_gne__c getProfileLicenseID(String physicianId)
    {
        try {
            if (phyProfileLicenseIdList == null)
            {   
            phyProfileLicenseIdList = [Select p.Id, p.ID_License_gne__c, 
                p.State_gne__c, p.Release_gne__c, p.Name,  p.ID_License_Type_gne__c, p.Address_gne__c, 
                p.Account_Type_gne__c, p.Account_Name_gne__c , p.LastModifiedDate
                From ProfileID_License_gne__c p
                where p.Account_Name_gne__c =: physicianId and p.ID_License_Type_gne__c in ('State License')
                order by  p.LastModifiedDate desc
                limit 1];
            }
    
            if (!phyProfileLicenseIdList.isEmpty()) {
                profileId = phyProfileLicenseIdList[0];
                return profileId;
            }
            else
                return null;
        }
        catch (Exception e) {
            return null;
        }
        
    }
    
    private static ProfileID_License_gne__c getTaxID(String physicianId)
    {
        try {
            if (phyTaxIdList == null)
            {
            phyTaxIdList = [Select p.ID_License_gne__c, 
                p.ID_License_Type_gne__c, p.LastModifiedDate
                From ProfileID_License_gne__c p
                where p.Account_Name_gne__c =: physicianId and p.ID_License_Type_gne__c in ('Tax ID')
                order by  p.LastModifiedDate desc
                limit 1];
            }
    
            if (!phyTaxIdList.isEmpty()) {
                profileId = phyTaxIdList[0];
                return profileId;
            }
            else
                return null;
        }
        catch (Exception e) {
            return null;
        }
    }    
    
    private static Account getAddressee(String physicianId)
    {
        if( Addressee == null )
        {
            try{
                Addressee = [Select a.Middle_vod__c,
                                a.LastName,
                                a.FirstName,
                                a.Phone,
                                a.Fax,
                                a.Title_gne__pc,
                                a.PersonTitle
                                from Account a
                                where a.Id = :physicianId];
           
                return Addressee;
            }catch(Exception e){
                System.debug('Inside Catch of getAddressee...');
                return null;
            }
          }
        return Addressee;
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
    
    public static SCM_MergeField ATTN_PhysicianContactName(String physicianId)
    {
        SCM_MergeField mf = createMergeField('ATTN_Attn');
        try {
        if( null != getPhysician(physicianId) )
        {
            mf.fieldValue = getPhysician(physicianId).HCP_gne__r.FirstName;
        }
        mf.displayTextBox = true;
        mf.displayLabel = true;
        mf.label='Attn:';
        }catch (exception ex){
    mf.fieldValue = '';	
    }
        return mf;
    }
    
    public static SCM_MergeField PhysicianLastName(String physicianId)
    {
        SCM_MergeField mf = createMergeField('Physician Last Name');
        mf.fieldValue='';
        if( null != getAddressee(physicianId) && getAddressee(physicianId).LastName!=null )
        {
            mf.fieldValue = getAddressee(physicianId).LastName;
        }
        
        mf.displayCheck = false;
        mf.displayTextBox = false;
        mf.displayLabel = false; 
        return mf;
    }
     public static SCM_MergeField PhysicianFirstName(String physicianId)
    {
        SCM_MergeField mf = createMergeField('Physician First Name');
        mf.fieldValue='';
        if( null != getAddressee(physicianId) && getAddressee(physicianId).FirstName!=null )
        {
        	
        
            mf.fieldValue = getAddressee(physicianId).FirstName;
        }
        
        mf.displayCheck = false;
        mf.displayTextBox = false;
        mf.displayLabel = false; 
        return mf;
    }
    public static SCM_MergeField PhysicianFirstMidAndLastName(String physicianId)
    {   
        String fullName='';
        SCM_MergeField mf = createMergeField('RECNAME_To');
try {
        if( null != getAddressee(physicianId) )
        {
            fullName = (getAddressee(physicianId).FirstName == null)? '': getAddressee(physicianId).FirstName;
            if (getAddressee(physicianId).Middle_vod__c != null){
                fullName = fullName + ' ' + getAddressee(physicianId).Middle_vod__c;
            }
            fullName = fullName + ' ' + ((getAddressee(physicianId).LastName == null)? '': getAddressee(physicianId).LastName) ;    
            if(fullName.Trim() != ''){
                 fullName = fullName + ', M.D.' ;
            }       
        }
        
        mf.fieldValue = fullName;
        }catch (exception ex){
    mf.fieldValue = '';	
    }
     
     
        mf.displayTextBox = true;
        mf.displayLabel = true;
        mf.label='Addressed To:';
     
        return mf;
    }
    public static SCM_MergeField PhysicianFirstLastName(String physicianId)
    {   
        String phyName='';
        SCM_MergeField mf = createMergeField('Physician First Last Name');
        try {
        if( null != getAddressee(physicianId) )
        {
              if(Addressee.LastName != null)
            {
                phyName= Addressee.LastName ;               
            }
            if(Addressee.FirstName != null )
            {
                phyName=Addressee.FirstName;        
            }
            if(Addressee.FirstName != null && Addressee.LastName != null )
            {
                phyName=Addressee.FirstName + ' ' + Addressee.LastName  ;      
            }
    mf.fieldValue = phyName;
        }
        
        mf.fieldValue = phyName;
         }catch (exception ex){
    mf.fieldValue = '';	
    }
        return mf;
    }
    
    
     public static SCM_MergeField PhysicianFirstLastName_Textbox(String physicianId)
    {
       SCM_MergeField mf= PhysicianFirstLastName(physicianId);
       mf.displayTextBox = true;
       mf.displayLabel = true;
       mf.key = 'RECNAME';
       mf.label='Addressed To:';
       return mf;
    }

    public static SCM_MergeField PhysicianFirstMidAndLastName_Invisible(String physicianId)
    {   
        String fullName='';
        SCM_MergeField mf = createMergeField('PhysicianFullName');
        try {
        if( null != getAddressee(physicianId) )
        {
            fullName = (getAddressee(physicianId).FirstName == null)? '': getAddressee(physicianId).FirstName;
            if (getAddressee(physicianId).Middle_vod__c != null){
                fullName = fullName + ' ' + getAddressee(physicianId).Middle_vod__c;
            }
            fullName = fullName + ' ' + ((getAddressee(physicianId).LastName == null)? '': getAddressee(physicianId).LastName) ;    
            if(fullName.Trim() != ''){
                 fullName = fullName + ', M.D.' ;
            }       
        }
        
        mf.fieldValue = fullName;
        mf.displayTextBox = false;
        mf.displayLabel = false;
         }catch (exception ex){
    mf.fieldValue = '';	
    }
        return mf;
    }
    
    public static SCM_MergeField PhysicianFax(String physicianId)
    {
        SCM_MergeField mf = createMergeField('RECFAX_Fax');
        try {
        if( null != getPhysician(physicianId) )
        {
            mf.fieldValue = getPhysician(physicianId).HCP_gne__r.Fax;
        }
        mf.displayTextBox = true;
        mf.displayLabel = true;
        mf.label='Fax:';
        mf.totalWidth = '270';
        mf.width = '150';
        mf.fieldType = SCM_MergeField.FieldTypes.phoneNumberField;
         }catch (exception ex){
    mf.fieldValue = '';	
    }
        
        return mf;
    }
    
    public static SCM_MergeField PhysicianTitle(String physicianId) {
        String title = '';
        SCM_MergeField mf = createMergeField('PhysicianTitle');
        try {
        if( null != getAddressee(physicianId) )
        {
            title = (getAddressee(physicianId).PersonTitle == null)? '': getAddressee(physicianId).PersonTitle;
        }
        
        mf.fieldValue = title;
        mf.displayTextBox = false;
        mf.displayLabel = false;
         }catch (exception ex){
    mf.fieldValue = '';	
    }
        return mf;   
    }
    
    public static SCM_MergeField PhysicianDEA(String physicianId)
    {
        SCM_MergeField mf = createMergeField('Physician DEA');
        mf.fieldValue = '';
        try {
        if (getProfileId(physicianId) != null)
        {
            
            mf.fieldValue = profileId.ID_License_gne__c;                        
            if (mf.fieldValue == null)
                mf.fieldValue = '';
        }
         }catch (exception ex){
    mf.fieldValue = '';	
    }
        return mf;
    }
     public static SCM_MergeField ProfileLicenceID(String physicianId)
    {
        SCM_MergeField mf = createMergeField('Physician Profile Luncentis');
        mf.fieldValue = '';
     try {   
        if(getProfileLicenseID(physicianId) != null)
        {
            mf.fieldValue = profileId.ID_License_gne__c;
            if (mf.fieldValue == null)
                mf.fieldValue = '';
        }
      }catch (exception ex){
    mf.fieldValue = '';	
    }
        return mf;
    }
    
     public static SCM_MergeField TaxID(String physicianId) {
        SCM_MergeField mf = createMergeField('Physician Tax Id');
        mf.fieldValue = '';
        try {
        if(getTaxID(physicianId) != null)
        {
            mf.fieldValue = profileId.ID_License_gne__c;
            if (mf.fieldValue == null)
                mf.fieldValue = '';
        }
         }catch (exception ex){
    mf.fieldValue = '';	
    }
        return mf;
    }
}