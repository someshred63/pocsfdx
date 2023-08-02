global without sharing class EMS_Subscribe_iHCP_Batch implements Database.Batchable<sObject>, Database.Stateful {

    global Set<String> iHCPIds = new Set<String>();

    global Database.QueryLocator start(Database.BatchableContext BC) {

        String query = 'SELECT First_Name_gne__c, Last_Name_gne__c, Middle_Name_gne__c, Email_gne__c,   IHCP_ID_gne__c, IHCP_Created_Date_gne__c, IHCP_Last_Modified_Date_gne__c, IHCP_Name_gne__c, ' +
                'Inactive_Indicator_gne__c, Institution_gne__c, Phone_gne__c, Position_gne__c, Profession_gne__c, Speciality_gne__c, Speciality_MS_gne__c, State_Province_gne__c, Subscribe_Status_gne__c, Title_gne__c, Zip_gne__c, ' +
                'Address_gne__c, Address_2_gne__c, Affiliation_gne__c, City_gne__c, Country_gne__c, Delta_Instruction_gne__c FROM Stg_EMS_iHCP_gne__c WHERE Subscribe_Status_gne__c = \'Not Processed\' ';


        return Database.getQueryLocator(query);
    }


    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<EMS_International_Speaker_gne__c> speakersToUpsert = new List<EMS_International_Speaker_gne__c>();
        List<Stg_EMS_iHCP_gne__c> stagingRecordsToUpdate = new List<Stg_EMS_iHCP_gne__c>();

        Map<String, EMS_International_Speaker_gne__c> existingSpeakers = new Map<String, EMS_International_Speaker_gne__c>();
        for (EMS_International_Speaker_gne__c ihcp : [SELECT Id, IHCP_ID_gne__c FROM EMS_International_Speaker_gne__c]) {
            existingSpeakers.put(ihcp.IHCP_ID_gne__c, ihcp);
        }

        List<Stg_EMS_iHCP_gne__c> ihcps = (List<Stg_EMS_iHCP_gne__c>) scope;
        for (Stg_EMS_iHCP_gne__c ihcp : ihcps) {
            EMS_International_Speaker_gne__c speaker;

            if (ihcp.Delta_Instruction_gne__c.equalsIgnoreCase('I')) {
                // create new speaker
                speaker = new EMS_International_Speaker_gne__c();
            } else if (ihcp.Delta_Instruction_gne__c.equalsIgnoreCase('U')) {
                // update existing speaker
                speaker = existingSpeakers.get(ihcp.IHCP_ID_gne__c);
                if (speaker == null) {
                    // no speaker was found
                    ihcp.Subscribe_Status_gne__c = 'Failed';
                    ihcp.Error_Message_gne__c = 'No speaker with specified iHCP ID was found';
                    stagingRecordsToUpdate.add(ihcp);
                    continue;
                }
            } else {
                // invalid delta operation was specified
                ihcp.Subscribe_Status_gne__c = 'Failed';
                ihcp.Error_Message_gne__c = 'Invalid Delta Instruction specified';
                stagingRecordsToUpdate.add(ihcp);
                continue;
            }

            speaker.Name = ihcp.First_Name_gne__c + ' ' + ihcp.Last_Name_gne__c;
            speaker.First_Name_gne__c = ihcp.First_Name_gne__c;
            speaker.Last_Name_gne__c = ihcp.Last_Name_gne__c;
            speaker.Middle_Name_gne__c = ihcp.Middle_Name_gne__c;
            speaker.Address_gne__c = ihcp.Address_gne__c;
            speaker.Address_2_gne__c = ihcp.Address_2_gne__c;
            speaker.Affiliation_gne__c = ihcp.Affiliation_gne__c;
            speaker.State_Province_gne__c = ihcp.State_Province_gne__c;
            speaker.Zip_gne__c = ihcp.Zip_gne__c;
            speaker.City_gne__c = ihcp.City_gne__c;
            speaker.Country_gne__c = ihcp.Country_gne__c;
            speaker.Email_gne__c = ihcp.Email_gne__c;
            speaker.Phone_gne__c = ihcp.Phone_gne__c;
            speaker.Institution_gne__c = ihcp.Institution_gne__c;
            speaker.Position_gne__c = ihcp.Position_gne__c;
            speaker.Profession_gne__c = ihcp.Profession_gne__c;
            speaker.Speciality_gne__c = ihcp.Speciality_gne__c;
            speaker.Speciality_MS_gne__c = ihcp.Speciality_MS_gne__c;
            speaker.Title_gne__c = ihcp.Title_gne__c;

            // fill iHCP system details
            speaker.IHCP_ID_gne__c = ihcp.IHCP_ID_gne__c;
            speaker.IHCP_Name_gne__c = ihcp.IHCP_Name_gne__c;
            speaker.IHCP_Created_Date_gne__c = ihcp.IHCP_Created_Date_gne__c;
            speaker.IHCP_Last_Modified_Date_gne__c = ihcp.IHCP_Last_Modified_Date_gne__c;


            // mark inactive iHCPs
            if (ihcp.Inactive_Indicator_gne__c == 1) {
                speaker.Is_Active_gne__c = false;
            } else {
                speaker.Is_Active_gne__c = true;
            }

            if (speaker.IHCP_ID_gne__c == null || !iHCPIds.contains(speaker.IHCP_ID_gne__c)) {
                speakersToUpsert.add(speaker);
                stagingRecordsToUpdate.add(ihcp);
            }

            // add IHCP id with the speaker was already updated
            if (speaker.IHCP_ID_gne__c != null) {
                iHCPIds.add(speaker.IHCP_ID_gne__c);
            }
        }

        if (speakersToUpsert.size() > 0) {
            List<Database.UpsertResult> results = Database.upsert(speakersToUpsert, false);

            for (Integer i = 0; i < results.size(); i++) {
                Stg_EMS_iHCP_gne__c stagingRecord = stagingRecordsToUpdate.get(i);
                if (results[i].isSuccess()) {
                    stagingRecord.EMS_International_Speaker_gne__c = results[i].getId();
                    stagingRecord.Subscribe_Status_gne__c = 'Processed';
                } else {
                    stagingRecord.Subscribe_Status_gne__c = 'Failed';
                    stagingRecord.Error_Message_gne__c = results[i].getErrors()[0].getMessage();
                }
            }
        }

        if (stagingRecordsToUpdate.size() > 0) {
            update stagingRecordsToUpdate;
        }
    }

    global void finish(Database.BatchableContext BC) {

		AsyncApexJob a = [SELECT Id FROM AsyncApexJob WHERE Id =:BC.getJobId()];
		
		List<String> mails = EMS_Util.getApplicationAdminsEmails();
			
    	EMS_Email.prepareSingleEmail('EMS_Batch_Job_Notification', a.Id, mails);
    	
    	EMS_Email.Send();
    }
}