/************************************************************
*  @author: Krzysztof Wilczek, Roche
*  Date: 2011-02-16
*  Description: 
*  
*  Modification History
*  Date        Name        Description
*  Xeloda           
*************************************************************/
public class GNE_PatPers_IU_Support_4697 extends GNE_PatPers_IU_Support_Base 
{
    GNE_PatPers_IU_Utility util = new GNE_PatPers_IU_Utility();    
    
    public override List<GNE_PatPers_IU_SurveyInfo> getSurveyList(String transactionID, String segmentID, String patientID, GNE_PatPers_IU_PatientAndAddressInfo patient,
                                                Medical_History_gne__c mHist, Case casePractice, Address_vod__c addyPractice, Insurance_gne__c insPrimary,
                                                Address_vod__c addyPrim, Insurance_gne__c insSecondary, Address_vod__c addySecondary,
                                                ProfileID_License_gne__c[] profile, Date productShipDate, String preferredMethodOfContact)
	{
    	System.debug('In Support_4697');
        List<GNE_PatPers_IU_SurveyInfo> surveyList = new List<GNE_PatPers_IU_SurveyInfo>();
        
        if (patient.pat_dob != null)
        {
            GNE_PatPers_IU_SurveyInfo survey1 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
            survey1.questionNumber = '22';
            if (GlobalUtils.getAge(patient.pat_dob) >= 18)
            {
                survey1.answerNumber = '189';
                survey1.answerText = 'Yes';
            }
            else
            {
                survey1.answerNumber = '188';
                survey1.answerText = 'No';
            }
            surveyList.Add(survey1);
        }
            
        GNE_PatPers_IU_SurveyInfo survey2 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey2.questionNumber = '23';
        if (patient.pat_gender.equals('Male'))
        {
            survey2.answerNumber = '186';
            survey2.answerText = 'Male';
        }   
        else
        {
            survey2.answerNumber = '187';
            survey2.answerText = 'Female';
        }    
        surveyList.Add(survey2);
            
        GNE_PatPers_IU_SurveyInfo survey3 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey3.questionNumber = '24';
        survey3.answerNumber = '190';
        survey3.answerText = 'I have cancer';
        surveyList.Add(survey3);
            
            
            
        GNE_PatPers_IU_SurveyInfo survey4 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey4.questionNumber = '25';
        if (mHist.ICD9_Code_1_gne__r.ICD_version_gne__c == 'ICD-9'
                && (mHist.ICD9_Code_1_gne__r.icd9_code_gne__c.contains('174.') 
                    || mHist.ICD9_Code_1_gne__r.icd9_code_gne__c.contains('175.'))
            )
        {
            survey4.answerNumber = '192';
            survey4.answerText = 'Metastatic breast cancer';
        }
        else if (mHist.ICD9_Code_1_gne__r.ICD_version_gne__c == 'ICD-9'
                 && (mHist.ICD9_Code_1_gne__r.icd9_code_gne__c.equals('154.0') 
                     || mHist.ICD9_Code_1_gne__r.icd9_code_gne__c.equals('154.1') 
                     || mHist.ICD9_Code_1_gne__r.icd9_code_gne__c.equals('154.8'))
                )
        {
            survey4.answerNumber = '193';
            survey4.answerText = 'Metastatic colorectal cancer';
        }
        else if ((mHist.ICD9_Code_1_gne__r.ICD_version_gne__c == 'ICD-9'
                    && mHist.ICD9_Code_1_gne__r.icd9_code_gne__c.contains('153.')) 
                  && mHist.Tumor_Staging_gne__c != null 
                  && mHist.Tumor_Staging_gne__c.contains('Stage III')
                )
        {
            survey4.answerNumber = '194';
            survey4.answerText = 'stage III (Dukes’ C) colon cancer';
        }
        else if ((mHist.ICD9_Code_1_gne__r.ICD_version_gne__c == 'ICD-9'
                    && mHist.ICD9_Code_1_gne__r.icd9_code_gne__c.contains('153.')) 
                  && (mHist.Tumor_Staging_gne__c == null ||!mHist.Tumor_Staging_gne__c.contains('Stage III'))
                )
        {
            survey4.answerNumber = '195';
            survey4.answerText = 'Other/Don’t Know';
        }
        surveyList.Add(survey4);
        
        GNE_PatPers_IU_SurveyInfo survey5 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey5.questionNumber = '26';
        survey5.answerNumber = '196';
        survey5.answerText = 'Yes';
        surveyList.Add(survey5); 
 
        GNE_PatPers_IU_SurveyInfo survey6 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey6.questionNumber = '27';
        if (mHist.Date_of_First_Treatment_gne__c == null)
        {
            survey6.answerNumber = '203';
            survey6.answerText = 'Don’t Know';
        }
        else if (mHist.Date_of_First_Treatment_gne__c.daysBetween(Date.today()) >= 1 &&
            mHist.Date_of_First_Treatment_gne__c.daysBetween(Date.today()) <= 15)
        {
            survey6.answerNumber = '198';
            survey6.answerText = 'Within 1-15 days';
        }
        else if (mHist.Date_of_First_Treatment_gne__c.daysBetween(Date.today()) >= 16 &&
                mHist.Date_of_First_Treatment_gne__c.daysBetween(Date.today()) <= 30)
        {
            survey6.answerNumber = '199';
            survey6.answerText = 'Within 16-30 days';
        }
        else if (mHist.Date_of_First_Treatment_gne__c.daysBetween(Date.today()) >= 31 &&
                mHist.Date_of_First_Treatment_gne__c.daysBetween(Date.today()) <= 45)
        {
            survey6.answerNumber = '200';
            survey6.answerText = 'Within 31-45 days';
        }           
        else if (mHist.Date_of_First_Treatment_gne__c.daysBetween(Date.today()) >= 46 &&
                mHist.Date_of_First_Treatment_gne__c.daysBetween(Date.today()) <= 60)
        {
            survey6.answerNumber = '201';
            survey6.answerText = 'Within 46-60 days';
        }           
        else if (mHist.Date_of_First_Treatment_gne__c.daysBetween(Date.today()) > 60)
        {
            survey6.answerNumber = '202';
            survey6.answerText = 'Over 60 days';
        }           
        else 
        {
            survey6.answerNumber = '203';
            survey6.answerText = 'Don’t Know';
        }                      
        surveyList.Add(survey6);
          
        GNE_PatPers_IU_SurveyInfo survey7 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey7.questionNumber = '28';
        survey7.answerNumber = '206';
        survey7.answerText = 'Unsure';
        surveyList.Add(survey7); 

        GNE_PatPers_IU_SurveyInfo survey11 = new GNE_PatPers_IU_SurveyInfo(transactionID, segmentID, patientID);
        survey11.questionNumber = '1004';
        survey11.answerNumber = '1004';
        survey11.answerText = 'Registration';
        surveyList.Add(survey11);          
            
        return surveyList;
    }
    /*
    @isTest
    public static void testMe()
    {
        //fake number - the source is Transaction_ID__c on Patient Program (Auto Number field)
        String transactionID = '9999999999';
        String brandName = 'Xeloda';
        
        //CREATE PATIENT
        User testUser = GNE_CM_Test_Helper.getCaseManagerUser();
        System.runAs(testUser) 
        {
            GNE_PatPers_IU_Test_Helper.PatPersStructure structure = GNE_PatPers_IU_Test_Helper.createTestData(testUser, brandName);
            insert structure.patient;
            structure.patientAddress.Patient_gne__c = structure.patient.Id;
            insert structure.patientAddress;
            structure.patientContact.pat_con_Patient_gne__c = structure.patient.Id;
            insert structure.patientContact;
            
            GNE_PatPers_IU_support_Helpers pHelpers = new GNE_PatPers_IU_Support_Helpers();
            GNE_PatPers_IU_PatientAndAddressInfo patientAndAddress = pHelpers.GetPatientAndAddressInfo(structure.patient.Id);       
            
            insert structure.icd9;
            structure.medicalHistory.ICD9_Code_1_gne__c = structure.icd9.Id;
            insert structure.medicalHistory;                
            
            //CREATE METHOD OF CONTACT - possible values: Email, Phone, Mail
            String preferredMethodOfContact = 'Email';
            
            GNE_PatPers_InsertUpdate_Trigger_Support ppSupport = new GNE_PatPers_InsertUpdate_Trigger_Support();
            String segmentID = ppSupport.getSegmentIDByProduct(brandName, patientAndAddress, structure.medicalHistory);
            
            Test.startTest();
                System.assertEquals('4697', segmentID);
                GNE_PatPers_IU_Support_4697 pSup = new GNE_PatPers_IU_Support_4697();
                List<GNE_PatPers_IU_SurveyInfo> sur = pSup.getSurveyList(transactionID, segmentID, structure.patient.Id,
                                                        patientAndAddress, structure.medicalHistory, preferredMethodOfContact);
                                                        
                System.assertEquals(8, sur.size());
            Test.stopTest();
        }
        
    }
    */
}