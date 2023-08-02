public virtual with sharing class GNE_SFA2_UserPreference_Ctrl {
    public Enum PreferenceType {FAVORITE, PREFERREDADDRESS, HIDDENADDRESS}
    
    protected transient DAO dao;
    protected transient Set<Id> hiddenAddrIds;
    protected transient List<Address_vod__c> hiddenAddresses;
    protected transient List<Address_vod__c> visibleAddresses;
    protected transient Boolean hasHiddenAddresses;
    
    public GNE_SFA2_UserPreference_Ctrl() {}
    
    public virtual List<Address_vod__c> getHiddenAddresses(Id userId, Id accountId) {
        if(hiddenAddresses==null) {
            hiddenAddresses = getDAO().getHiddenAddresses(userId, accountId);
        }
        
        return hiddenAddresses;
    }
    
    public virtual List<Address_vod__c> getVisibleAddresses(Id userId, Id accountId) {
        if(visibleAddresses==null) {
            visibleAddresses = getDAO().getVisibleAddresses(userId, accountId);
        }
        
        return visibleAddresses;
    }
    
    public virtual Set<Id> getHiddenAddressIds(Id userId, Id accountId) {
        return getHiddenAddressIds(userId, new Set<Id>{accountId});
    }
    
    public virtual Set<Id> getHiddenAddressIds(Id userId, Set<Id> accIds) {
        if(hiddenAddrIds==null) {
            hiddenAddrIds = getDAO().getHiddenAddressIds(userId, accIds);
        }
        
        return hiddenAddrIds;
    }
    
    public virtual Boolean hasHiddenAddresses(Id userId, Set<Id> accIds) {
        if(hasHiddenAddresses==null) {
            hasHiddenAddresses = getDAO().hasHiddenAddresses(userId, accIds);
        }
        
        return hasHiddenAddresses;
    }
    
    public virtual DAO getDAO() {
        if(dao==null) {
            dao = new DAO();
        }
        
        return dao;
    }
    
    public virtual void hideAddresses(Id userId, List<Address_vod__c> addrs) {
        showOrHideAddresses(userId, addrs, false);
    }
    
    public virtual void showAddresses(Id userId, List<Address_vod__c> addrs) {
        showOrHideAddresses(userId, addrs, true);
    }
    
    public virtual void showOrHideAddresses(Id userId, List<Address_vod__c> addrs, Boolean showOrHide) {
        List<UserPreferenceWrapper> userPrefs = new List<UserPreferenceWrapper>();
        
        for(Address_vod__c addr : addrs) {
            UserPreferenceWrapper upWrapper = new UserPreferenceWrapper(addr, PreferenceType.HIDDENADDRESS);
            upWrapper.active = !showOrHide;
            userPrefs.add(upWrapper);
        }
        
        upsertUserPreferences(userId, userPrefs);
    }
    
    public virtual void upsertUserPreferences(Id userId, List<UserPreferenceWrapper> userPrefs) {
        List<User_Preference_gne__c> toUpsert = new List<User_Preference_gne__c>();
      
        for(UserPreferenceWrapper userPrefWrappper : userPrefs) {
            User_Preference_gne__c uPrefRec = userPrefWrappper.getRecord(userId);
            toUpsert.add(uPrefRec);
        }
      
        if(!toUpsert.isEmpty()) {
            Database.upsert(toUpsert, User_Preference_gne__c.External_Id_gne__c);
        }
    }
    
    public virtual with sharing class DAO {
        public List<Address_vod__c> getHiddenAddresses(Id userId, Id accountId) {
            Set<Id> addrIds = getHiddenAddressIds(userId, new Set<Id>{accountId});
            
            return addrIds.isEmpty() ? new List<Address_vod__c>() : [
               SELECT MDM_Address_ID_gne__c, MDM_Status_gne__c,
                   Name, Address_Line_2_vod__c, State_vod__c, City_vod__c, Zip_vod__c, Primary_vod__c,
                   Phone_vod__c, Phone_2_vod__c, Fax_vod__c, Fax_2_vod__c, PFG_BDTD_gne__c,
                   Location_gne__Latitude__s, Location_gne__Longitude__s               
               FROM Address_vod__c
               WHERE Id IN :addrIds
               ORDER BY Name
            ];
        }
        
        public virtual List<Address_vod__c> getVisibleAddresses(Id userId, Id accountId) {
            Set<Id> addrIds = getHiddenAddressIds(userId, new Set<Id>{accountId});
            
            return addrIds.isEmpty() ? new List<Address_vod__c>() : [
               SELECT MDM_Address_ID_gne__c, MDM_Status_gne__c,
                   Name, Address_Line_2_vod__c, State_vod__c, City_vod__c, Zip_vod__c, Primary_vod__c,
                   Phone_vod__c, Phone_2_vod__c, Fax_vod__c, Fax_2_vod__c, PFG_BDTD_gne__c,
                   Location_gne__Latitude__s, Location_gne__Longitude__s               
               FROM Address_vod__c
               WHERE Account_vod__c = :accountId AND Id NOT IN :addrIds
               ORDER BY Name
            ];
        }
        
        public virtual Set<Id> getHiddenAddressIds(Id userId, Set<Id> accountIds) {
            Set<Id> result = new Set<Id>();
            List<User_Preference_gne__c> uPrefs = [
               SELECT
                   Address_gne__c
               FROM User_Preference_gne__c
               WHERE User_gne__c = :userId
                   AND Account_gne__c IN :accountIds
                   AND Type_gne__c = :PreferenceType.HIDDENADDRESS.name()
                   AND Active_gne__c = true
            ];
            
            for(User_Preference_gne__c up : uPrefs) {
                if(String.isNotBlank(up.Address_gne__c)) {
                    result.add(up.Address_gne__c);
                }
            }
            
            return result;
        }
        
        public virtual Boolean hasHiddenAddresses(Id userId, Set<Id> accountIds) {
            return ![
                SELECT Id
                FROM User_Preference_gne__c
                WHERE User_gne__c = :userId
                   AND Account_gne__c IN :accountIds
                   AND Type_gne__c = :PreferenceType.HIDDENADDRESS.name()
                   AND Active_gne__c = true
                LIMIT 1
            ].isEmpty();
        }
    }
    
    public virtual class UserPreferenceWrapper {
	    public String primaryId;
	    public String secondaryId;
	    public Boolean active;
	    public String type;
	    
	    public UserPreferenceWrapper() {}
	    
	    public UserPreferenceWrapper(Address_vod__c addr, PreferenceType type) {
	        this.primaryId = addr.Account_vod__c;
	        this.secondaryId = addr.Id;
	        this.active = true;
	        this.type = type.name();
	    }
    
        public virtual User_Preference_gne__c getRecord(Id userId) {
            Id primId = String.isNotBlank(this.primaryId) ? (Id)this.primaryId : null;
            Id secId = String.isNotBlank(this.secondaryId) ? (Id)this.secondaryId : null;
            String externalId = String.format('{0}_{1}_{2}_{3}', new String[]{
                ((String)userId).substring(0,15).toUpperCase(), primId!=null ? (String)primId : '', secId!=null ? (String)secId : '', this.type
            });
            Schema.SObjectType sobjectType = primId!=null ? primId.getSObjectType() : null;
            User_Preference_gne__c up = new User_Preference_gne__c(
                User_gne__c = userId,
                OnObject_Type_gne__c = sobjectType!=null ? sobjectType.getDescribe().getName().toUpperCase() : null,
                Address_gne__c = secId,
                Type_gne__c = this.type,
                External_Id_gne__c = externalId,
                Active_gne__c = this.active
            );
            
            if(sobjectType==Account.sObjectType) {
                up.Account_gne__c = primId;
            } else {
                up.OnObject_Id_gne__c = primId;
            }
            
            return up;
        }
    }
}