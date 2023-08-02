public with sharing class EDM_Attendee_Trigger_Helper {

	public static void onBeforeInsert(List<EDM_Attendee_gne__c> triggerNew) {
      Map<Id, EDM_IABP_gne__c> parentIABPs = retrieveParentIABPs(triggerNew);
      Map<Id, Account> accounts = retrieveAccounts(triggerNew);       	
       	
   	  for (EDM_Attendee_gne__c att : triggerNew) {
   		   EDM_IABP_gne__c iabp = parentIABPs.get(att.EDM_Parent_IABP_gne__c);
   		   if (iabp != null) {
   			    if (iabp.EDM_Status_gne__c == 'Event Occurred' || iabp.EDM_Status_gne__c == 'Executive Summary in Progress' ||
     			     iabp.EDM_Status_gne__c == 'Executive Summary in Review' || iabp.EDM_Status_gne__c == 'PTD in Progress' || iabp.EDM_Status_gne__c == 'PTD complete') {

                if (accounts.get(att.EDM_Account_gne__c) != null) {
                    if (att.EDM_Current_Business_Classification_gne__c == null) {
             			      att.EDM_Current_Business_Classification_gne__c = accounts.get(att.EDM_Account_gne__c).EDM_Business_Classification_gne__c;
                        att.EDM_Current_Business_Class_Role_gne__c = accounts.get(att.EDM_Account_gne__c).EDM_Business_Cl_Role_gne__c;
                        att.EDM_Current_Business_Classif_Date_gne__c = accounts.get(att.EDM_Account_gne__c).EDM_Business_Classification_Date_gne__c;
                    }
                    if (att.EDM_Current_Clinical_Classification_gne__c == null) {
      		              att.EDM_Current_Clinical_Classification_gne__c = accounts.get(att.EDM_Account_gne__c).EDM_Clinical_Classification_gne__c;
                        att.EDM_Current_Clinical_Classif_Date_gne__c = accounts.get(att.EDM_Account_gne__c).EDM_Clinical_Classification_Date_gne__c;
                        att.EDM_Current_Clinical_Specialties_gne__c = accounts.get(att.EDM_Account_gne__c).Specialties_gne__c;
                    }
                    if (att.EDM_Current_Exclusion_Status_gne__c == null) {
                        if(System.today() > att.EDM_Parent_IABP_gne__r.EDM_End_Date_gne__c) {
                            AGS_EX_Exclusion_Check_gne__c exCheck = getCurrentExclusionCheck(att.EDM_Account_gne__c);
                            if(exCheck != null) {
                                att.EDM_Current_Exclusion_Status_gne__c = exCheck.AGS_EX_Status_gne__c;
                                att.EDM_Current_Exclusion_Checked_Date_gne__c = exCheck.AGS_EX_Check_Date_gne__c;
                            }
                        } else {
                            att.EDM_Current_Exclusion_Status_gne__c = accounts.get(att.EDM_Account_gne__c).AGS_EX_Exclusion_Status_gne__c;
                            att.EDM_Current_Exclusion_Checked_Date_gne__c = accounts.get(att.EDM_Account_gne__c).AGS_EX_Date_Checked_Exclusion_gne__c;
                        }

                        if (accounts.get(att.EDM_Account_gne__c).AGS_EX_Exclusion_Status_gne__c == 'Request Pending' || 
                            accounts.get(att.EDM_Account_gne__c).AGS_EX_Exclusion_Status_gne__c == 'In Process') {
                               
                            List<AGS_EX_Exclusion_Request_gne__c> existingExclusionRequests = [SELECT Id, AGS_EX_Account_Name_gne__c,CreatedDate 
                                                                                    FROM AGS_EX_Exclusion_Request_gne__c 
                                                                                    WHERE 
                                                                                    (AGS_EX_Request_Status_gne__c = 'Pending' OR AGS_EX_Request_Status_gne__c = 'In Progress')
                                                                                  AND AGS_EX_Account_Name_gne__c = :accounts.get(att.EDM_Account_gne__c).Id];
                            if(!existingExclusionRequests.isEmpty()) {
                                DateTime dT = existingExclusionRequests[0].CreatedDate;                  
                                att.EDM_Current_Exclusion_Checked_Date_gne__c = Date.newInstance(dT.year(), dT.month(), dT.day());                                
                            } else {
                                att.EDM_Current_Exclusion_Checked_Date_gne__c = accounts.get(att.EDM_Account_gne__c).AGS_EX_Date_Checked_Exclusion_gne__c;
                            }                                                                                                              
                        }
                    }            
                }
            }
            if (accounts.get(att.EDM_Account_gne__c) != null) {
                att.EDM_Clinical_Specialties_gne__c = accounts.get(att.EDM_Account_gne__c).Specialties_gne__c;
                att.EDM_Credentials_gne__c = accounts.get(att.EDM_Account_gne__c).Credentials_gne__c;
            }
   		   }
      } 
    }

    private static AGS_EX_Exclusion_Check_gne__c getCurrentExclusionCheck(String accountId) {
        List<AGS_EX_Exclusion_Request_gne__c> lastExclusionRequests = [
                SELECT Id, AGS_EX_Request_Status_gne__c, (SELECT AGS_EX_Status_gne__c, AGS_EX_Check_Date_gne__c FROM AGS_EX_Exclusion_Checks__r WHERE AGS_EX_Check_Date_gne__c = LAST_N_DAYS:365)
                FROM AGS_EX_Exclusion_Request_gne__c
                WHERE AGS_EX_Account_Name_gne__c = :accountId
                ORDER BY CreatedDate desc
                LIMIT 1
        ];
        if (lastExclusionRequests.size() > 1) {
            return lastExclusionRequests[1].AGS_EX_Exclusion_Checks__r[0];
        }
        return null;
    }

    private static Map<Id, EDM_IABP_gne__c> retrieveParentIABPs(List<EDM_Attendee_gne__c> triggerNew) {
        Set<Id> parentIABPIds = new Set<Id>();

        for (EDM_Attendee_gne__c att : triggerNew) {
        	parentIABPIds.add(att.EDM_Parent_IABP_gne__c);                        
        }
        
        Map<Id, EDM_IABP_gne__c> parentIABPs = new Map<Id, EDM_IABP_gne__c>([SELECT EDM_Status_gne__c FROM EDM_IABP_gne__c 
        	WHERE Id IN :parentIABPIds]);
        return parentIABPs;
    }

    
    private static Map<Id, Account> retrieveAccounts(List<EDM_Attendee_gne__c> triggerNew) {
        Set<Id> hcpIds = new Set<Id>();
        for (EDM_Attendee_gne__c att : triggerNew) {
            hcpIds.add(att.EDM_Account_gne__c);
        }
        Map<Id, Account> result = new Map<Id, Account>([
          SELECT Name, EDM_Business_Classification_gne__c, EDM_Business_Cl_Role_gne__c, EDM_Business_Classification_Date_gne__c,
          EDM_Clinical_Classification_gne__c, EDM_Clinical_Classification_Date_gne__c,
          AGS_EX_Exclusion_Status_gne__c, AGS_EX_Date_Checked_Exclusion_gne__c, Specialties_gne__c, Credentials_gne__c
          FROM Account 
          WHERE id IN :hcpIds ]); 

        return result;
    }

    public static void trackChangedFields(List<EDM_Attendee_gne__c> triggerNew, Map<Id, EDM_Attendee_gne__c> triggerOldMap) {
        List<EDM_Attendee_History_gne__c> history_list=new List<EDM_Attendee_History_gne__c>();
        if(Trigger.isAfter && Trigger.isUpdate) {
            Map<Id, Account> accounts = retrieveAccounts(triggerNew);

            Set<String> trackedFields = new Set<String>{
                    'EDM_First_Name_gne__c',
                    'EDM_Last_Name_gne__c',
                    'EDM_Role_gne__c',
                    'EDM_Purpose_gne__c',
                    'EDM_Observer_gne__c',
                    'EDM_Company_gne__c',
                    'EDM_Country_gne__c'
            };
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType attendeeSchema = schemaMap.get('EDM_Attendee_gne__c');
            Map<String, Schema.SObjectField> fieldMap = attendeeSchema.getDescribe().fields.getMap();
            for (EDM_Attendee_gne__c attendee : triggerNew) {
                if(String.isBlank(attendee.EDM_Parent_IABP_gne__r.EDM_Parent_IABP_gne__c)) {
                EDM_Attendee_gne__c oldAttendee = triggerOldMap.get(attendee.Id);
                for (String str : trackedFields) {
                    try {
                        Boolean notEquals = checkValuesAreNotEquals(str, String.valueOf(oldAttendee.get(str)), String.valueOf(attendee.get(str)));
                            if (notEquals) {
                            EDM_Attendee_History_gne__c attHistory = new EDM_Attendee_History_gne__c();
                            attHistory.Action__c = 'Change';
                            attHistory.ChangedField_gne__c = fieldMap.get(str).getDescribe().getLabel() == 'Role' && attendee.EDM_System_Type_gne__c == 'Genentech' ? 'Title' : fieldMap.get(str).getDescribe().getLabel();
                                attHistory.OldValue_gne__c = str != 'EDM_Observer_gne__c' ? (String) oldAttendee.get(str) : String.valueOf((Boolean) oldAttendee.get(str));
                                attHistory.NewValue_gne__c = str != 'EDM_Observer_gne__c' ? (String) attendee.get(str) : String.valueOf((Boolean) attendee.get(str));
                            attHistory.EDM_Attendee_gne__c = attendee.Id;
                            attHistory.EDM_Attendee_Name_gne__c = attendee.EDM_Account_gne__c != null ? accounts.get(attendee.EDM_Account_gne__c).Name : attendee.EDM_First_Name_gne__c + ' ' + attendee.EDM_Last_Name_gne__c;
                            attHistory.EDM_Parent_IABP_gne__c = attendee.EDM_Parent_IABP_gne__c;

                            history_list.add(attHistory);
                        }
                    } catch (Exception e) {
                        System.Debug('Error: ' + e);
                    }
                }
                }

            }
            insert history_list;
        }
    }

    private static Boolean checkValuesAreNotEquals(String fieldApiName, String oldValue, String newValue) {
        Boolean stringsAreNotEquals = false;
        if(oldValue != null && newValue != null) {
            if(fieldApiName.equalsIgnoreCase('EDM_Role_gne__c') || fieldApiName.equalsIgnoreCase('EDM_Purpose_gne__c')) {
                stringsAreNotEquals = !newValue.stripHtmlTags().equals(oldValue.stripHtmlTags());
            } else {
                stringsAreNotEquals = !newValue.equals(oldValue);
            }
        }
        return stringsAreNotEquals;
    }

    public static void trackAddedAttendees(List<EDM_Attendee_gne__c> triggerNew) {
        List<EDM_Attendee_History_gne__c> history_list=new List<EDM_Attendee_History_gne__c>();
        if(Trigger.isAfter && Trigger.isInsert) {
            Map<Id, Account> accounts = retrieveAccounts(triggerNew);

            for (EDM_Attendee_gne__c attendee : triggerNew) {
                try {
                    if(String.isBlank(attendee.EDM_Parent_IABP_gne__r.EDM_Parent_IABP_gne__c)) {
                    EDM_Attendee_History_gne__c attHistory = new EDM_Attendee_History_gne__c();
                    attHistory.Action__c = 'Add';
                    attHistory.EDM_Attendee_gne__c = attendee.Id;
                    attHistory.EDM_Attendee_Name_gne__c = attendee.EDM_Account_gne__c != null ? accounts.get(attendee.EDM_Account_gne__c).Name : attendee.EDM_First_Name_gne__c + ' ' + attendee.EDM_Last_Name_gne__c;
                    attHistory.EDM_Parent_IABP_gne__c = attendee.EDM_Parent_IABP_gne__c;

                    history_list.add(attHistory);
                    }
                } catch (Exception e) {
                    System.Debug('Error: ' + e);
                }
            }
            insert history_list;
        }
    }

    public static void trackDeletedAttendees(List<EDM_Attendee_gne__c> triggerOld) {
        List<EDM_Attendee_History_gne__c> history_list=new List<EDM_Attendee_History_gne__c>();
        if(Trigger.isBefore && Trigger.isDelete) {
            Map<Id, Account> accounts = retrieveAccounts(triggerOld);
            for (EDM_Attendee_gne__c attendee : triggerOld) {
                try {
                    if(String.isBlank(attendee.EDM_Parent_IABP_gne__r.EDM_Parent_IABP_gne__c)) {
                    EDM_Attendee_History_gne__c attHistory = new EDM_Attendee_History_gne__c();
                    attHistory.Action__c = 'Delete';
                    attHistory.EDM_Attendee_Name_gne__c = attendee.EDM_Account_gne__c != null ? accounts.get(attendee.EDM_Account_gne__c).Name : attendee.EDM_First_Name_gne__c + ' ' + attendee.EDM_Last_Name_gne__c;
                    attHistory.EDM_Parent_IABP_gne__c = attendee.EDM_Parent_IABP_gne__c;
                    history_list.add(attHistory);
                    }
                } catch (Exception e) {
                    System.Debug('Error: ' + e);
                }
            }
            insert history_list;
        }
    }
}