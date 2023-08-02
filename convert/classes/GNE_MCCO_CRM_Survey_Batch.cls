/* 
 * global class GNE_MCCO_CRM_Survey_Batch implements Database.Batchable<sObject>, Database.Stateful
 *
 * This batch upserts Field Intelligence based on Published Survey and Survey Record Type (General / Account)
 */
global class GNE_MCCO_CRM_Survey_Batch implements Database.Batchable<SObject>, Database.Stateful {

    global final GNE_MCCO_CRM_Survey__c SURVEY;
    global final Map<String, Set<Id>> TERRITORY_NAME_TO_USER_IDS_MAP;
    global final Boolean IS_EDIT;
    global final List<String> TERRITORIES_NAMES;
    global final List<String> ACCOUNT_IDS;
    global Set<String> fisForAccountsAndUsers;
    global Set<String> tsfsForAccountsAndUsers;
    global Integer fieldUpdated = 0;
    global Integer fieldInserted = 0;
    global Integer fieldHidden = 0;
    global Integer fieldTotalActive = 0;

    global GNE_MCCO_CRM_Survey_Batch(String surveyJson, Boolean edit) {
        SURVEY = (GNE_MCCO_CRM_Survey__c) JSON.deserialize(surveyJson, GNE_MCCO_CRM_Survey__c.class);
        TERRITORY_NAME_TO_USER_IDS_MAP = GNE_MCCO_CRM_Survey_Util.getUsersTerrs();
        System.debug('TERRITORY_NAME_TO_USER_IDS_MAP: ' + TERRITORY_NAME_TO_USER_IDS_MAP);

        IS_EDIT = edit;
        TERRITORIES_NAMES = String.isNotEmpty(SURVEY.Territories_Names_gne__c) ? SURVEY.Territories_Names_gne__c.split(';') : new List<String>();
        ACCOUNT_IDS = String.isNotEmpty(SURVEY.Account_Ids_gne__c) ? SURVEY.Account_Ids_gne__c.split(';') : new List<String>();
        fisForAccountsAndUsers = new Set<String>();
        System.debug('ACCOUNT_IDS: ' + ACCOUNT_IDS);
        System.debug('TERRITORIES_NAMES: ' + TERRITORIES_NAMES);
        if (IS_EDIT) {
            List<TSF_vod__c> tsfs;
            if (ACCOUNT_IDS.isEmpty() || TERRITORIES_NAMES.isEmpty()) {
                tsfs = [SELECT Account_vod__c, Territory_vod__c FROM TSF_vod__c WHERE (Territory_vod__c IN :TERRITORIES_NAMES OR Account_vod__c IN :ACCOUNT_IDS) AND External_Id_vod__c != NULL AND Address_vod__c != NULL];
            } else {
                tsfs = [SELECT Account_vod__c, Territory_vod__c FROM TSF_vod__c WHERE (Territory_vod__c IN :TERRITORIES_NAMES AND Account_vod__c IN :ACCOUNT_IDS) AND External_Id_vod__c != NULL AND Address_vod__c != NULL];
            }
            tsfsForAccountsAndUsers = prepareTSFsForAcctAndUsers(tsfs);
        }
    }

    global GNE_MCCO_CRM_Survey_Batch(String surveyJson, Boolean edit, String acctAndUsersForFI, Integer fieldAlreadyUpdated, Integer fieldAlreadyInserted, Integer fieldAlreadyHidden, Integer fieldAlreadyTotalActive) {
        fieldUpdated = fieldAlreadyUpdated;
        fieldInserted = fieldAlreadyInserted;
        fieldHidden = fieldAlreadyHidden;
        fieldTotalActive = fieldAlreadyTotalActive;
        SURVEY = (GNE_MCCO_CRM_Survey__c) JSON.deserialize(surveyJson, GNE_MCCO_CRM_Survey__c.class);
        TERRITORY_NAME_TO_USER_IDS_MAP = GNE_MCCO_CRM_Survey_Util.getUsersTerrs();
        IS_EDIT = edit;
        TERRITORIES_NAMES = String.isNotEmpty(SURVEY.Territories_Names_gne__c) ? SURVEY.Territories_Names_gne__c.split(';') : new List<String>();
        ACCOUNT_IDS = new List<String>();
        fisForAccountsAndUsers = new Set<String>();
        for (String tau : (Set<String>) JSON.deserialize(acctAndUsersForFI, Set<String>.class)) {
            ACCOUNT_IDS.add(tau.split('_').get(0));
        }
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        String query = '';
        if (IS_EDIT) {
            Id surveyId = SURVEY.Id;
            query += 'SELECT Id, Account_gne__c, User_gne__c, Available_gne__c, Comment_gne__c FROM GNE_MCCO_CRM_Field_Intelligence__c WHERE Survey_gne__c = :surveyId';
        } else {
            if (ACCOUNT_IDS.isEmpty() || TERRITORIES_NAMES.isEmpty()) {
                query += 'SELECT Account_vod__c, Territory_vod__c FROM TSF_vod__c WHERE (Territory_vod__c IN :TERRITORIES_NAMES OR Account_vod__c IN :ACCOUNT_IDS) AND External_Id_vod__c != null AND Address_vod__c != null';
            } else {
                query += 'SELECT Account_vod__c, Territory_vod__c FROM TSF_vod__c WHERE (Territory_vod__c IN :TERRITORIES_NAMES AND Account_vod__c IN :ACCOUNT_IDS) AND External_Id_vod__c != null AND Address_vod__c != null';
            }
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<SObject> scope) {
        if (IS_EDIT) {
            updateFieldIntelligences(scope);
        } else {
            createFieldIntelligences(scope);
        }
    }

    global void finish(Database.BatchableContext BC) {
        if (tsfsForAccountsAndUsers != null && !tsfsForAccountsAndUsers.isEmpty()) {
            System.debug('Need to add ' + tsfsForAccountsAndUsers.size() + ' Field Intelligences.');
            Database.executeBatch(new GNE_MCCO_CRM_Survey_Batch(JSON.serializePretty(SURVEY), false, JSON.serializePretty(tsfsForAccountsAndUsers), fieldUpdated, fieldInserted, fieldHidden, fieldTotalActive), 200);
        } else {
            System.debug('No Field Intelligence to add.');
            System.debug('# Field Updated : ' + fieldUpdated);
            System.debug('# Field Inserted : ' + fieldInserted);
            System.debug('# Field Hidden : ' + fieldHidden);
            System.debug('# Total Active Field Intelligences : ' + fieldTotalActive);
            sendEmails();
        }
    }

    global void sendEmails() {
        Set<String> sendToCC = new Set<String>();
        Set<String> sendTo = new Set<String>();

        for (GNE_MCCO_CRM_Admin_Mode__c notification : [SELECT SetupOwnerId, SetupOwner.Name, SetupOwner.Email FROM GNE_MCCO_CRM_Admin_Mode__c WHERE Name LIKE '%(User)' AND Survey_Builder_Notifications_gne__c = TRUE]) {
            sendToCC.add(notification.SetupOwner.Email);
        }
        sendTo.add(UserInfo.getUserEmail());
        sendToCC.remove(UserInfo.getUserEmail());

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        mail.setToAddresses(new List<String>(sendTo));
        mail.setCcAddresses(new List<String>(sendToCC));

        mail.setSubject('Survey Builder - Field Intelligences on Survey ' + SURVEY.Title_gne__c);

        String body = '<h2>Hello ' + UserInfo.getName() + '!</h2>';
        body += 'You have successfully created / updated Field Intelligences on Survey <strong>' + SURVEY.Title_gne__c + '</strong> (<a href="' + Url.getSalesforceBaseUrl().toExternalForm() + '/apex/GNE_MCCO_CRM_Survey_Builder_Detail?id=' + SURVEY.Id + '" target="_blank">' + SURVEY.Id + '</a>)<br/><br/>';
        body += '<strong>Updated Field Intelligences</strong> : ' + fieldUpdated + '<br/>';
        body += '<strong>Hidden Field Intelligences</strong> : ' + fieldHidden + '<br/>';
        body += '<strong>New Field Intelligences</strong> : ' + fieldInserted + '<br/><br/>';
        body += '<strong>Total Active Field Intelligences</strong> : ' + fieldTotalActive + '<br/><br/>';

        mail.setHtmlBody(body);
        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{
                mail
        });
    }

    global void createFieldIntelligences(List<SObject> scope) {
        List<GNE_MCCO_CRM_Field_Intelligence__c> fiToInsert = new List<GNE_MCCO_CRM_Field_Intelligence__c>();
        for (SObject s : scope) {
            TSF_vod__c tsf = (TSF_vod__c) s;
            System.debug(tsf.Territory_vod__c);
            if (TERRITORY_NAME_TO_USER_IDS_MAP.containsKey(tsf.Territory_vod__c) && !TERRITORY_NAME_TO_USER_IDS_MAP.get(tsf.Territory_vod__c).isEmpty()) {
                for (Id uId : TERRITORY_NAME_TO_USER_IDS_MAP.get(tsf.Territory_vod__c)) {
                    if (!fisForAccountsAndUsers.contains(tsf.Account_vod__c + '_' + uId)) {
                        fisForAccountsAndUsers.add(tsf.Account_vod__c + '_' + uId);
                        fiToInsert.add(
                                new GNE_MCCO_CRM_Field_Intelligence__c(
                                        Available_gne__c = true,
                                        Account_gne__c = tsf.Account_vod__c,
                                        User_gne__c = uId,
                                        Survey_gne__c = SURVEY.Id
                                )
                        );
                        fieldInserted++;
                        fieldTotalActive++;
                    }
                }
            }
        }

        if (!fiToInsert.isEmpty()) {
            insert fiToInsert;
        }
    }

    global void updateFieldIntelligences(List<SObject> scope) {
        List<GNE_MCCO_CRM_Field_Intelligence__c> fiToUpsert = new List<GNE_MCCO_CRM_Field_Intelligence__c>();
        for (SObject s : scope) {
            GNE_MCCO_CRM_Field_Intelligence__c fi = (GNE_MCCO_CRM_Field_Intelligence__c) s;
            String au = fi.Account_gne__c + '_' + fi.User_gne__c;
            if (tsfsForAccountsAndUsers.contains(au)) {
                if (!fi.Available_gne__c) {
                    fi.Available_gne__c = true;
                    fi.Comment_gne__c = null;
                    fieldUpdated++;
                }
                fieldTotalActive++;
            } else if (fi.Available_gne__c) {
                fi.Available_gne__c = false;
                fi.Comment_gne__c = System.now().format('MM/dd/yyyy') + ' - survey hidden as user / account should no longer see the survey.';
                fieldHidden++;
            }
            tsfsForAccountsAndUsers.remove(au);
            fiToUpsert.add(fi);
        }
        if (!fiToUpsert.isEmpty()) {
            upsert fiToUpsert;
        }
    }

    global Set<String> prepareTSFsForAcctAndUsers(List<TSF_vod__c> tsfs) {
        Set<String> result = new Set<String>();
        for (TSF_vod__c tsf : tsfs) {
            if (TERRITORY_NAME_TO_USER_IDS_MAP.containsKey(tsf.Territory_vod__c)) {
                for (Id uId : TERRITORY_NAME_TO_USER_IDS_MAP.get(tsf.Territory_vod__c)) {
                    result.add(tsf.Account_vod__c + '_' + uId);
                }
            }
        }
        System.debug('prepareTSFsForAcctAndUsers: ' + result);
        return result;
    }

}