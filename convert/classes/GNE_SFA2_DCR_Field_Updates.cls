/************************************************************
*  @author: 
*  Date: 
*  Description: This is a helper class for handling Change_Request_gne__c field updates
*  This class is being used in GNE_SFA2_Data_Change_Request_Trigger
*    
*  Modification History
*  Date        Name                 Description
* 09-11-2016	kozminsl		Add support for frm_hco account dcrs
*************************************************************/
public without sharing class GNE_SFA2_DCR_Field_Updates {
	
	
	private static final String analystQueue = 'Data Change Request Analysts Queue';
	private static final String frmAnalystQueue = 'Data Change Request FRM Vendors Queue';
	
	private static final String vendorQueue = 'Data Change Request Vendors Queue';
	private static final String vendorQueue1 = 'Data Change Request Vendors Queue 1';
	private static final String vendorQueue2 = 'Data Change Request Vendors Queue 2';
	private static Integer minutesToWait = GNE_SFA2_DCR_Trigger_Helper.getminutesToWait();
	private static ID queueId = ChangeRequestControllerHelper.getAnalystsQueueNameQueueID();
	
	private static Map<Id, RecordType> rtMap;
	private static Map<Id, Account> dcrAccounts;

	private static void initCommonVariables(List<Change_Request_gne__c> triggerNewList){
		rtMap = new Map<Id, RecordType>([SELECT id, DeveloperName, Name FROM recordtype WHERE sobjecttype ='change_request_gne__c']);
		
		Set<Id> dcrAccountIds = new Set<Id>();
		for(Change_Request_gne__c dcr : triggerNewList){
			if(dcr.Account_gne__c != null) {
				dcrAccountIds.add(dcr.Account_gne__c);
			}
			if(rtMap.get(dcr.recordTypeId).DeveloperName.equalsIgnoreCase('HCO_Remove_Duplicate_Organization') || rtMap.get(dcr.recordTypeId).DeveloperName.equalsIgnoreCase('HCP_Remove_Duplicate')){
			    if(dcr.Account_gne__c != null) {
	                dcr.Duplicate_Account_1_Text_SFDC_ID_gne__c = dcr.Account_gne__c;
	            }
				if(dcr.duplicate_account_2_gne__c != null){
					dcrAccountIds.add(dcr.duplicate_account_2_gne__c);
					dcr.Duplicate_Account_2_Text_SFDC_ID_gne__c = dcr.Duplicate_Account_2_gne__c;
				}
				if(dcr.duplicate_account_3_gne__c != null){
					dcrAccountIds.add(dcr.duplicate_account_3_gne__c);
					dcr.Duplicate_Account_3_Text_SFDC_ID_gne__c = dcr.Duplicate_Account_3_gne__c;
				}
				if(dcr.duplicate_account_4_gne__c != null){
					dcrAccountIds.add(dcr.duplicate_account_4_gne__c);
					dcr.Duplicate_Account_4_Text_SFDC_ID_gne__c = dcr.Duplicate_Account_4_gne__c;
				}
				if(dcr.duplicate_account_5_gne__c != null){
					dcrAccountIds.add(dcr.duplicate_account_5_gne__c);
					dcr.Duplicate_Account_5_Text_SFDC_ID_gne__c = dcr.Duplicate_Account_5_gne__c;
				}
			}
		}
		dcrAccounts = new Map<Id, Account>([SELECT  Id, Account_Type_gne__c, FirstName, LastName, Name, Middle_vod__c, RecordTypeId, RecordType.Name, RecordType.DeveloperName, Recordtype.IsPersonType, Stewardship_System_Name_gne__c, ams_id_gne__c, Tier_Level_gne__c, HCP_Stakeholder_Type_gne__c, Language_of_Preference_can_gne__c, Specialties_can_gne__c FROM Account WHERE Id in :dcrAccountIds]);
	}

	public static void onBeforeUpdate(List<Change_Request_gne__c> triggerOldList, List<Change_Request_gne__c> triggerNewList,Map<Id,Change_Request_gne__c> triggerOldMap,Map<Id,Change_Request_gne__c> triggerNewMap){
		
		// .........:::::::::::::: THIS CODE RULE MUST BE ACTIVE DURING MERGE - NOT ADDING BYPASS :::::::::::::::::.................
		initCommonVariables(triggerNewList);
		initDcrValues(triggerOldList,triggerNewList,triggerOldMap,triggerNewMap);
		clearDuplicateAccountTextId(triggerNewList);
		
		if(!GNE_SFA2_Util.isMergeMode()) {
			LicOvrWrtExpDatHandler.handleLiceExpDat(triggerOldList, triggerNewList);
			changeDCRStatus(triggerNewList);
		}
		
		changeOwnerShip(triggerOldList, triggerNewMap);
		fillListOfChangedFields(triggerOldMap, triggerNewList);
	}
	
	public static void onBeforeInsert(List<Change_Request_gne__c> triggerNewList){
		initCommonVariables(triggerNewList);
		duplicateAccountDistinctCheck(triggerNewList);
		fillNotes(triggerNewList);
		setStatusForCanadaDCR(triggerNewList);
		changeDCRStatus(triggerNewList);
		changeOwners(triggerNewList);
		if(GNE_SFA2_Util.isCanadaUser()){
			fillNotesForCanada(triggerNewList);
		}
		fillListOfChangedFields(null, triggerNewList);
	}
	
    private static void clearDuplicateAccountTextId(List<Change_Request_gne__c> triggerNewList) {
        for(Change_Request_gne__c dcr: triggerNewList) {
            if(dcr.Approval_State__c != 'TBD'){
                continue;
            }
            Change_Request_gne__c oldRecord = (Change_Request_gne__c)Trigger.oldMap.get(dcr.Id);
            if(dcr.Account_gne__c == null && dcr.Account_gne__c != oldRecord.Account_gne__c){
                dcr.Duplicate_Account_1_Text_SFDC_ID_gne__c = null;
            }
            if(dcr.Duplicate_Account_2_gne__c == null && dcr.Duplicate_Account_2_gne__c != oldRecord.Duplicate_Account_2_gne__c){
                dcr.Duplicate_Account_2_Text_SFDC_ID_gne__c = null;
            }
            if(dcr.Duplicate_Account_3_gne__c == null && dcr.Duplicate_Account_3_gne__c != oldRecord.Duplicate_Account_3_gne__c){
                dcr.Duplicate_Account_3_Text_SFDC_ID_gne__c = null;
            }
            if(dcr.Duplicate_Account_4_gne__c == null && dcr.Duplicate_Account_4_gne__c != oldRecord.Duplicate_Account_4_gne__c){
                dcr.Duplicate_Account_4_Text_SFDC_ID_gne__c = null;
            }
            if(dcr.Duplicate_Account_5_gne__c == null && dcr.Duplicate_Account_5_gne__c != oldRecord.Duplicate_Account_5_gne__c){
                dcr.Duplicate_Account_5_Text_SFDC_ID_gne__c = null;
            }
        }
    }

	private static void fillNotes(List<Change_Request_gne__c> triggerNewList){
		for(Change_Request_gne__c cr: triggerNewList){
			if(cr.Account_gne__c != null && isAccountAMSStewarded(dcrAccounts.get(cr.Account_gne__c))){
        		if (amsDCRReadyForVendor(cr) == false) {
            		cr.notes_gne__c = System.Label.DCR_Missing_AMS_Id;     
          		}
			}  
    	}
	}
	
	private static Boolean isAccountAMSStewarded(Account acct) {
        Boolean bRet = false;  
        if((acct.Stewardship_System_Name_gne__c != null) && acct.Stewardship_System_Name_gne__c.equalsIgnoreCase('ams')){ 
             bRet = true;
        }
        return bRet;
    }
    
    private static Boolean amsDCRReadyForVendor (Change_Request_gne__c dcr) {
    	Boolean bReadyforVendor = true;
    	if ( dcr.account_gne__c != null && dcrAccounts.get(dcr.account_gne__c).ams_id_gne__c == null){
        	bReadyforVendor = false;
        }
        if(rtMap.get(dcr.recordTypeId).DeveloperName.equalsIgnoreCase('HCO_Remove_Duplicate_Organization') || rtMap.get(dcr.recordTypeId).DeveloperName.equalsIgnoreCase('HCP_Remove_Duplicate')){
        	
	        if ( dcr.duplicate_account_2_gne__c != null && dcrAccounts.get(dcr.duplicate_account_2_gne__c).ams_id_gne__c  == null){
	            bReadyforVendor = false;
	        }
	        if ( dcr.duplicate_account_3_gne__c != null && dcrAccounts.get(dcr.duplicate_account_3_gne__c).ams_id_gne__c  == null){
	            bReadyforVendor = false;
	        }
	        if ( dcr.duplicate_account_4_gne__c != null && dcrAccounts.get(dcr.duplicate_account_4_gne__c).ams_id_gne__c  == null){
	            bReadyforVendor = false;
	        }
	        if ( dcr.duplicate_account_5_gne__c != null && dcrAccounts.get(dcr.duplicate_account_5_gne__c).ams_id_gne__c  == null){
	            bReadyforVendor = false;
	        }
        }
        return bReadyforVendor;
    }
	
	/*
	*	This method fills Notes (Notes_gne__c) field with values from other fields depending on DCR type and
	*	information requested to be modified so Notes field will contain information about attributes that
	*	user is requesting to be changed on DCR creation. This requirement is only for Canada profiles.
	*/
	private static void fillNotesForCanada(List<Change_Request_gne__c> triggerNewList){
		List<String> dcrAddressIds = new List<String>();
		Map<Change_Request_gne__c, Account> dcrAccountMap = new Map<Change_Request_gne__c, Account>();
		Map<Change_Request_gne__c, Address_vod__c> dcrAddressMap = new Map<Change_Request_gne__c, Address_vod__c>();
		
		for(Change_Request_gne__c dcr : triggerNewList){
			if(dcr.Current_Address_gne__c != null){
				dcrAddressIds.add(dcr.Current_Address_gne__c);
			}
		}
		
		Map<Id, Address_vod__c> dcrAddresses = new Map<Id, Address_vod__c>([SELECT Id, Name, City_vod__c, Postal_Code_can_gne__c, Province_can_gne__c FROM Address_vod__c WHERE Id in :dcrAddressIds]);
		
		for(Change_Request_gne__c dcr : triggerNewList){
			if(dcr.Account_gne__c != null && dcrAccounts.get(dcr.Account_gne__c) != null){
				dcrAccountMap.put(dcr, dcrAccounts.get(dcr.Account_gne__c));
			}
			
			if(dcr.Current_Address_gne__c != null && dcrAddresses.get(dcr.Current_Address_gne__c) != null){
				dcrAddressMap.put(dcr, dcrAddresses.get(dcr.Current_Address_gne__c));
			}		
		}
		
		for(Change_Request_gne__c dcr : triggerNewList){
			String dcrNotes = '';		
			
			// check DCR type and copy relevant information to notes field
			dcrNotes = UserInfo.getUserName()+', '+DateTime.now() + '\n';
			// Change Organization Info
			if(rtMap.get(dcr.recordTypeId).DeveloperName.equalsIgnoreCase('HCO_Change_Organization_Info')){
				if(dcr.New_Organization_Name_gne__c != null && dcr.New_Organization_Name_gne__c != '' && dcr.New_Organization_Name_gne__c != dcrAccountMap.get(dcr).Name){
					dcrNotes += 'Change Organization Name to '+dcr.New_Organization_Name_gne__c+'\n';
				}
				if(dcrAccountMap.get(dcr) != null && dcr.Account_Type_DCR_gne__c != '--None--' && dcrAccountMap.get(dcr).Account_Type_gne__c != dcr.Account_Type_DCR_gne__c){
					dcrNotes += 'Change Organization Type to '+dcr.Account_Type_DCR_gne__c+'\n';
				}
				// Remove Duplicate Organization
			} else if (rtMap.get(dcr.recordTypeId).DeveloperName.equalsIgnoreCase('HCO_Remove_Duplicate_Organization')){
				if(dcr.Duplicate_Account_2_gne__c != null || dcr.Duplicate_Account_3_gne__c != null || dcr.Duplicate_Account_4_gne__c != null || dcr.Duplicate_Account_5_gne__c != null){
					dcrNotes += 'Duplicate HCOs: ';
				}
				if(dcr.Duplicate_Account_2_gne__c != null){
					dcrNotes += dcr.Duplicate_Account_2_gne__c;
				}
				if(dcr.Duplicate_Account_3_gne__c != null){
					dcrNotes += ', '+dcr.Duplicate_Account_3_gne__c;
				}
				if(dcr.Duplicate_Account_4_gne__c != null){
					dcrNotes += ', '+dcr.Duplicate_Account_4_gne__c;
				}
				if(dcr.Duplicate_Account_5_gne__c != null){
					dcrNotes += ', '+dcr.Duplicate_Account_5_gne__c;
				}
				// Remove/Inactivate Organization
			} else if (rtMap.get(dcr.recordTypeId).DeveloperName.equalsIgnoreCase('HCO_Remove_Inactivate_Organization')){
				if(dcr.Reason_dcr_gne__c != null && dcr.Reason_dcr_gne__c != ''){
					dcrNotes += 'Reason for Change Request: '+dcr.Reason_dcr_gne__c;
				}
				// Change HCP Info
			} else if (rtMap.get(dcr.recordTypeId).DeveloperName.equalsIgnoreCase('HCP_Change_HCP_Info')){
				if(dcr.First_Name_DCR_gne__c != null && dcr.First_Name_DCR_gne__c != dcrAccountMap.get(dcr).FirstName){
					dcrNotes += 'Change First Name to '+dcr.First_Name_DCR_gne__c+'\n';
				}
				if(dcr.New_Value_2_gne__c != null && dcr.New_Value_2_gne__c != dcrAccountMap.get(dcr).Middle_vod__c){
					dcrNotes += 'Change Middle Name to '+dcr.New_Value_2_gne__c+'\n';
				}
				if(dcr.Last_Name_DCR_gne__c != null && dcr.Last_Name_DCR_gne__c != dcrAccountMap.get(dcr).LastName){
					dcrNotes += 'Change Last Name to '+dcr.Last_Name_DCR_gne__c+'\n';
				}
				if(dcr.Account_Type_DCR_gne__c != null && dcr.Account_Type_DCR_gne__c != dcrAccountMap.get(dcr).Account_Type_gne__c){
					dcrNotes += 'Change Account Type to '+dcr.Account_Type_DCR_gne__c+'\n';
				}
				if(dcr.Language_of_Preference_dcr_gne__c != null && dcr.Language_of_Preference_dcr_gne__c != dcrAccountMap.get(dcr).Language_of_Preference_can_gne__c){
					dcrNotes += 'Change Language of Preference to '+dcr.Language_of_Preference_dcr_gne__c+'\n';
				}
				if(dcr.Specialties_HCP_DCR_gne__c != null && dcr.Specialties_HCP_DCR_gne__c != dcrAccountMap.get(dcr).Specialties_can_gne__c){
					dcrNotes += 'Change Specialties to '+dcr.Specialties_HCP_DCR_gne__c+'\n';
				}
				if(dcr.Verify_Gender_can_gne__c != null && dcr.Verify_Gender_can_gne__c == true){
					dcrNotes += 'Verify gender as it is incorrect or incomplete.';
				}
				// Remove Duplicate HCP
			} else if (rtMap.get(dcr.recordTypeId).DeveloperName.equalsIgnoreCase('HCP_Remove_Duplicate')){
				if(dcr.Duplicate_Account_2_gne__c != null || dcr.Duplicate_Account_3_gne__c != null || dcr.Duplicate_Account_4_gne__c != null || dcr.Duplicate_Account_5_gne__c != null){
					dcrNotes += 'Duplicate HCPs: ';
				}
				if(dcr.Duplicate_Account_2_gne__c != null){
					dcrNotes += dcr.Duplicate_Account_2_gne__c;
				}
				if(dcr.Duplicate_Account_3_gne__c != null){
					dcrNotes += ', '+dcr.Duplicate_Account_3_gne__c;
				}
				if(dcr.Duplicate_Account_4_gne__c != null){
					dcrNotes += ', '+dcr.Duplicate_Account_4_gne__c;
				}
				if(dcr.Duplicate_Account_5_gne__c != null){
					dcrNotes += ', '+dcr.Duplicate_Account_5_gne__c;
				}
				// Remove/Inactivate HCP
			} else if (rtMap.get(dcr.recordTypeId).DeveloperName.equalsIgnoreCase('HCP_Remove_Inactivate_HCP')){
				if(dcr.Reason_dcr_gne__c != null && dcr.Reason_dcr_gne__c != ''){
					dcrNotes += 'Reason for Change Request: '+dcr.Reason_dcr_gne__c;
				}
				// Remove/Inactivate Address
			} else if (rtMap.get(dcr.recordTypeId).DeveloperName.equalsIgnoreCase('HCP_Remove_Inactivate_Address') || rtMap.get(dcr.recordTypeId).DeveloperName.equalsIgnoreCase('HCO_Remove_Inactivate_Address')){
				if(dcr.Remove_Inactive_Address_gne__c != null && dcr.Remove_Inactive_Address_gne__c != ''){
					dcrNotes += 'Reason for Change Request: '+dcr.Remove_Inactive_Address_gne__c;
				}
				// Existing Address Has Typo
			} else if (rtMap.get(dcr.recordTypeId).DeveloperName.equalsIgnoreCase('HCP_Existing_Address_Typo_Missing_Info') || rtMap.get(dcr.recordTypeId).DeveloperName.equalsIgnoreCase('HCO_Change_Address')){
				if(dcr.Address_Line_1_gne__c != null && dcr.Address_Line_1_gne__c != dcrAddressMap.get(dcr).Name){
					dcrNotes += 'Change Street Name to '+dcr.Address_Line_1_gne__c+'\n';
				}
				if(dcr.City_gne__c != null && dcr.City_gne__c != dcrAddressMap.get(dcr).City_vod__c){
					dcrNotes += 'Change City to '+dcr.City_gne__c+'\n';
				}
				if(dcr.Province_can_gne__c != null && dcr.Province_can_gne__c != dcrAddressMap.get(dcr).Province_can_gne__c){
					dcrNotes += 'Change Province to '+dcr.Province_can_gne__c+'\n';
				}
				if(dcr.Postal_Code_can_gne__c != null && dcr.Postal_Code_can_gne__c != dcrAddressMap.get(dcr).Postal_Code_can_gne__c){
					dcrNotes += 'Change Postal Code to '+dcr.Postal_Code_can_gne__c+'\n';
				}
				//FMV Tier request
			} else if (rtMap.get(dcr.recordTypeId).DeveloperName.equalsIgnoreCase('HCP_FMV_Tier_request')){				
				if(dcr.Tier_Level_gne__c != null && dcr.Tier_Level_gne__c != dcrAccountMap.get(dcr).Tier_Level_gne__c){
					dcrNotes += 'Change Tier Level to '+dcr.Tier_Level_gne__c+'\n';
				}
				if(dcr.HCP_Stakeholder_Type_gne__c != null && dcr.HCP_Stakeholder_Type_gne__c != dcrAccountMap.get(dcr).HCP_Stakeholder_Type_gne__c){
					dcrNotes += 'Change HCP/Stakeholder Type to '+dcr.HCP_Stakeholder_Type_gne__c+'\n';
				}				
			} else if (rtMap.get(dcr.recordTypeId).DeveloperName.equalsIgnoreCase('US_Licensed_Physician')){				
				dcrNotes += 'Identify as U.S. Licensed Physician:  ';
				dcrNotes += 'state of license "'+dcr.License_State_gne__c+'", ';
				dcrNotes += 'license number "'+dcr.License_Number_gne__c+'", ';
				String npi = dcr.HCP_National_Provider_Id_gne__c;
				if (npi == null)
					npi = '';
				dcrNotes += 'HCP NPI ID "'+npi+'"\n';
			}
			dcr.Notes_gne__c = dcrNotes;
		}
	}
	
	private static void setStatusForCanadaDCR(List<Change_Request_gne__c> triggerNewList){
		if(GNE_SFA2_Util.isCanadaUser()){
			for (Change_Request_gne__c dcr : triggerNewList ) {
				dcr.Status_gne__c = 'Open';
			}
		}
	}
	
	private static void duplicateAccountDistinctCheck(List<Change_Request_gne__c> triggerNewList){
		for (Change_Request_gne__c dcr : triggerNewList )  {
			RecordType rt = rtMap.get ( dcr.recordTypeId );
			dcr.Type_gne__c = rt.Name;
			if (rt.DeveloperName.equalsIgnoreCase('HCP_Remove_Duplicate') || rt.DeveloperName.equalsIgnoreCase('HCO_Remove_Duplicate_Organization')) {
				dcr.ams_id_1_gne__c = dcr.account_gne__c != null ? dcrAccounts.get(dcr.account_gne__c).ams_id_gne__c:null;
				dcr.ams_id_2_gne__c = dcr.duplicate_account_2_gne__c != null ? dcrAccounts.get(dcr.duplicate_account_2_gne__c).ams_id_gne__c:null;
				dcr.ams_id_3_gne__c = dcr.duplicate_account_3_gne__c != null ? dcrAccounts.get(dcr.duplicate_account_3_gne__c).ams_id_gne__c:null;
				dcr.ams_id_4_gne__c = dcr.duplicate_account_4_gne__c != null ? dcrAccounts.get(dcr.duplicate_account_4_gne__c).ams_id_gne__c:null;
				dcr.ams_id_5_gne__c = dcr.duplicate_account_5_gne__c != null ? dcrAccounts.get(dcr.duplicate_account_5_gne__c).ams_id_gne__c:null;
			}
		}
		
		for (Change_Request_gne__c dcr : triggerNewList )  {
			try {
				RecordType rt = rtMap.get (dcr.recordTypeId);
				
				if (rt.DeveloperName.equalsIgnoreCase('HCP_Remove_Duplicate') || rt.DeveloperName.equalsIgnoreCase('HCO_Remove_Duplicate_Organization')) {
					Map <Id,String> acctMap = new Map<Id,String>();
					acctMap.put (dcr.Account_gne__c,  'Account 1' );
					String msg = '';
					
					// duplicate 2
					if ( dcr.Duplicate_Account_2_gne__c != null && acctMap.get(dcr.Duplicate_Account_2_gne__c) !=null ) {
						msg = 'Account 2 is same as  ' + acctMap.get(dcr.Duplicate_Account_2_gne__c);
					}
					if ( dcr.Duplicate_Account_2_gne__c != null ) {
						if ( acctMap.get(dcr.Duplicate_Account_2_gne__c) == null )
						acctMap.put(dcr.Duplicate_Account_2_gne__c, 'Account 2');
					}
					// duplicate 3
					if (dcr.Duplicate_Account_3_gne__c != null && acctMap.get(dcr.Duplicate_Account_3_gne__c) !=null ) {
						msg = msg + '<p>' +  'Account 3 is same as ' + acctMap.get(dcr.Duplicate_Account_3_gne__c);
					}
					if ( dcr.Duplicate_Account_3_gne__c != null ) {
						if ( acctMap.get(dcr.Duplicate_Account_3_gne__c) == null )
						acctMap.put(dcr.Duplicate_Account_3_gne__c, 'Account 3');
					}
					// duplicate 4
					if (dcr.Duplicate_Account_4_gne__c != null && acctMap.get(dcr.Duplicate_Account_4_gne__c) !=null ) {
						msg = msg + '<p>' +  'Account 4 is same as  ' + acctMap.get(dcr.Duplicate_Account_4_gne__c);
					}
					if ( dcr.Duplicate_Account_4_gne__c != null ) {
						if ( acctMap.get(dcr.Duplicate_Account_4_gne__c) == null )
						acctMap.put(dcr.Duplicate_Account_4_gne__c, 'Account 4');
					}
					
					// duplicate 5
					if (dcr.Duplicate_Account_5_gne__c != null && acctMap.get(dcr.Duplicate_Account_5_gne__c) !=null ) {
						msg = msg + '<p>' +  'Account 5 is same as  ' + acctMap.get(dcr.Duplicate_Account_5_gne__c);
					}
					
					if ( msg.length() > 0 ) {
						dcr.addError(msg);
					} else {
						dcr.ams_id_1_gne__c = dcr.account_gne__c != null ? dcrAccounts.get(dcr.account_gne__c).ams_id_gne__c:null;
						dcr.ams_id_2_gne__c = dcr.duplicate_account_2_gne__c != null ? dcrAccounts.get(dcr.duplicate_account_2_gne__c).ams_id_gne__c:null;
						dcr.ams_id_3_gne__c = dcr.duplicate_account_3_gne__c != null ? dcrAccounts.get(dcr.duplicate_account_3_gne__c).ams_id_gne__c:null;
						dcr.ams_id_4_gne__c = dcr.duplicate_account_4_gne__c != null ? dcrAccounts.get(dcr.duplicate_account_4_gne__c).ams_id_gne__c:null;
						dcr.ams_id_5_gne__c = dcr.duplicate_account_5_gne__c != null ? dcrAccounts.get(dcr.duplicate_account_5_gne__c).ams_id_gne__c:null;
					}
				}
			}catch (Exception e) {
				dcr.addError (e.getMessage());
			}
		}
	}
	
	private static void initDcrValues(List<Change_Request_gne__c> triggerOldList, List<Change_Request_gne__c> triggerNewList,Map<Id,Change_Request_gne__c> triggerOldMap,Map<Id,Change_Request_gne__c> triggerNewMap){
		List<Change_Request_gne__Share> newDCRShares = new List<Change_Request_gne__Share>();
		
		/*-------------------------------------------------------------------------------
		D3. Change ownership based on the Recortype/Stewardship of the account.
		*/
		String envName=Utilities.getEnvironmentName();
		List<String> envVariablesNames=new String[]{'DataChangeRequestRecordTypesForAMS','DataChangeRequestRecordTypesForBOT','DataChangeRequestRecordTypesForGeneric'};
		
		List<Environment_Variables__c> envVariables= [SELECT Environment__c, Key__c, Value__c FROM Environment_Variables__c
														WHERE Key__c in :envVariablesNames and Environment__c =:envName];
		Set<String> accountRecordTypesForAMS = new Set<String>();
		Set<String> accountRecordTypesForBOT = new Set<String>();
		Set<String> accountRecordTypesForGeneric = new Set<String>();
		
		for(Environment_Variables__c envVar:envVariables){
			if(envVar.Key__c=='DataChangeRequestRecordTypesForAMS'){
				accountRecordTypesForAMS = new Set<String>(envVar.Value__c.split(',',0));
			}else if(envVar.Key__c=='DataChangeRequestRecordTypesForBOT'){
				accountRecordTypesForBOT = new Set<String>(envVar.Value__c.split(',',0));
			}else if(envVar.Key__c=='DataChangeRequestRecordTypesForGeneric'){
				accountRecordTypesForGeneric = new Set<String>(envVar.Value__c.split(',',0));
			}
		}
		
		/*--------------------------------------------------------------------------------*/
		List<Id> toBeSharesClearedDCRIds=new List<Id>();
		
		Set<Id>userIds = new Set<Id>();
		for(Change_Request_gne__c changeRequest : triggerNewList){
			if(changeRequest.Assigned_Analyst_gne__c!=null){
				userIds.add(changeRequest.Assigned_Analyst_gne__c);
			}
			userIds.add(changeRequest.CreatedById);
		}
		userIds.add(UserInfo.getUserId());
		Map<Id, User>users = new Map<Id, User>([SELECT Id, Name, Email, IsActive FROM User WHERE Id=:userIds]);
		
		Map<String, Id> vandorTypeToQueueId = ChangeRequestControllerHelper.getVendorQueues();
		
		for(Change_Request_gne__c changeRequest : triggerNewList){
			Id vendorShareId = vandorTypeToQueueId.get(changeRequest.Vendor_Type_gne__c);
			//Status Management sometimes should happen only if the status has changed!
			Boolean statusChanged = changeRequest.Status_gne__c!=triggerOldMap.get(changeRequest.Id).Status_gne__c;

			if((triggerOldMap.get(changeRequest.Id).ownerId == queueId && triggerOldMap.get(changeRequest.Id).Vendor_Type_gne__c == 'bot' && triggerOldMap.get(changeRequest.Id).Status_gne__c=='Submitted') &&
			 (changeRequest.ownerId==queueId && changeRequest.Vendor_Type_gne__c=='bot' &&	changeRequest.Status_gne__c=='Submitted')){
				continue;
			}
			
			if(changeRequest.Status_gne__c=='Submitted'){
				/*-------------------------------------------------------------------------------
				D3. Change ownership based on the Recortype/Stewardship of the account.
				*/

				if ( changeRequest.Vendor_Type_gne__c == null && dcrAccounts.get(changeRequest.Account_gne__c).stewardship_system_name_gne__c != null) {
					changeRequest.Vendor_Type_gne__c = dcrAccounts.get(changeRequest.Account_gne__c).Stewardship_System_Name_gne__c;
				}

				if(changeRequest.Vendor_Type_gne__c==null){
					String accountRecordtype;
					if(dcrAccounts.get(changeRequest.Account_gne__c).Recordtype.IsPersonType){
						accountRecordtype='Person_Account';
					}else{
						accountRecordtype=dcrAccounts.get(changeRequest.Account_gne__c).Recordtype.Name;
					}

					if(accountRecordTypesForAMS.contains(accountRecordtype)){
						changeRequest.Vendor_Type_gne__c = 'ams';
					}else if(accountRecordTypesForBOT.contains(accountRecordtype)){
						changeRequest.Vendor_Type_gne__c = 'bot';
					}else if(accountRecordTypesForGeneric.contains(accountRecordtype)){
						changeRequest.Vendor_Type_gne__c = 'generic';
					}else{
						changeRequest.Vendor_Type_gne__c = 'sfdc';
					}
				}
				/*--------------------------------------------------------------------------------*/
				
				if(changeRequest.ownerId==queueId){
					//At this point the ownership of the record is passed to the Analyst queue
					//I just need to create a read only share with the original owner
					newDCRShares.add(ChangeRequestControllerHelper.createChangeRequestShare(changeRequest.CreatedById, changeRequest, 'Read', Change_Request_gne__Share.RowCause.Original_Owner_gne__c));
					changeRequest.Current_Sharing_Owner_gne__c = 'Read';
					if(changeRequest.Assigned_Analyst_gne__c != null){
						//when an analyst is assigned the job is in progress
						changeRequest.Status_gne__c='In-Progress';
					}
				}
			}
			
			if(changeRequest.Status_gne__c == 'In-Progress' && changeRequest.Assigned_Analyst_gne__c == null){
				changeRequest.Assigned_Analyst_gne__c=UserInfo.getUserId();
			}
			
			if(changeRequest.Status_gne__c=='Need Info'  && statusChanged){
				//Need Info:  Request is sent back to requestor for clarification or missing info
				newDCRShares.add(ChangeRequestControllerHelper.createChangeRequestShare(changeRequest.CreatedById, changeRequest, 'Edit', Change_Request_gne__Share.RowCause.Original_Owner_gne__c));
				changeRequest.Current_Sharing_Owner_gne__c = 'Edit';
				//Sendig Email to User
				//Retrieving User and Analyst emails
				ChangeRequestControllerHelper.sendEmail(changeRequest, true, users.get(changeRequest.CreatedById).Email);
			}
			if(changeRequest.Status_gne__c == 'Ready for Data Vendor' && changeRequest.ownerId == vendorShareId){
				//Ready for Data Vendor:  Request is valid and ready to be processed by a vendor (AMS)
				//A workflow rule has given ownership to the Vendors queue
				newDCRShares.add(ChangeRequestControllerHelper.createChangeRequestShare(queueId,changeRequest, 'Edit', Change_Request_gne__Share.RowCause.Data_Vendor_gne__c));
				changeRequest.Current_Sharing_Vendor_gne__c='Edit';
				newDCRShares.add(ChangeRequestControllerHelper.createChangeRequestShare(changeRequest.CreatedById, changeRequest, 'Read', Change_Request_gne__Share.RowCause.Original_Owner_gne__c));
				changeRequest.Current_Sharing_Owner_gne__c = 'Read';
				changeRequest.Flag_Ready_for_Data_Vendor_gne__c = Datetime.Now();
			}
			if(changeRequest.Status_gne__c=='Issue Identified by Vendor' && changeRequest.ownerId==queueId){
				//Let it first get out of the Vendor Queue ownership!
				changeRequest.Current_Sharing_Vendor_gne__c=null;
				if (changeRequest.Approval_State__c!='TBD' && changeRequest.Approval_State__c!='Invalid') changeRequest.Status_gne__c='Ready to Load';
				if(changeRequest.Data_Vendor_Changes_gne__c==null && (changeRequest.Approval_State__c!='TBD' && changeRequest.Approval_State__c!='Approved')){
					changeRequest.Data_Vendor_Changes_gne__c.addError('Description of Exceptions is required. See field help for details.');
					break;
				}
				changeRequest.Flag_Issue_Identified_by_Vendor_gne__c=Datetime.Now();
			}
			if(changeRequest.Status_gne__c=='Ready to Load'){
				//Ready to Load:  AMS has completed request and it is sent to GNE for loading into MDM and eventually SFDC
				changeRequest.Flag_Ready_for_Load_gne__c=Datetime.Now();
			}
			if(changeRequest.Status_gne__c=='Ready to Close' && statusChanged){
				//Ready to Close:  Request Analyst had determined that no further work is required, either because the request was completed and updated in SFDC, or because it was determined to be an invalid request.
				//Now we give the user a chance to dispute the record and we flag the event
				newDCRShares.add(ChangeRequestControllerHelper.createChangeRequestShare(changeRequest.CreatedById,changeRequest,'Edit',Change_Request_gne__Share.RowCause.Original_Owner_gne__c));
				changeRequest.Current_Sharing_Owner_gne__c='Edit';
				changeRequest.Date_Ready_To_Close_Last_Set_gne__c=Datetime.Now();
				changeRequest.Flag_Ready_for_Close_gne__c=Datetime.Now();
				ChangeRequestControllerHelper.sendEmail(changeRequest, false, users.get(changeRequest.CreatedById).Email);
			}
			if(changeRequest.Status_gne__c!='Ready to Close' && changeRequest.Status_gne__c!='Closed By System' && statusChanged){
				//Resetting the Date_Ready_To_Close_Last_Set_gne__c fieldif the status is other than closed
				changeRequest.Date_Ready_To_Close_Last_Set_gne__c=null;
				// guruk commented to review the functionality provided by flag fields.  - 09/04/2009
				//changeRequest.Flag_Ready_for_Close_gne__c=Datetime.Now();
			}
			if(changeRequest.Status_gne__c=='Disputed'){
				//Disputed:  requestor disputes that no further work is needed, either because they believe it is valid or has not been updated in SFDC as expected
				newDCRShares.add(ChangeRequestControllerHelper.createChangeRequestShare(changeRequest.CreatedById,changeRequest,'Read',Change_Request_gne__Share.RowCause.Original_Owner_gne__c));
				changeRequest.Current_Sharing_Owner_gne__c='Read';
			}
			if(changeRequest.Status_gne__c=='Closed'){
				//Closed: No further activity is required and the request can not be re-opened.
				newDCRShares.add(ChangeRequestControllerHelper.createChangeRequestShare(changeRequest.CreatedById,changeRequest,'Read',Change_Request_gne__Share.RowCause.Original_Owner_gne__c));
				changeRequest.Current_Sharing_Owner_gne__c='Read';
				changeRequest.Flag_Closed_gne__c=Datetime.Now();
			}
			if(changeRequest.Status_gne__c=='Closed By System'){
				//This is the system attempting to close the record.
				//I'll have to make sure that the Date_Ready_To_Close_Last_Set_gne__c is still on an then i'll be able to close it
				//if not i'll have to ignore the action
				
				// guruk - parameterized minutes to wait prior to closing a dcr automatically
				// via workflow rule. please see bug gRemedy HD0000001584418
				if( changeRequest.Date_Ready_To_Close_Last_Set_gne__c==null || changeRequest.Date_Ready_To_Close_Last_Set_gne__c.addMinutes(minutesToWait) > Datetime.Now() ) {
					changeRequest.Status_gne__c=triggerOldMap.get(changeRequest.Id).Status_gne__c;
				} else {
					changeRequest.Status_gne__c='Closed';
					changeRequest.Date_Ready_To_Close_Last_Set_gne__c=null;
					newDCRShares.add(ChangeRequestControllerHelper.createChangeRequestShare(changeRequest.CreatedById,changeRequest,'Read',Change_Request_gne__Share.RowCause.Original_Owner_gne__c));
					changeRequest.Current_Sharing_Owner_gne__c='Read';
					changeRequest.Flag_Closed_gne__c=Datetime.Now();
				}
			}
			//Sending Email if Reassigned
			if(changeRequest.Assigned_Analyst_gne__c!=triggerOldMap.get(changeRequest.Id).Assigned_Analyst_gne__c &&
					changeRequest.Assigned_Analyst_gne__c!=null && triggerOldMap.get(changeRequest.Id).Assigned_Analyst_gne__c!=null){
				ChangeRequestControllerHelper.sendRAEmail(changeRequest, users.get(changeRequest.Assigned_Analyst_gne__c).Email);
			}
			//Updating Ownership records
			if(triggerOldMap.get(changeRequest.Id).Assigned_Analyst_gne__c!=changeRequest.Assigned_Analyst_gne__c){
				String sStart= '<b>' + UserInfo.getUserName() + ' ' + changeRequest.LastModifiedDate.format('MM/dd/yyyy HH:mm:ss') + '</b><br>' + 'Assigned to:' + users.get(changeRequest.Assigned_Analyst_gne__c).Name + '<br><br>';
				if(changeRequest.Notes_gne__c!=null){
					changeRequest.Notes_gne__c=sStart+ changeRequest.Notes_gne__c;
				}else{
					changeRequest.Notes_gne__c=sStart;
				}
			}

			//Updating Notes
			if(changeRequest.New_Note_gne__c!=null){
				String sStart= '<b>' + UserInfo.getUserName() + ' ' + changeRequest.LastModifiedDate.format('MM/dd/yyyy HH:mm:ss') + '</b><br>' + changeRequest.New_Note_gne__c + '<br><br>';
				if(changeRequest.Notes_gne__c!=null){
					changeRequest.Notes_gne__c=sStart + changeRequest.Notes_gne__c;
				}else{
					changeRequest.Notes_gne__c=sStart;
				}
				changeRequest.New_Note_gne__c=null;
			}
			//Updating Vendor Notes
			if(changeRequest.New_Vendor_Note_gne__c!=null){
				String sStart='<b>' + UserInfo.getUserName() + ' ' + changeRequest.LastModifiedDate.format('MM/dd/yyyy HH:mm:ss') + '</b><br>' +  changeRequest.New_Vendor_Note_gne__c + '<br><br>';
				if(changeRequest.Vendor_Notes_gne__c!=null){
					changeRequest.Vendor_Notes_gne__c=sStart+  changeRequest.Vendor_Notes_gne__c;
				}else{
					changeRequest.Vendor_Notes_gne__c=sStart;
				}
				changeRequest.New_Vendor_Note_gne__c=null;
			}
		}
		
		//Updating Data Change Request Sharings
		ChangeRequestControllerHelper.clearChangeRequestShares(toBeSharesClearedDCRIds);
		removeDCRSharesForInactiveUsers(newDCRShares, users);
		List<Database.SaveResult> lsr= Database.insert(newDCRShares,false);
		Integer i=0;
		// Process the save results
		for(Database.SaveResult sr : lsr){
			if(!sr.isSuccess()){
				// Get the first save result error
				Database.Error err = sr.getErrors()[0];
				if(!(err.getStatusCode() == StatusCode.FIELD_INTEGRITY_EXCEPTION && err.getMessage().contains('AccessLevel'))){
					// Throw an error when the error is not related to trivial access level.
					triggerNewMap.get(newDCRShares[i].ParentId).addError('Unable to grant sharing access due to following exception:' + err.getMessage());
				} else{
					triggerNewMap.get(newDCRShares[i].ParentId).addError('Unable to update the record due to following exception:' + err.getMessage());
				}
				i++;
			}
		}
	}

	private static void removeDCRSharesForInactiveUsers(List<Change_Request_gne__Share> newDCRShares, Map<Id, User> users) {
		for (Integer i = 0; i < newDCRShares.size(); i++) {
			if (users.containsKey(newDCRShares.get(i).UserOrGroupId) && !users.get(newDCRShares.get(i).UserOrGroupId).isActive) {
				newDCRShares.remove(i);
				i--;
			}
		}
	}
	
	private static void changeOwnerShip(List<Change_Request_gne__c> triggerOldList, Map<Id, Change_Request_gne__c> triggerNewMap){
		List<Change_Request_gne__c> chrChangeOwnerList = new List<Change_Request_gne__c>();
		for(Change_Request_gne__c chrold :triggerOldList){
			//SFA-547
			if(chrold.Status_gne__c == null && !(GNE_SFA2_DCR_Trigger_Helper.getProfileName(chrold.createdById).toLowerCase().contains('canada'))){
				chrChangeOwnerList.add(triggerNewMap.get(chrold.id));
			}else if(!((chrold.Status_gne__c.equals('Submitted') || chrold.Status_gne__c.equals('Issue Identified by Vendor')) && (!(GNE_SFA2_DCR_Trigger_Helper.getProfileName(chrold.createdById).toLowerCase().contains('canada'))))){
				chrChangeOwnerList.add(triggerNewMap.get(chrold.id));
			}else if (!(chrold.Status_gne__c.equals('Ready for Data Vendor') && chrold.Vendor_Type_gne__c.equals('ams'))){
				chrChangeOwnerList.add(triggerNewMap.get(chrold.id));
			}else if(!(chrold.Status_gne__c.equals('Ready for Data Vendor') && chrold.Vendor_Type_gne__c.equals('bot'))){
				chrChangeOwnerList.add(triggerNewMap.get(chrold.id));
			}else if(!(chrold.Status_gne__c.equals('Ready for Data Vendor') && chrold.Vendor_Type_gne__c.equals('generic'))){
				chrChangeOwnerList.add(triggerNewMap.get(chrold.id));
			}
		}
		changeOwners(chrChangeOwnerList);
	}
	
	private static void changeOwners(List<Change_Request_gne__c> changeOwnerReadyRecords) {
		if(changeOwnerReadyRecords != null){
			for(Change_Request_gne__c chr : changeOwnerReadyRecords){
				try{
					Id creatorId = chr.CreatedById !=null ? chr.CreatedById : UserInfo.getUserId(); // chr.CreatedById is null on Before Insert
					if(chr.Account_gne__c != null && dcrAccounts.get(chr.Account_gne__c).RecordType.DeveloperName == GNE_SFA2_Account_Trigger_Helper.REC_TYPE_FRM_HCO){
						if(chr.Status_gne__c.equals('Submitted')){
							chr.ownerId = GNE_SFA2_DCR_Trigger_Helper.getQueueId(frmAnalystQueue);
						}
					} else if(chr.Status_gne__c == null && !(GNE_SFA2_DCR_Trigger_Helper.getProfileName(creatorId).toLowerCase().contains('canada'))){
						chr.ownerId=GNE_SFA2_DCR_Trigger_Helper.getQueueId(analystQueue);
					}else if( (chr.Status_gne__c.equals('Submitted') || chr.Status_gne__c.equals('Issue Identified by Vendor') || (chr.AMS_ID_gne__c != null && chr.Status_gne__c == 'Ready to Load')) && (!(GNE_SFA2_DCR_Trigger_Helper.getProfileName(creatorId).toLowerCase().contains('cananda')) )){
						chr.ownerId=GNE_SFA2_DCR_Trigger_Helper.getQueueId(analystQueue);
					}else if((chr.Status_gne__c.equals('Ready for Data Vendor') ) && (chr.Vendor_Type_gne__c != null && chr.Vendor_Type_gne__c.equals('ams'))){
						chr.ownerId=GNE_SFA2_DCR_Trigger_Helper.getQueueId(vendorQueue);
					}else if((chr.Status_gne__c.equals('Ready for Data Vendor') ) && (chr.Vendor_Type_gne__c != null && chr.Vendor_Type_gne__c.equals('bot'))){
						chr.ownerId=GNE_SFA2_DCR_Trigger_Helper.getQueueId(vendorQueue1);
					}else if((chr.Status_gne__c.equals('Ready for Data Vendor') ) && (chr.Vendor_Type_gne__c != null && chr.Vendor_Type_gne__c.equals('generic'))){
						chr.ownerId=GNE_SFA2_DCR_Trigger_Helper.getQueueId(vendorQueue2);
					}
				}catch(Exception e){
					chr.addError(e.getMessage());
				}
			}
		}
	}
	
	private static void changeDCRStatus(List<Change_Request_gne__c> dcrList){
		Id licIssueRecTypeId = GNE_SFA2_DCR_Trigger_Helper.getLicIssueRecordTypeId();
		for(Change_Request_gne__c dcr : dcrList){
			try{
				if(dcr.RecordTypeId != licIssueRecTypeId && dcr.Account_gne__r.RecordType.Developername != GNE_SFA2_Account_Trigger_Helper.REC_TYPE_FRM_HCO) {
					Id creatorId = dcr.CreatedById != null ? dcr.CreatedById : UserInfo.getUserId();
					if(dcr.AMS_ID_gne__c != null && dcr.Status_gne__c.equalsIgnoreCase('Submitted')  && (!(GNE_SFA2_DCR_Trigger_Helper.getProfileName(creatorId).toLowerCase().contains('cananda')))){
						dcr.Status_gne__c = 'Ready for Data Vendor';
						dcr.Vendor_Type_gne__c = 'ams';
					}else if(dcr.AMS_ID_gne__c != null && dcr.Status_gne__c != null && dcr.Status_gne__c.equalsIgnoreCase('Issue Identified by Vendor') && (!(GNE_SFA2_DCR_Trigger_Helper.getProfileName(creatorId).toLowerCase().contains('cananda')))){
						dcr.Status_gne__c = 'Ready to Load';
					}
				}
			}catch(Exception e){
				dcr.addError(e.getMessage());
			}
		}
	}
	
	private static void fillListOfChangedFields(Map<Id,Change_Request_gne__c> triggerOldMap, List<Change_Request_gne__c> triggerNew) {
		List<Change_Request_gne__c> dcrsToRefresh = new List<Change_Request_gne__c>();
		
		for(Change_Request_gne__c crNew : triggerNew) {
			Change_Request_gne__c crOld = triggerOldMap != null && triggerOldMap.containsKey(crNew.Id) ? triggerOldMap.get(crNew.Id) : null; 
			if(GNE_SFA2_DCR_Util.isValidForUpdateListOfChangedFields(crOld, crNew)) {
				dcrsToRefresh.add(crNew);
			}
		}
		if(!dcrsToRefresh.isEmpty()) {
			GNE_SFA2_DCR_Util.updateListOfChangedFields(dcrsToRefresh);
		}
	}
}