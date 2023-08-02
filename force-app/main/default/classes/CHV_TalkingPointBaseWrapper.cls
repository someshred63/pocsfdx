global virtual with sharing class CHV_TalkingPointBaseWrapper {
	public String id;
	
	global CHV_TalkingPointBaseWrapper(CHV_Talking_Point__c tp){
		this.id = tp.Id;	
	}
}