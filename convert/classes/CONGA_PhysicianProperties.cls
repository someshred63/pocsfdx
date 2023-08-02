public with sharing class CONGA_PhysicianProperties extends CONGA_Iproperties{
	
    public String name { get; set; }
    public ID locationId { get; set; }
    public Boolean isTargeted{ get; set; }
	public List<String> territoryNameList {get;set;}

	public CONGA_PhysicianProperties(Account physician, Boolean isTargeted)
	{
		this.id = physician.id; 
		this.Name = physician.name; 
		this.locationId = physician.Address_vod__r.size()>0 ? physician.Address_vod__r[0].id : null; 
		this.isTargeted = isTargeted; 
	}

	public CONGA_PhysicianProperties(Account physician, Boolean isTargeted, Id addressId )
	{
		this.id = physician.id; 
		this.Name = physician.name; 
		this.locationId = addressId;  
		this.isTargeted = isTargeted; 
	}

	public CONGA_PhysicianProperties(Account physician, Boolean isTargeted, List<TSF_vod__c> tsfList, List<TSF_vod__c> targetedTSFList)
	{
		this.id = physician.id; 
		this.Name = physician.name; 
		this.isTargeted = isTargeted; 

		if(tsfList != null && targetedTSFList != null){
			this.territoryNameList = new List<String>();
			for(TSF_vod__c tsf : targetedTSFList){
				territoryNameList.add(tsf.Territory_vod__c);
			}
		} else {
			this.territoryNameList = null;
		}
		if(tsfList != null){
			Boolean primaryAddressFound = false;		
			for(TSF_vod__c tsf : tsfList){
				if(!primaryAddressFound && tsf.Address_vod__r.Primary_vod__c){
					this.locationId = tsf.Address_vod__c;  
					primaryAddressFound = true;
				}			
			}
		}
	}

	public CONGA_PhysicianProperties(TSF_vod__c tsf)
	{
		this.id = tsf.Account_vod__c; 
		this.Name = tsf.Account_vod__r.name; 
		this.locationId = tsf.Address_vod__c;  
		this.isTargeted = tsf.My_Target_vod__c; 
	}



}