// Created By:  Rajesh Sinha

//Join Case.CaseNumber to Insurance.Case_Insurance_gne__c
//to return a list of all the Insurances where Insurance.Rank_gne__c = Primary
//and Insurance.Bill_Level_gne__c = 1.  Select the last modified Insurance and
//join Insurance.Payer to Account.ID
 

public virtual class SCM_MF_InsuranceCollRankBill_Filter extends SCM_MergeField {
    protected Insurance_gne__c patientInsRankBillFil;
    
    public SCM_MF_InsuranceCollRankBill_Filter(String CaseId)
    {
        checked=false;
        displayCheck=false;
        displayTextBox=false;
        displayLabel=false;
        className = 'SCM_MF_InsuranceCollRankBill_Filter';
        Key='InsuranceCollRankBillFil_Raptiva';
        List<Insurance_gne__c> patientInsRankBillFilList; 
        try{
        patientInsRankBillFilList = [Select i.Id,
            i.Payer_gne__r.Phone, i.Payer_gne__r.Name, i.Group_Num_gne__c,
            i.Subscriber_Name_gne__c,
            i.Subscriber_Num_gne__c,i.ins_Insurance_gne__c,
            i.Case_Insurance_gne__c
            From Insurance_gne__c i
            where i.Case_Insurance_gne__c =: CaseId 
            and i.Bill_Level_gne__c = '1' and i.Rank_gne__c = 'Primary'
            order by i.LastModifiedDate desc LIMIT 100];        
        }catch(Exception e){
            patientInsRankBillFil = null;  
        }
        if(patientInsRankBillFilList.size() >= 1)
        {
            patientInsRankBillFil = patientInsRankBillFilList[0];                        
        }
        else
        {           
            patientInsRankBillFil = null;       
        }
    }

}