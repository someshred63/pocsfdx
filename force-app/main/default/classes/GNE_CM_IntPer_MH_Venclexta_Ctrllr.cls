public with sharing class GNE_CM_IntPer_MH_Venclexta_Ctrllr  extends GNE_CM_IntPer_MH_Base_Ctrllr{ 
	public GNE_CM_IntPer_MH_Venclexta_Ctrllr() {
		
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
        return new Set<String> { 'Venclexta' };
    }

	public override void initPERFields()
	{
		super.initPERFields();
		patenrol.Starter_Dosage_Venclexta_gne__c = medicalHistory.Starter_Dosage_gne__c;
	}

   public override Map<String, String> saveMH()
	{
		Map<String, String> mapRet=new Map<String, String>();

		medicalHistory.Drug_gne__c = product;
		medicalHistory.Rx_Serial_Number_gne__c = pageController.rxMap.get(product);
		medicalHistory.Starter_Dosage_gne__c = patenrol.Starter_Dosage_Venclexta_gne__c;


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