//Created By: shobha Rawat

public class SCM_MF_PatientPrimeConHmPh2 extends SCM_MergeField
{
    
    string patientId;
    protected Patient_Contact_gne__c patientContact;
    
    public SCM_MF_PatientPrimeConHmPh2(String patientId)
    {
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        Key='PatientPrimeConHmPh';
        this.patientId=patientId;
    }
         
    public override string getFieldValue()
    { 
        
        string name='';
         
        List<Patient_Contact_gne__c> patientContactList = [Select p.Name, 
        p.LAST_NAME_CONT_gne__c, p.pat_con_Relationship_to_Patient_gne__c, 
        p.pat_con_Street_gne__c, p.pat_con_Mail_Box_gne__c,
        p.pat_con_Home_Phone_gne__c, p.pat_con_Work_gne__c,
        p.pat_con_City_gne__c, p.pat_con_Zip_gne__c, p.First_Name_gne__c
        FROM Patient_Contact_gne__c p 
        WHERE p.pat_con_Patient_gne__c = :patientId 
        And p.pat_con_Contact_Type_gne__c IN ('Primary')
        
        limit 500];
        
        if (patientContactList.size()==0)
        {
            //do nothing
        }
        
        else if(patientContactList.size()>1)
        {
            patientContactList = [Select p.pat_con_Home_Phone_gne__c
            FROM Patient_Contact_gne__c p 
            WHERE p.pat_con_Patient_gne__c = :patientId 
            order by p.LastModifiedDate desc limit 500];
            patientContact= patientContactList[0];
            
            name=patientContact.pat_con_Home_Phone_gne__c;
            
        }
         
        else if (patientContactList.size()==1)
        {       
            patientContactList = [Select p.pat_con_Home_Phone_gne__c
            FROM Patient_Contact_gne__c p 
            WHERE p.pat_con_Patient_gne__c = :patientId
            And p.pat_con_Contact_Type_gne__c IN ('Primary')];
            
            patientContact= patientContactList[0];
            
            name=patientContact.pat_con_Home_Phone_gne__c;       
            
        }
        name= (name==null)? '': name;
        return name;
         
    }
}