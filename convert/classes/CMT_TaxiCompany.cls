global class CMT_TaxiCompany extends CMT_JSONWrapper
{
    public String Name { get; set; }
    public String Phone { get; set; }

    public CMT_TaxiCompany()
    {
    }
    
    private void init (CMT_Taxi_Company_gne__c tc, List<CMT_Attachment> attachments)
    {
        if (tc != null)
        {
            Id = tc.Id;
            Name =  tc.Company_Name_gne__c;
            Phone = tc.Phone_gne__c;
            this.Attachments = attachments != null ? attachments : new List<CMT_Attachment>();
        }
    }
    
    public CMT_TaxiCompany (CMT_Taxi_Company_gne__c tc)
    {
        init (tc, null);
    }
    
    public CMT_TaxiCompany (CMT_Taxi_Company_gne__c tc, List<CMT_Attachment> attachments)
    {
        init (tc, attachments);
    }
}