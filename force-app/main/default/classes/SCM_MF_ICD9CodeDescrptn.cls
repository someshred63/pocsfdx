//Condition is as follows
//Join Case.Medical_History_gne__c to Medical History.ID and select
// Medical History.ICD9_Code_1_gne__c.  Join Medical History.ICD9_Code_1_gne__c to 
// ICD9 Code.ICD9_Code_gne_c and merge ICD9.ICD9_Code_gne__c || ICD9 Code.ICD9_Descrption_gne__c
public class SCM_MF_ICD9CodeDescrptn extends SCM_MergeField 
{
    public SCM_MF_ICD9CodeDescrptn(String medical_History_gne_c)
    {
      
      checked=false;
      displayCheck=false;
      displayTextBox=false;
      displayLabel=false;
      Key='ICD9CodeDescrptn';
      className='SCM_MF_ICD9CodeDescrptn';
      fieldValue = obtainICD9CodeDescrptn(medical_History_gne_c);
    }
    public String obtainICD9CodeDescrptn(String medical_History_gne_c)
    {
    	try {
       String returnString='';
       List<Medical_History_gne__c> ListMedical = [Select m.Id, m.ICD9_Code_1_gne__r.ICD9_Code_gne__c, 
       m.ICD9_Code_1_gne__r.ICD9_Descrption_gne__c, m.ICD9_Code_1_gne__c From Medical_History_gne__c m 
       where  m.id=:medical_History_gne_c
        order by m.LastModifiedDate desc LIMIT 1];
        
        if(ListMedical.size()>0)
        {
         returnString=ListMedical[0].ICD9_Code_1_gne__r.ICD9_Code_gne__c +' '+ListMedical[0].ICD9_Code_1_gne__r.ICD9_Descrption_gne__c;
        }
       if(returnString==null)
       {
       returnString='';
       } 
       return returnString;
    }
     catch (exception ex) {
   	return '';
   }
    }
    
     public override String getFieldvalue()
   {
    return fieldValue;
   }
}