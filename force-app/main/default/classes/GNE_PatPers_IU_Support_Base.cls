public virtual without sharing class GNE_PatPers_IU_Support_Base 
{
	
 	public virtual List<GNE_PatPers_IU_SurveyInfo> getSurveyList(String transactionID, String segmentID, String patientID, GNE_PatPers_IU_PatientAndAddressInfo patient,
                                                Medical_History_gne__c mHist, Case casePractice, Address_vod__c addyPractice, Insurance_gne__c insPrimary,
                                                Address_vod__c addyPrim, Insurance_gne__c insSecondary, Address_vod__c addySecondary,
                                                ProfileID_License_gne__c[] profile, Date productShipDate, String preferredMethodOfContact) 
	{
		//
		throw new GNE_PatPers_Exception('Method getSurveyList was not override properly for class ' + String.valueOf(this).substring(0,String.valueOf(this).indexOf(':')));
    }
}