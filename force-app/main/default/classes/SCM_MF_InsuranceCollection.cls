// Added By: Paras Sharma
// Collection Class for Insurance
/**Regarding the [b.BI_BI_Status_gne__c = 'Complete Pending PA'] portion of the query, there is currently
no such option in the DB but has been implemented as per spec docs */

public virtual class SCM_MF_InsuranceCollection extends SCM_MergeField{

	private static List<Insurance_gne__c> InsuranceList;
	private List<Benefit_Investigation_gne__c> BIList;
	public static List<Benefit_Investigation_gne__c> BIListFil = new List<Benefit_Investigation_gne__c>();
	private List<Prior_Authorization_gne__c> PAList;
	private List<Prior_Authorization_gne__c> PAListFil = new List<Prior_Authorization_gne__c>();
	public Prior_Authorization_gne__c PA;
	
	public SCM_MF_InsuranceCollection(String caseId) {
        this.checked = false;
        this.displayCheck = false;
        this.displayTextBox = false;
        this.displayLabel = false;
        if(InsuranceList == null)
        {
         	InsuranceList = [Select i.Id From Insurance_gne__c i 
							where i.case_Insurance_gne__c = :caseId LIMIT 100];
        }
        if(InsuranceList.size()>=1){
            for(Insurance_gne__c i : InsuranceList){
		   		BIList = [Select b.Id, b.BI_Insurance_gne__r.Payer_gne__r.Name,
		   				b.BI_Insurance_gne__r.Subscriber_Num_gne__c, 
		   				b.BI_Insurance_gne__r.Group_Num_gne__c,
		   				b.Drug_Billing_Code_gne__c
		   				From Benefit_Investigation_gne__c b
						where b.BI_BI_Status_gne__c = 'Complete - Pending PA' 
						and BI_Insurance_gne__c = :i.Id order by b.LastModifiedDate desc LIMIT 100];
				//System.Debug('After 1st For Loop.............' + BIList);		
				for(Benefit_Investigation_gne__c bi : BIList){
					PAList = [Select p.Id From Prior_Authorization_gne__c p
							 where p.Benefit_Investigation_gne__c = :bi.Id order by p.LastModifiedDate desc];
					if(PAList.size()>=1){
						BIListFil.add(bi);
						PAListFil.add(PAList[0]);
					}
				}
				//System.Debug('After 2nd For Loop.............' + BIListFil +' PAListFil-->>'+ + PAListFil);
			}
			string paIds = '';
			for(Prior_Authorization_gne__c pa : PAListFil){
				if(paIds != ''){
					paIds += ',';
				}
				paIds += pa.Id;
			}
			//System.Debug('After 3rd For Loop.............' + paIds);
			try
			{
			PAListFil = [Select p.Id, p.PA_Contact_Name_gne__c, p.Fax_gne__c, p.Address_Line_1_gne__c, p.Address_Line_2_gne__c,  
						 p.City_gne__c, p.State_gne__c, p.Zip_gne__c From Prior_Authorization_gne__c p
						where p.Id in (:paIds ) order by p.LastModifiedDate desc];
			}
			catch(Exception ex)
			{
				PAListFil = null;
			}
			if(PAListFil.size() >= 1){
				PA = PAListFil[0]; //Selecting the last modified PA 
			}
			else
			{
				PA = null;
			}
			//System.Debug('End Step[LAST MODIFIED PA].............' + PA);
        }
        else{
            InsuranceList = null;
        }
    }
}