global with sharing class CHV_TalkingPointWrapper extends CHV_TalkingPointBaseWrapper{
	
	public String name;
	public String content;
	public String lastModifiedDate;
	
	global CHV_TalkingPointWrapper(CHV_Talking_Point__c tp){
		super(tp);
		this.name = tp.Name;
		this.content = tp.Content__c;
		this.lastModifiedDate = String.valueOf(tp.LastModifiedDate.getTime()/1000);
	}
	
}