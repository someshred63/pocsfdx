public class SCM_MF_InsuranceFactory {
    private static Insurance_gne__c InsurancePrimary;
    private static Insurance_gne__c InsuranceSecondary;
    private static Insurance_gne__c InsuranceTeriary;
    
    private static Insurance_gne__c getInsurance(String caseID, String rank, String billLevel)
    {
        Insurance_gne__c Insurance = new Insurance_gne__c();
        
        if(rank.ToLowerCase() == '1')
        {
            Insurance = InsurancePrimary;
        }
        else if(rank.ToLowerCase() == '2')
        {
            Insurance = InsuranceSecondary;
        }
        else if(rank.ToLowerCase() == '3')
        {
            Insurance = InsuranceSecondary;
        }
        
        if( Insurance == null )
        {
            try
            {
            Insurance = [SELECT i.id, i.LastModifiedDate, i.Payer_gne__c, i.Case_Insurance_gne__r.CaseNumber,
                                i.Payer_gne__r.Name, i.Payer_gne__r.Phone, i.Subscriber_Name_gne__c,
                                i.Subscriber_Num_gne__c, i.Group_Num_gne__c, i.Employer_gne__c,
                                i.Case_Insurance_gne__c, i.Bill_Level_gne__c, i.Rank_gne__c
                           FROM Insurance_gne__c i 
                          WHERE i.Case_Insurance_gne__r.CaseNumber=:caseID 
                            AND i.Bill_Level_gne__c=:billLevel
                            AND i.Rank_gne__c=:rank
                       ORDER BY i.LastModifiedDate DESC LIMIT 1];
            }
            catch(Exception ex)
            {
                Insurance = null;
            }
        }

        return Insurance;
    }

    private static SCM_MergeField createMergeField(String key)
    {
        SCM_MergeField mf = new SCM_MergeField();
        mf.key = key;
        mf.checked = false;
        mf.displayCheck = false;
        mf.displayTextBox = false;
        mf.displayLabel = false;
        
        return mf;
    }
    
    public static SCM_MergeField InsuranceNameSMN(Case selectedCase, String rank)
    {
        SCM_MergeField mf = createMergeField('InsuranceNameSMN' + rank);


        if(null != getInsurance(selectedCase.Id, rank, '1'))
        {
            mf.FieldValue = getInsurance(selectedCase.Id, 'Primary', '1').Payer_gne__r.Name;
        }
        else
        {
            mf.FieldValue = '';
        }
        
        return mf;
    }
    
    public static SCM_MergeField InsurancePhoneSMN(Case selectedCase, String rank)
    {
        SCM_MergeField mf = createMergeField('InsurancePhoneSMN' + rank);

        if(null != getInsurance(selectedCase.Id, rank, '1'))
        {
            mf.FieldValue = getInsurance(selectedCase.Id, 'Primary', '1').Payer_gne__r.Phone;
        }
        else
        {
            mf.FieldValue = '';
        }
        
        return mf;
    }
    
    public static SCM_MergeField SubscriberNameSMN(Case selectedCase, String rank)
    {
        SCM_MergeField mf = createMergeField('SubscriberNameSMN' + rank);

        if(null != getInsurance(selectedCase.Id, rank, '1'))
        {
            mf.FieldValue = getInsurance(selectedCase.Id, 'Primary', '1').Subscriber_Name_gne__c;
        }
        else
        {
            mf.FieldValue = '';
        }
        
        return mf;
    }
    
    public static SCM_MergeField SubscriberIDSMN(Case selectedCase, String rank)
    {
        SCM_MergeField mf = createMergeField('SubscriberIDSMN' + rank);

        if(null != getInsurance(selectedCase.Id, rank, '1'))
        {
            mf.FieldValue = getInsurance(selectedCase.Id, 'Primary', '1').Subscriber_Num_gne__c;
        }
        else
        {
            mf.FieldValue = '';
        }
        
        return mf;
    }
    
    public static SCM_MergeField GroupNumSMN(Case selectedCase, String rank)
    {
        SCM_MergeField mf = createMergeField('GroupNumSMN' + rank);

        if(null != getInsurance(selectedCase.Id, rank, '1'))
        {
            mf.FieldValue = getInsurance(selectedCase.Id, 'Primary', '1').Group_Num_gne__c;
        }
        else
        {
            mf.FieldValue = '';
        }
        
        return mf;
    }
    
    public static SCM_MergeField InsuranceEmployerSMN(Case selectedCase, String rank)
    {
        SCM_MergeField mf = createMergeField('InsuranceEmployerSMN' + rank);

        if(null != getInsurance(selectedCase.Id, rank, '1'))
        {
            mf.FieldValue = getInsurance(selectedCase.Id, 'Primary', '1').Employer_gne__c;
        }
        else
        {
            mf.FieldValue = '';
        }
        
        return mf;
    }
}