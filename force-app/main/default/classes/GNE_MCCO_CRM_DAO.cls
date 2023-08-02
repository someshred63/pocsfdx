/******************************************************************************************
*  @author: Michal Hrycenko, Roche (contractor)
*  @email: michal.hrycenko@contractors.roche.com
*  Created: 2015-07-20
*  Project: OTR2
*  Description: Data Abstraction Object for the MCCO CRM project.
*******************************************************************************************/
public with sharing class GNE_MCCO_CRM_DAO {
	
	public static List<TSF_vod__c> getAccountsIdsFromTSFs(List<String> territories) {
        return  [
            SELECT
                Account_vod__c,
                Account_vod__r.RecordType.Name
            FROM
                TSF_vod__c
            WHERE
                    External_Id_vod__c != null 
                AND Address_vod__c != null 
                AND Account_vod__r.IsPersonAccount = false
                AND Territory_vod__c IN : territories
        ];
    }
}