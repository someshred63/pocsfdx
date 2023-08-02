public with sharing class GNE_CM_BRC_Actemra_Batch extends GNE_CM_BRC_Base_Batch implements Database.Batchable<sObject>, Database.Stateful
{
	public GNE_CM_BRC_Actemra_Batch(Boolean runInDebugMode, String addressFilterConditions, String patientFilterConditions, String caseFilterConditions)
	{
		this.productName = 'Actemra';
        this.debugMode = runInDebugMode;
		this.addressFilterConditions = addressFilterConditions;
		this.patientFilterConditions = patientFilterConditions;
		this.caseFilterConditions = caseFilterConditions;
	}

	public GNE_CM_BRC_Actemra_Batch()
	{
		this(false,null,null,null);
	}
}