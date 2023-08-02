/**
* @author: GFRS Dev Team
* @date: 17/06/2013
* @description: gFRS_DAO class - Data Access Object class which is dedicated for retrieving data from database. 
* In class methods there should be only appropriate query, which return needed data. Any processing of data should be made in class where the data is needed.
* For now this class should be used only for unit tests and for newly created queries.
*
*/
public with sharing class gFRS_DAOCopay {

  /**
  * @author: GFRS Dev Team
  * @date: 24/01/2014
  * @description: getPaymentHistoryByFundingAllocation method - retrieves list of Payment/Refund History for given Funding Allocation.
  * in query.  
  */
  public static List<GFRS_Copay_Payment_History__c> getPaymentHistoryByFundingAllocation(GFRS_Copay_Funding_Allocation__c fundingAllocation) {
    return [
    SELECT 
      SAP_Doc_ID__c, 
      Status__c 
    FROM GFRS_Copay_Payment_History__c
    WHERE Funding_Allocation__c = : fundingAllocation.Id AND isDeleted = false
    ]; 
  }   
   
  /**
  * @author: GFRS Dev Team
  * @date: 27/01/2014
  * @description: getProfileById method - retrieves Profile for given Id. 
  */
  public static Profile getProfileById(Id profileId) {
    return [
    SELECT 
      Name
    FROM Profile
    WHERE Id = : profileId
    ]; 
  }
  
  
}