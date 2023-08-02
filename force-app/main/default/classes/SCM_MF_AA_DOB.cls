public class SCM_MF_AA_DOB extends SCM_MergeField{
public SCM_MF_AA_DOB(Case SelectedCase)
    {
        Case SelCase = SelectedCase;
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        key = 'AntAccs_DOB';
        displayLabel = false;
        
        try {
        List<Patient_gne__c> Pat = [select  p.PAN_Form_1_Product_gne__c, 
                                            p.Pat_DOB_gne__c
                                       From Patient_gne__c p 
                                      where id = :selectedCase.Patient_gne__c 
                                        and PAN_Form_1_Product_gne__c = 'Rituxan RA'
                                    limit 1];
            if (pat.size() > 0){
                if (pat[0].PAN_Form_1_Product_gne__c != null && 
                    pat[0].PAN_Form_1_Product_gne__c == 'Rituxan RA'){
                    if (pat[0].Pat_DOB_gne__c!= null) {
                        fieldvalue = string.valueof(pat[0].Pat_DOB_gne__c);
                    }
                }
            }   
            else {
                fieldValue = 'No DOB on file';
                
            }
            if (fieldvalue == null)
                fieldvalue = 'No DOB on file';
        }catch (Exception ex) {
            fieldValue = '';
        }
    }
    
}