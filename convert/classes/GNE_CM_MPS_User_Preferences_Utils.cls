/**
 * Utility methods for different operations on MPS user preferences.
 * @author Radek Krawiec
 * @created 10/19/2012
 */
public class GNE_CM_MPS_User_Preferences_Utils
{
	private static Map<String,String> perToRCCMap = new Map<String,String>{		
		Patient_Enrollment_Request_gne__c.Reimb_Clin_First_Name_gne__c.getDescribe().getName() => GNE_CM_MPS_User_Preferences__c.RCC_First_Name__c.getDescribe().getName(),
		Patient_Enrollment_Request_gne__c.Reimbursement_Contact_Name__c.getDescribe().getName() => GNE_CM_MPS_User_Preferences__c.RCC_Last_Name__c.getDescribe().getName(),
		Patient_Enrollment_Request_gne__c.Reimbursement_Clinical_Contact_Phone_gne__c.getDescribe().getName() => GNE_CM_MPS_User_Preferences__c.RCC_Phone__c.getDescribe().getName(),
		Patient_Enrollment_Request_gne__c.Reimbursement_Clinical_Contact_Phone_Ext__c.getDescribe().getName() => GNE_CM_MPS_User_Preferences__c.RCC_Phone_Extension__c.getDescribe().getName(),
		Patient_Enrollment_Request_gne__c.Reimbursement_Clinical_Contact_Fax_gne__c.getDescribe().getName() => GNE_CM_MPS_User_Preferences__c.RCC_Fax__c.getDescribe().getName(),
		Patient_Enrollment_Request_gne__c.GATCF_Contact_gne__c.getDescribe().getName() => GNE_CM_MPS_User_Preferences__c.RCC_GATCF_First_Name__c.getDescribe().getName(),
		Patient_Enrollment_Request_gne__c.GATCF_Contact_Last_Name_gne__c.getDescribe().getName() => GNE_CM_MPS_User_Preferences__c.RCC_GATCF_Last_Name__c.getDescribe().getName(),
		Patient_Enrollment_Request_gne__c.GATCF_Contact_Phone_gne__c.getDescribe().getName() => GNE_CM_MPS_User_Preferences__c.RCC_GATCF_Last_Name__c.getDescribe().getName(),
		Patient_Enrollment_Request_gne__c.GATCF_Contact_Last_Name_gne__c.getDescribe().getName() => GNE_CM_MPS_User_Preferences__c.RCC_GATCF_Phone__c.getDescribe().getName(),
		Patient_Enrollment_Request_gne__c.GATCF_Contact_Phone_Ext__c.getDescribe().getName() => GNE_CM_MPS_User_Preferences__c.RCC_GATCF_Phone_Extension__c.getDescribe().getName(),
		Patient_Enrollment_Request_gne__c.GATCF_Contact_Fax_gne__c.getDescribe().getName() => GNE_CM_MPS_User_Preferences__c.RCC_GATCF_Fax__c.getDescribe().getName()
	};
	
	/**
	* Removes MPS User Preferences stored based on SFDC User Id.
	**/	
	public static void clearReimbursementClinicalContactStoredData()
	{
		GNE_CM_MPS_User_Preferences__c preferenceSettings = getMPSPreferencesBySFDCUser(UserInfo.getUserId());
		if (preferenceSettings != null)
		{
			preferenceSettings.RCC_Preferences_Stored__c = false;
			for (String rccField : perToRCCMap.values())
			{
				preferenceSettings.put(rccField, null);
			}
			update preferenceSettings;
		}
	}
	
	/**
     * Check if there is RCC data stored in the MPS User Preferences object for this user, and if it is, rewrite it to the PER object.
     * @return the original PER with possibly loaded RCC data
     */
    public static Patient_Enrollment_Request_gne__c loadReimbursementClinicalContactStoredData (Patient_Enrollment_Request_gne__c per)
    {	
    	// get user preferences for the current user
    	GNE_CM_MPS_User_Preferences__c preferenceSettings = getMPSPreferencesBySFDCUser(UserInfo.getUserId());    	
    	if (preferenceSettings == null)
    	{
    		// if no preferences have been found to be loaded, return the unchanged PER
    		return per;
    	}
    	
    	// load the data from the user preferences into the PER
    	return loadReimbursementClinicalContactStoredData(per, preferenceSettings);
    	}
    	
    /**
     * Check if there is RCC data stored in the MPS User Preferences object for this user, and if it is, rewrite it to the PER object.
     * @return the original PER with possibly loaded RCC data
     */
    public static Patient_Enrollment_Request_gne__c loadReimbursementClinicalContactStoredData(Patient_Enrollment_Request_gne__c per, GNE_CM_MPS_User_Preferences__c preferenceSettings)
	{
		if (areRCCFieldsEmpty(per))
		{
			// rewrite the data only if the RCC fields in the PER are empty - we don't want to overwrite anything
			per.Reimbursement_Clinical_Contact_Store__c = preferenceSettings.RCC_Preferences_Stored__c;
			return rewriteRCCDataIntoPER(per, preferenceSettings);
		}
		else
		{
			return per;
		}
    }
    
    /**
     * Rewrites the Reimbursement/Clinical Contact data from the MPS user preferences into a patient enrollment request.
     * The values are overwritten only if all fields to be overwritten are empty.
     */
    private static Patient_Enrollment_Request_gne__c rewriteRCCDataIntoPER (Patient_Enrollment_Request_gne__c per, GNE_CM_MPS_User_Preferences__c preferenceSettings)
    {
    	if (preferenceSettings == null)
    	{
    		throw new GNE_CM_Exception('Passed MPS User Preferences object is null');	
    	}
    	
    	for (String perField : perToRCCMap.keySet())
		{
			per.put(perField, preferenceSettings.get(perToRCCMap.get(perField)));
		}
    	
    	return per;
    }
    
    private static Boolean isEmpty (String val)
    {
    	return val == null || val == '';
    }
    
    private static Boolean areRCCFieldsEmpty (Patient_Enrollment_Request_gne__c per)
    {
    	for (String perField : perToRCCMap.keySet())
		{
			if (!(per.get(perField) == null || per.get(perField) == ''))
			{
				return false;
			}
		}
		return true;
    }
    
    public static GNE_CM_MPS_User_Preferences__c getMPSPreferencesBySFDCUser (Id sfdcUserId)
    {
    	//UserInfo.getUserId()
    	// find the MPS user for the current user
    	List<GNE_CM_MPS_User__c> mpsUsers = [SELECT Id FROM GNE_CM_MPS_User__c WHERE SFDC_User__c = :sfdcUserId];
    	
    	if (mpsUsers.isEmpty())
    	{
    		throw new GNE_CM_Exception('No MPS user found for the current SFDC user with ID = ' + sfdcUserId);
    	}
    	
    	Id mpsUserId = mpsUsers.get(0).Id;
    	
    	return getMPSPreferences(mpsUserId);
    }
    
    /**
     * Get the MPS User Preferences object for the given MPS user.
     * @return the MPS User Preferences object if found for the given user. If not found, returns null.
     */
    public static GNE_CM_MPS_User_Preferences__c getMPSPreferences (Id mpsUserId)
    {
    	// try find user preference object
    	List<String> rccFieldsToSelect = new List<String>{ 'Id', GNE_CM_MPS_User_Preferences__c.RCC_Preferences_Stored__c.getDescribe().getName() };
    	for (String rccField : perToRCCMap.values())
    	{
    		rccFieldsToSelect.add(rccField);
    	}
    	List<GNE_CM_MPS_User_Preferences__c> preferenceSettingsList = Database.query(
    		'SELECT ' + String.join(rccFieldsToSelect, ', ') + ' FROM GNE_CM_MPS_User_Preferences__c WHERE MPS_User__c = \'' + mpsUserId + '\''
    	);
    	
    	if (preferenceSettingsList.isEmpty())
    	{
    		return null;
    	}
    	else if (preferenceSettingsList.size() > 1)
		{
			throw new GNE_CM_Exception('More than one GNE_CM_MPS_User_Preferences__c object found for MPS user with ID = ' + mpsUserId);
		}
		
		return preferenceSettingsList.get(0);
    }
    
	/**
     * Stores the Reimbursement/Clinical Contact data from the Patient Enrollment Form into an object containing user preferences
     */
    public static void storeReimbursementClinicalContact (Patient_Enrollment_Request_gne__c per)
    {
    	// find the MPS user for the current user
    	List<GNE_CM_MPS_User__c> mpsUsers = [SELECT Id FROM GNE_CM_MPS_User__c WHERE SFDC_User__c = :UserInfo.getUserId()];
    	
    	if (mpsUsers.isEmpty())
    	{
    		throw new GNE_CM_Exception('No MPS user found for the current SFDC user with ID = ' + UserInfo.getUserId());
    	}
    	
    	Id mpsUserId = mpsUsers.get(0).Id;
    	
    	GNE_CM_MPS_User_Preferences__c preferenceSettings = getMPSPreferences(mpsUserId);
    	
    	if (preferenceSettings == null)
    	{
    		// create new preference settings
    		preferenceSettings = new GNE_CM_MPS_User_Preferences__c (MPS_User__c = mpsUserId);
    	}
    	
    	// rewrite the Reimbursement/Clinical Contact data from PER into the preferences object
    	
    	preferenceSettings.RCC_Preferences_Stored__c = true;
    	for (String perField : perToRCCMap.keySet())
    	{
    		preferenceSettings.put(perToRCCMap.get(perField), per.get(perField));
    	}
    	
    	// save the preference object
    	upsert preferenceSettings;
    }
}