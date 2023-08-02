public without sharing class GNE_SFA_Influence_Metrics_Container 
{
	private final Account acct;
	public Boolean toRender {get; set;}
	public String div_height {get; set;}
	public GNE_SFA_Influence_Metrics_Container(ApexPages.StandardController stdCtrl)
	{
		this.acct = (Account)stdCtrl.getRecord();
		div_height = setHeight();	
		toRender = checkDisplay();
	}
	private String setHeight()
	{
		String height = '';
		Boolean adjHeight = checkDisplay();
		if(adjHeight == false)
		{
			height = '183px';
		}
		else
		{
			height = '320px';
		}
		return height;
	}
	private Boolean checkDisplay()
	{
		Boolean display = false;
		List<Influence_Metrics_gne__c> tmpMetrics = new List<Influence_Metrics_gne__c>();
		tmpMetrics = 
		[
			Select
			Id
			From 
			Influence_Metrics_gne__c
			Where
			Target_Physician_gne__c =: acct.Id
		];
		if(tmpMetrics.size() >0)
		{
			display = true;
		}
		else
		{
			display = false;
		}
		return display;
	}
	
	
}