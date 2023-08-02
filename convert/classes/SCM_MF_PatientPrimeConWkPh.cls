//created by : Shobha Rawat

//Join Case.Patient_gne__c to Patient.PatientID_gne__c 
//and join Patient.PatientID_gne__c to Patient Contact.pat_con_Patient_gne__c to 
//return a list of Patient Contact objects
//If count of Patient Contact = 0, then merge ""
//If count of Patient Contact = 1, then merge Patient Contact.pat_con_Work_gne__c
//If count of Patient Contact > 1, 
//then return a list of Patient Contact objects where Patient Contact.pat_con_Contact_Type_gne__c  = Primary
//If count of Patient Contact = 0, then merge patient contact.pat_con_Work_gne__c where last modified
//If count of Patient Contact = 1, then merge Patient Contact.pat_con_Work_gne__c
//If count of Patient Contact > 1, then merge patient contact.pat_con_Work_gne__c where last modified



public class SCM_MF_PatientPrimeConWkPh extends SCM_MergeField {



	string patientId;
    protected Patient_Contact_gne__c patientContact;
    protected Patient_Contact_gne__c patientContact1;
    protected Patient_Contact_gne__c patientContact2;
    
    public SCM_MF_PatientPrimeConWkPh(String patientId)
    {
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        this.patientId=patientId;
        key='PatientPrimeConWkPh';
    }
         
    public override string getFieldValue() { 
        
        string name='';
        system.debug('====================11======================='); 
        List<Patient_Contact_gne__c> patientContactList = [Select p.pat_con_Work_gne__c
        FROM Patient_Contact_gne__c p 
        WHERE p.pat_con_Patient_gne__c = :patientId
        limit 100 ];
               
        
        if (patientContactList.size()==0) {
        	name='';
        }        
        else if(patientContactList.size()==1) {
        	patientContact = patientContactList[0];
        	name = patientContact.pat_con_Work_gne__c;
        }        
        else if (patientContactList.size()>1) {	
        	system.debug('====================22=======================');	
        	List<Patient_Contact_gne__c>patientContactList1 = [Select  p.pat_con_Work_gne__c
        	FROM Patient_Contact_gne__c p 
	        WHERE p.pat_con_Patient_gne__c = :patientId
	        And p.pat_con_Contact_Type_gne__c IN ('Primary')
	        limit 500];
	        
	        if(patientContactList1.size() == 0) {
	        	name='';
	        }
	        else if(patientContactList.size()==1) {
	        	patientContact1 = patientContactList1[0];
	        	name = patientContact.pat_con_Work_gne__c;
	        }
	        else if(patientContactList.size()>1) {
	        	system.debug('====================44=======================');
	        	List<Patient_Contact_gne__c>patientContactList2 = [Select  p.pat_con_Work_gne__c
	        	FROM Patient_Contact_gne__c p 
	        	WHERE p.pat_con_Patient_gne__c = :patientId
	        	And p.pat_con_Contact_Type_gne__c IN ('Primary')
	        	order by p.LastModifiedDate desc limit 100];
	        	system.debug('===================54=======================');
            	patientContact2 = patientContactList2[0];	
	        	name = patientContact2.pat_con_Work_gne__c;
	        } 	
        	
        }
        name= (name==null)? '': name;
        return name;
   }  

}