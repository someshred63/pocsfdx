public class SCM_MF_PatientDOB extends SCM_MF_PatientField {

  public SCM_MF_PatientDOB(String patientId)
  {
  	super(patientId);
    key = 'Patient_DOB';
    className = 'SCM_MF_PatientDOB';
    checked = false;
    displayCheck = false;
    displayTextBox = false;
    displayLabel = false;
    if(patient!=null && patient.pat_dob_gne__c!=null)
    	fieldValue = patient.pat_dob_gne__c.format();
    else
    	fieldValue = '';
  }
  
  public SCM_MF_PatientDOB(String patientId, string newkey) {
       this(patientId);
        key = newkey;
    }
  public override String getFieldValue()
  {
  	return fieldValue;
  }
}