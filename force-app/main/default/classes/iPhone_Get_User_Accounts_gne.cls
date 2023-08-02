/**************************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, returns a list of AccountIds for the specified user id (unixId).
***************************************************************************************************/
@RestResource(urlMapping = '/iPhoneGetUserAccounts/*')
global with sharing class iPhone_Get_User_Accounts_gne {

    @HttpPost
    global static iPhone_Commons_gne.RestResponse processRequest(String unixId, List<String> territoriesIds) {
        return iPhone_Commons_gne.buildResponse(
                   new GetUserAccountsResponseBuilder(territoriesIds),
                   unixId
               );
    }

    static Pattern isCFTUserPattern = Pattern.compile('^(GNE-MCCO-CFT).*');
    static Pattern isPFTUserPattern = Pattern.compile('^(GNE-MCCO PFT)|^(GNE-MCCO-PFT).*');

    public without sharing class GetUserAccountsResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {

        public List<String> territoriesIds {get; set;}

        public GetUserAccountsResponseBuilder(List<String> territoriesIds) {
            this.territoriesIds = territoriesIds;
        }

        public iPhone_Commons_gne.RestResponse build(Object unixId) {
            List<Account> accounts = getAccountsForUnixId((String)unixId);
            List<GetUserAccountsRecord> records = new List<GetUserAccountsRecord>();
            List<String> affRecords = new List<String>();
            for (Account account : accounts) {
                records.add(new GetUserAccountsRecord(account));
            }
            for(Affiliation_vod__c aff: [SELECT To_Account_vod__c FROM Affiliation_vod__c WHERE From_Account_vod__c IN :accounts AND To_Contact_vod__c = null AND To_Account_vod__r.isPersonAccount = true ]) {
                affRecords.add(aff.To_Account_vod__c);
            }
            return new GetUserAccountsResponse(records, affRecords);
        }

        private List<Account> getAccountsForUnixId(String unixId) {
            User user = iPhone_DAO.getUserByExternalId(unixId);
            List<Territory2> territories = iPhone_DAO.getTerritories(territoriesIds);
            List<String> territoriesName = iPhone_StringUtil.buildStringList(territories, 'Name');
            List<TSF_vod__c> tsfs = getTSFForTerritoriesName(territoriesName, user);
            List<Call2_vod__c> calls = iPhone_DAO.getCallsCreatedByUser(user);
            List<Medical_Communication_gne__c> medComms = iPhone_DAO.getMedicalCommunicationsAccountsByUserUnixId(unixId);
            List<Change_Request_gne__c> dcrs = iPhone_DAO.getDCRsAccountsByUserUnixId(unixId);
            
            Set<String> accountIds = iPhone_StringUtil.buildStringSet(tsfs, 'Account_vod__c');
            accountIds.addAll(iPhone_StringUtil.buildStringSet(calls, 'Account_vod__c'));
            accountIds.addAll(iPhone_StringUtil.buildStringSet(medComms, 'Account_gne__c'));
            accountIds.addAll(iPhone_StringUtil.buildStringSet(dcrs, 'Account_gne__c'));

            if (user.Profile_Name_gne__c.containsIgnoreCase('MedAffairs')) {
                List<Referral_Assignment_gne__c> referrals = iPhone_DAO.getReferralAssignmentByUserId(user.Id);
                Set<String> accountIdsFromReferrals = iPhone_StringUtil.buildStringSet(referrals, 'AccountId_gne__c');
                accountIds.addAll(accountIdsFromReferrals);
            }
            return iPhone_DAO.getAccountsByIds(accountIds);
        }

        private List<TSF_vod__c> getTSFForTerritoriesName(List<String> territoriesName, User user) {
        	if (iPhone_REST_Utils.getOnlyTargetedAccounts() && GNE_SFA2_Util.isCanadaUser()){
        		List<String> filterConditions = new List<String>{
        			//' AND Account_vod__r.IsPersonAccount = false ',
        			' AND Account_vod__r.IsPersonAccount = true ' + GNE_SFA2_MyAccounts_Controller.getMyTargetAndTiersTsfQueryCondition(territoriesName)
        		};
        		List<TSF_vod__c> tsfs = new List<TSF_vod__c>();
        		for (String filterExt : filterConditions){
        			tsfs.addAll(getTSFForTerritoriesName(territoriesName, user, filterExt));
        		}
        		return tsfs;
        	} else {
        		return getTSFForTerritoriesName(territoriesName, user, null);
        	}
        }

        private List<TSF_vod__c> getTSFForTerritoriesName(List<String> territoriesName, User user, String additionalCondition) {
            String query = 'SELECT Id, Account_vod__c ' +
                           'FROM TSF_vod__c ' +
                           'WHERE Territory_vod__c in :territoriesName ' +
                           'AND Address_vod__c != null ' +
                           'AND External_Id_vod__c != null ';

            if (iPhone_REST_Utils.getOnlyTargetedAccounts()) {
            	query += 'AND My_Target_vod__c = true ';
            }

            if (iPhone_REST_Utils.getOnlyHCOSAccounts() || isCFTUserPattern.matcher(user.Profile_Name_gne__c.toUpperCase()).matches() || isPFTUserPattern.matcher(user.Profile_Name_gne__c.toUpperCase()).matches()) {
                query += 'AND Account_vod__r.IsPersonAccount = false ';
            }

            if (isPFTUserPattern.matcher(user.Profile_Name_gne__c.toUpperCase()).matches()) {
                query += 'AND Account_vod__r.Target__c = true ';
            }

            if (String.isNotBlank(additionalCondition)){
            	query += additionalCondition;
            }

            return Database.query(query);
        }
    }

    public class GetUserAccountsResponse extends iPhone_Commons_gne.RestResponse {
        public final List<RestRecord> records;
        public final List<String> affRecords;

        public GetUserAccountsResponse(List<RestRecord> records, List<String> affRecords) {
            this.records = records;
            this.affRecords = affRecords;
        }
    }

    class GetUserAccountsRecord extends iPhone_Commons_gne.RestRecord {

        public GetUserAccountsRecord(Account account) {
            this.id = account.id;
        }
    }
}