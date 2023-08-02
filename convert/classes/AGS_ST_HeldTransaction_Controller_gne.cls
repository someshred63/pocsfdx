/** @date 9/23/2012
* @Author Pawel Sprysak
* @description Controller for AGS_ST_HeldTransaction_gne page
*/
public without sharing class AGS_ST_HeldTransaction_Controller_gne {
	/* HD Decommissioning
	public String statusValue { get; set; }
	*/

	/** @date 9/23/2012
	* @Author Pawel Sprysak
	* @description Getter for Held Transaction statuses
	* @return List<SelectOption>
	*/
	/* HD Decommissioning
	public List<SelectOption> getHeldTransactionStatusList() {
		return AGS_ST_Utils.getPickListValuesWithExcept(
								AGS_ST_Held_Transaction_gne__c.Held_Transaction_Process_Status_Code_gne__c.getDescribe(), 
								new List<String>{'No Longer Valid'});
	}
	*/

	/** @date 9/23/2012
	* @Author Pawel Sprysak
	* @description Method for changing status of all selected (given in URL) Held Transactions
	* @return PageReference
	*/
	/* HD Decommissioning
	public PageReference changeStatus() {
		//Get record id's from _GET and put them into Id List
		String recordIds = ApexPages.currentPage().getParameters().get('recordIds');
		String[] stringIdList = recordIds.split(',', -2);
		Boolean isError = false;
		List<Id> idList = new List<Id>();
		for(String str : stringIdList) {
			idList.add((Id)str);
		}
		//Get all Held Transaction with getted id's and change their statuses
		List<AGS_ST_Held_Transaction_gne__c> heldTransactionList = AGS_ST_DbUtils.getHeldListByIdList(idList);
		for(AGS_ST_Held_Transaction_gne__c ht : heldTransactionList) {
			if(ht.Held_Transaction_Process_Status_Code_gne__c != null && ht.Held_Transaction_Process_Status_Code_gne__c.containsIgnoreCase('Ok to Process')){
				isError = true;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: You cannot change the status of already processed held transaction.'));
			}else if(ht.Held_Transaction_Process_Status_Code_gne__c != null && ht.Held_Transaction_Process_Status_Code_gne__c.containsIgnoreCase('No Longer Valid')){
				isError = true;
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: You cannot change the status of historical held transaction.'));
			//}else if(ht.Source_Transaction_Amount_gne__c != null && ht.Source_Transaction_Amount_gne__c < 0) {
			//  isError = true;
			//  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Error: You cannot change the status of held transaction with Source Amount less then 0.'));
			} else {
				ht.Held_Transaction_Process_Status_Code_gne__c = statusValue;
			}
		}
		if(!isError){
			update heldTransactionList;
			return redirect('&com=2');
		}else{
			return null;
		}
	}
	*/

	/** @date 9/23/2012
	* @Author Pawel Sprysak
	* @description Method for canceling action and backing to previous page
	* @return PageReference
	*/
	/* HD Decommissioning
	public PageReference cancelAction() {
		return redirect('');
	}
	*/

	/** @date 9/23/2012
	* @Author Pawel Sprysak
	* @description Redirecting method to Related List Page or Held Transaction List
	* @param String additional
	* @return PageReference
	*/
	/* HD Decommissioning
	public PageReference redirect(String additional) {
		String pr = ApexPages.currentPage().getParameters().get('pr');
		String event = ApexPages.currentPage().getParameters().get('event');
		String setId = ApexPages.currentPage().getParameters().get('set');
		String disputeId = ApexPages.currentPage().getParameters().get('dispute');
		PageReference pref = null;
		if(pr!=null && !pr.equals('') && event!=null && !event.equals('')) {
			pref = new PageReference('/apex/AGS_ST_DisputeRelatedLists_gne?pr='+pr+'&event='+event+'&set='+setId+'&dispute='+disputeId+additional);
		} else {
			Schema.DescribeSObjectResult sObjectDescription = AGS_ST_Held_Transaction_gne__c.sObjectType.getDescribe();  
			pref = new PageReference('/'+ sObjectDescription.keyPrefix);
		}
		pref.setRedirect(true);
		return pref;
	}
	*/
}