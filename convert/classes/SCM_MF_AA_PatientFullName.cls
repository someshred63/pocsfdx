public class SCM_MF_AA_PatientFullName extends SCM_MergeField{
public SCM_MF_AA_PatientFullName(Case SelectedCase)
    {
        Case SelCase = SelectedCase;
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        key = 'AntAccs_PatientFullName';
        displayLabel = false;
        fieldvalue = '';
        
        try {
        List<Patient_gne__c> Pat = [select  p.PAN_Form_1_Product_gne__c, 
                                            p.Name,
                                            p.pat_first_name_gne__c
                                       From Patient_gne__c p 
                                      where id = :selectedCase.Patient_gne__c 
                                        and PAN_Form_1_Product_gne__c = 'Rituxan RA'
                                    limit 1];
            if (pat.size() > 0){
                if (pat[0].PAN_Form_1_Product_gne__c != null && 
                    pat[0].PAN_Form_1_Product_gne__c == 'Rituxan RA'){
                    if (pat[0].pat_first_name_gne__c != null) {
                        fieldvalue += string.valueof(pat[0].pat_first_name_gne__c);
                    }
                    if (pat[0].Name != null) {
                        fieldvalue += (fieldvalue != '') ? ' ' : '';
                        fieldvalue += string.valueof(pat[0].Name);
                    }
                }
            }   
            else {
                fieldValue = 'No Patient on file';
                
            }
            if (fieldvalue == null)
                fieldvalue = 'No Patient on file';
        }catch (Exception ex) {
            fieldValue = '';
        }
    }
    
}