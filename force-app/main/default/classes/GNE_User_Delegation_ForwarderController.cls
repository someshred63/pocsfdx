public without sharing class GNE_User_Delegation_ForwarderController {

	public GNE_User_Delegation_ForwarderController( ApexPages.StandardController std )
    {
    	
    }
    	
	public ApexPages.PageReference redirectToProperDelegation(){
		Map<String, String> params=ApexPages.currentPage().getParameters();
		if(params.containsKey('rt')){
			List<GNE_User_Delegation__c> userDelegations= [select id from GNE_User_Delegation__c where Username__c =: Userinfo.getUserId() and RecordType.Name =:params.get('rt')];
			if(userDelegations.size()>0){
				return( new ApexPages.PageReference('/'+userDelegations[0].id));
			}
	   }
	   return ( new ApexPages.PageReference('/a8x/o'));
	}
}