/************************************************************
*  @author: Krzysztof Wilczek, Roche
*  Date: 2011-03-18
*  Description: 
*  Creates test data for Interface 5 testing 
*
*  Modification History
*  Date        Name        Description
*                
*************************************************************/
public class GNE_PatPers_IU_Test_Helper 
{
    public static PatPersStructure createTestData(User testUser, String product)
    {
        //******************************** Prepare test data **************************     
        
        String userTail = GlobalUtils.getUserTail(testUser.username);
        PatPersStructure structure = new PatPersStructure();
        
        //PATIENT
        structure.patient = new Patient_gne__c(name = 'Jordan',
                                               pat_first_name_gne__c = 'Michael',
                                               Mid_Initial_gne__c = 'A',
                                               pat_dob_gne__c = Date.newInstance(1969,12,12),
                                               pat_email_gne__c = 'mj@gene.com',
                                               pat_gender_gne__c = 'Male',
                                               pat_home_phone_gne__c = '666',
                                               pat_prefix_gne__c = 'Mr.',
                                               pat_work_phone_gne__c = '222',                                              
                                               Patient_Number_gne__c = '221',
                                               Suffix_gne__c = 'Sr.');
                                               
        //PATIENT ADDRESS
        structure.patientAddress = new Patient_Address_gne__c(Address_Line_1_gne__c = 'George Street 222',
                                                                Address_Line_2_gne__c = 'Building 2',
                                                                City_gne__c = 'San Francisco',
                                                                Country_gne__c = 'USA',                                                             
                                                                Phone_gne__c = '666',
                                                                Primary_Address_gne__c = 'Yes',
                                                                Release_gne__c = 'test release',
                                                                State_gne__c = 'CA',
                                                                Type_gne__c = 'Home',
                                                                Validated_gne__c = 'Yes',
                                                                Zip_gne__c = '74106',
                                                                Patient_gne__r = structure.patient);
                                                                
        //PATIENT CONTACT
        structure.patientContact = new Patient_Contact_gne__c(Country_gne__c = 'USA',
                                                                First_Name_gne__c = 'Dorothy',
                                                                LAST_NAME_CONT_gne__c = 'Jordan',
                                                                pat_con_City_gne__c = 'San Francisco',
                                                                pat_con_Email_gne__c = 'djordan@gmail.com',
                                                                pat_con_Home_Phone_gne__c = '666',
                                                                pat_con_Mail_Box_gne__c = '333',
                                                                pat_con_Prefix_gne__c = 'Mrs.',
                                                                pat_con_State_gne__c = 'CA',
                                                                pat_con_Street_gne__c = 'Highland Ave',
                                                                pat_con_Work_gne__c = '222',
                                                                pat_con_Zip_gne__c = '74106',
                                                                pat_con_Patient_gne__r = structure.patient);
                                                                
        //ICD9 code
        structure.icd9 = new ICD9_Code_gne__c(name = 'ICD9 code for Xeloda',
                                                    ICD9_Code_gne__c = '154.0',
                                                    ICD9_Descrption_gne__c = 'test ICD9 code description');
                    
        //MEDICAL HISTORY
        Id productId = Schema.SObjectType.Medical_History_gne__c.getRecordTypeInfosByName().get(product).getRecordTypeId();
        structure.medicalHistory = new Medical_History_gne__c(recordTypeId = productId,                                                             
                                                                Patient_Med_Hist_gne__r = structure.patient,
                                                                Tumor_Staging_gne__c ='Stage III (Early Local Disease)',                                                                
                                                                ICD9_Code_1_gne__r = structure.icd9);
                                               
        return structure;
    }
    
    public class PatPersStructure
    {
        public Patient_gne__c patient { get; set; }
        public ICD9_Code_gne__c icd9 { get; set; }
        public Medical_History_gne__c medicalHistory { get; set; }      
        public Patient_Address_gne__c patientAddress { get; set; } 
        public Patient_Contact_gne__c patientContact { get; set; }      
    }
}