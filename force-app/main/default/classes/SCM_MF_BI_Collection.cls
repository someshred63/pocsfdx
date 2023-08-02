//Added By Haraprasad Uttaray
public virtual class SCM_MF_BI_Collection extends SCM_MergeField
{
    public Benefit_Investigation_gne__c BenefitInvest;
    public SCM_MF_BI_Collection(String patientId)
    {
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        
        List<Benefit_Investigation_gne__c> Bene = [Select b.Benefit_Type_gne__c, b.Authorization_No_gne__c, b.Authorization_Effective_Date_gne__c, b.Recertification_Date_gne__c, b.Drug_Billing_Code_gne__c, b.INC_Patient_Amount_gne__c,IN_Max_Benefit_Amount_Used_gne__c,IN_Pocket_Individual_gne__c 
                                           From Benefit_Investigation_gne__c b where b.Patient_BI_gne__r.ID=:patientId Order By b.LastModifiedDate desc LIMIT 10];
        if(Bene.size() >= 1)
        {
            BenefitInvest= Bene[0];                        
        }            
        else
        {           
            BenefitInvest = null;       
        }                                                
        
    }    

}