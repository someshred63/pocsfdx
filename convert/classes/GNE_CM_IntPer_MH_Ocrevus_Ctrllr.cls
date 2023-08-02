public with sharing class GNE_CM_IntPer_MH_Ocrevus_Ctrllr  extends GNE_CM_IntPer_MH_Base_Ctrllr { 
	public GNE_CM_IntPer_MH_Ocrevus_Ctrllr() {
		
	}

	@RemoteAction
	public static Boolean isComplete(String JSONMedicalHistory, String JSONPER)
	{
		Medical_History_gne__c mh = 
			(Medical_History_gne__c)JSON.deserialize(JSONMedicalHistory, Medical_History_gne__c.class);
		Patient_Enrollment_Request_gne__c per = 
			(Patient_Enrollment_Request_gne__c)JSON.deserialize(JSONPER, Patient_Enrollment_Request_gne__c.class);

		return (testComplete(mh, per).size()==0);
	}

	public static Map<String,String> testComplete(Medical_History_gne__c mh, Patient_Enrollment_Request_gne__c per)
	{
		Map<String,String> mapErrs=new  Map<String,String>();

		return mapErrs;
	}

	@RemoteAction
	public static String getDiseaseState(String IDC9Id)
	{
		return GNE_CM_IntPer_MH_Base_Ctrllr.lookupDiseaseState(IDC9Id);
	}
		
	
	public override Boolean validateInput()
	{
		errors=testComplete(medicalHistory, patenrol);

		return (errors.size()==0);
	}
	  
    public override Set<String> getProducts()
    {
        return new Set<String> { 'Ocrevus' };
    }

	public override void initPERFields()
	{
		super.initPERFields();
	}

   public override Map<String, String> saveMH()
	{
		Map<String, String> mapRet=new Map<String, String>();

		medicalHistory.Drug_gne__c = product;
		medicalHistory.Rx_Serial_Number_gne__c = pageController.rxMap.get(product);

		medicalHistory.Clinical_Impressions_gne__c =  (medicalHistory.Clinical_Impressions_gne__c==null ? '' : (medicalHistory.Clinical_Impressions_gne__c + '\n')) +
		    (patenrol.Specialty_Pharmacy_Needed_gne__c!=null ? ('Specialty Pharmacy Needed ?' + patenrol.Specialty_Pharmacy_Needed_gne__c + '\n') : '') +
		    (patenrol.Specialty_Pharmacy_Note_gne__c!=null  && patenrol.Specialty_Pharmacy_Note_gne__c!='' ? ('Specialty Pharmacy Note: ' + patenrol.Specialty_Pharmacy_Note_gne__c + '\n') : '');

        if(medicalHistory.SMN_Effective_Date_gne__c != null)
        {
            medicalHistory.SMN_Expiration_Date_gne__c = medicalHistory.SMN_Effective_Date_gne__c.addYears(1);
        }                            

        // ensure that expiration dates are updated by the trigger
        if (medicalHistory.Rx_Date_gne__c!=null)
        {
        	medicalHistory.GATCF_SMN_Expiration_Date_gne__c = null;
        }

        if (medicalHistory.Starter_Rx_Date_gne__c!=null)
        {
        	medicalHistory.Starter_Rx_Expiration_Date_gne__c = null;
        }

        // write to db 
        if (medicalHistory.Id!=null)
        {
            update medicalHistory;
        }
        else
        {
            insert medicalHistory;  
        }
        
        mapRet.put(product, medicalHistory.Id);

		return mapRet;	
	}	
}