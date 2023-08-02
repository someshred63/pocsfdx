/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-10-22
*  Description: This is a helper clsass for GNE_SFA2_Time_Off_Territory_Day_Trigger for handling email notifications
*  Test class: GNE_SFA2_Time_Off_Territory_Day_Trigger_Test
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class GNE_SFA2_ToT_Day_Email_Notifications {
	
	private static void notifyOnFuterReferralsAssigned(List<Time_off_Territory_Day_gne__c> triggerNew) {
        System.debug('notifyOnFuterReferralsAssigned sterted');
        try{
            List<Time_off_Territory_Day_gne__c> totdList = (List<Time_off_Territory_Day_gne__c>)triggerNew;
            Time_off_Territory_Day_gne__c totd = totdList.get(0);
            
            // Trigger starts only one time, after Time_off_Territory_gne__c record create, 
            // not after adding new Time_off_Territory_Day_gne__c position to existing ones.
            // So if Time_off_Territory_Day_gne__c have records with Time_Off_Territory_gne__c ID (the same as new records added) that means its update of days
            List<Time_Off_Territory_Day_gne__c> checkList = [ SELECT Id FROM Time_Off_Territory_Day_gne__c 
              WHERE Time_Off_Territory_gne__c = :totd.Time_Off_Territory_gne__c AND Id NOT IN :Trigger.newMap.keySet() ];
            
            if (checkList == null || checkList.size() == 0){
                Time_Off_Territory_gne__c tot = [ SELECT Owner.Email, Owner.Id, Assigned_Referral_Activity_gne__r.Email, 
                    Assigned_Referral_Activity_gne__r.Manager.Email FROM Time_Off_Territory_gne__c WHERE Id = :totd.Time_Off_Territory_gne__c];
                
                //System.debug('AssignedUserEmail: ' + tot.Assigned_Referral_Activity_gne__r.Email);
                String[] toAddresses = new String[]{tot.Assigned_Referral_Activity_gne__r.Email};
                List<String> ccAddresses = new List<string>();
                String ownerUserEmail = tot.Owner.Email;
                ccAddresses.add(ownerUserEmail);
                //System.debug('OwnerUserEmail: ' + ownerUserEmail);
                
                ID ownerManagerID = [ SELECT ManagerId FROM User WHERE Id = :tot.OwnerId].ManagerId;
                //System.debug('OwnerManagerID: ' + ownerManagerID);
                if (ownerManagerID != null){
                    String ownerUserManagerEmail = [ SELECT Email FROM User WHERE Id = :ownerManagerID].Email;
                    ccAddresses.Add(ownerUserManagerEmail);
                    //System.debug('OwnerUserManagerEmail: '+ ownerUserManagerEmail);
                }
                
                if (tot.Assigned_Referral_Activity_gne__r.Manager.Email != null){
                    ccAddresses.Add(tot.Assigned_Referral_Activity_gne__r.Manager.Email);
                    //System.debug('tot.Assigned_Referral_Activity_gne__r.Manager.Email: ' + tot.Assigned_Referral_Activity_gne__r.Manager.Email);
                }
                
                Date dateFrom = null;
                Date dateTo = null;         
                // Finding the max and min values of Date
                for (Time_off_Territory_Day_gne__c totdItem : totdList){
                    Date dateItemValue = totdItem.Date_gne__c;
                    if (dateFrom == null || dateFrom > dateItemValue){
                        dateFrom = dateItemValue;
                    }
                    if (dateTo == null || dateTo < dateItemValue){
                        dateTo = dateItemValue;
                    }
                }
            
                // Creating email message
                Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
                email.setToAddresses(toAddresses);
                email.setCcAddresses(ccAddresses);
                email.setSubject(Label.ToT_Assignment_Notification_Label);
                String emailBodyText = String.Format(Label.ToT_Assignment_Notification_Body_Label, new String[]{Userinfo.getName(), String.valueOf(dateFrom), String.valueOf(dateTo)});
                email.setPlainTextBody(emailBodyText);
                Messaging.sendEmail(new Messaging.Singleemailmessage[]{email});       
                System.debug('notifyOnFuterReferralsAssigned finished'); 
            } else {
                System.debug('notifyOnFuterReferralsAssigned do nothing.');
            }
        }catch(Exception e){
            System.debug('notifyOnFuterReferralsAssigned crashed: ' + e);
        }           
	}
	
	public static void onAfterInsert(List<Time_off_Territory_Day_gne__c> triggerNew) {
		if (GNE_SFA2_Util.getCurrentUserProfileName().contains('GNE-MedAffairs-MSL')){
			notifyOnFuterReferralsAssigned(triggerNew);
		}
	}
}