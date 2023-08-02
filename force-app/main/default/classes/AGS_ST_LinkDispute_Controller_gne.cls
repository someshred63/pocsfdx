public with sharing class AGS_ST_LinkDispute_Controller_gne {
	/* HD Decommissioning 
    // Search fields
    public String spendName { get; set; }
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String mdmId { get; set; }
    public Decimal amountFrom { get; set; }
    public Decimal amountTo { get; set; }
    public Boolean srchRes {get; set;}
    public List<AGS_ST_Held_Transaction_gne__c> heldTrans;
    public Id heldTransId {get; set;}

    //Instantiate the StandardSetController  
    public ApexPages.StandardSetController con{get; set;}  
    
    public AGS_ST_DMPagingAndSortingUtils linkDisputeUtil { get; set; }

	public AGS_ST_LinkDispute_Controller_gne() {
		srchRes = false;
		heldTrans = new List<AGS_ST_Held_Transaction_gne__c>();
		linkDisputeUtil = new AGS_ST_DMPagingAndSortingUtils(5);
	}

	public PageReference searchHelds() {
		if((spendName == null || spendName == '') && (firstName == null || firstName == '') && (lastName == '' || lastName == null) && (mdmId == null || mdmId == '') && (amountFrom == null || amountFrom == 0) && (amountTo == null || amountTo == 0)){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'There is no search criteria, You should enter at least one search criteria'));
			srchRes = false;
			amountFrom = null;
			amountTo = null;
		}else{
			srchRes = true;
			con = null;
			if(amountFrom == null || amountFrom == 0)
				amountFrom = null;
			if(amountTo == null || amountTo == 0)
				amountTo = null;
		}
		return null;
	}
	
	public PageReference clearVals(){
	    spendName = '';
	    firstName = '';
	    lastName = '';
	    mdmId = '';
	    amountFrom = null;
	    amountTo = null;
	    srchRes = false;
	    return null;
	}
	
	public List<AGS_ST_Held_Transaction_gne__c> getHeldTrans(){
		String QueryBegin = 'SELECT MDM_ID_GNE__c, Name, Id, RECEIPIENT_NAME_GNE__c, Source_Transaction_Amount_gne__c FROM AGS_ST_Held_Transaction_gne__c';
		String QueryEnd = '';
		String SortExpr = ' order by Name asc';
		heldTrans = new List<AGS_ST_Held_Transaction_gne__c>();
		
		if(spendName != '' && spendName != null){
			if(QueryEnd == ''){
				QueryEnd += ' WHERE Name = \''+spendName+'\'';
			}else{
				QueryEnd += ' AND Name = \''+spendName+'\'';
			}
		}
		if((firstName != null && firstName != '') && (lastName == '' || lastName == null)){
			if(QueryEnd == ''){
				QueryEnd += ' WHERE RECEIPIENT_NAME_GNE__c LIKE \''+firstName+'%\'';
			}else{
				QueryEnd += ' AND RECEIPIENT_NAME_GNE__c LIKE \''+firstName+'%\'';
			}
		}
		if((firstName == null || firstName == '') && ( lastName != '' && lastName != null)){
			if(QueryEnd == ''){
				QueryEnd += ' WHERE RECEIPIENT_NAME_GNE__c LIKE \'%'+lastName+'\'';
			}else{
				QueryEnd += ' AND RECEIPIENT_NAME_GNE__c LIKE \'%'+lastName+'\'';
			}
		}
		if((firstName != null && firstName != '') && ( lastName != '' && lastName != null)){
			if(QueryEnd == ''){
				QueryEnd += ' WHERE RECEIPIENT_NAME_GNE__c = \''+firstName+' '+lastName+'\'';
			}else{
				QueryEnd += ' AND RECEIPIENT_NAME_GNE__c = \''+firstName+' '+lastName+'\'';
			}
		}
		if(mdmId != null && mdmId != ''){
			if(QueryEnd == ''){
				QueryEnd += ' WHERE MDM_ID_GNE__c = \''+mdmId+'\'';
			}else{
				QueryEnd += ' AND MDM_ID_GNE__c = \''+mdmId+'\'';
			}
		}
		if(amountFrom != null && amountFrom != 0){
			Decimal amntFrom = amountFrom;
			if(amntFrom > 2147483647) amntFrom = 2147483647;
			if(QueryEnd == ''){
				QueryEnd += ' WHERE Source_Transaction_Amount_gne__c >= '+amntFrom;
			}else{
				QueryEnd += ' AND Source_Transaction_Amount_gne__c >= '+amntFrom;
			}
		}
		if(amountTo != null && amountTo != 0){
			Decimal amntTo = amountTo;
			if(amntTo > 2147483647) amntTo = 2147483647;
			if(QueryEnd == ''){
				QueryEnd += ' WHERE Source_Transaction_Amount_gne__c <= '+amntTo;
			}else{
				QueryEnd += ' AND Source_Transaction_Amount_gne__c <= '+amntTo;
			}
		}
		
		if(QueryEnd != ''){
			if(con == null){
				System.debug(QueryBegin);
				System.debug(QueryBegin + QueryEnd + SortExpr);
				System.debug(Database.query(QueryBegin));
				System.debug(Database.query(QueryBegin + QueryEnd + SortExpr));
				con = new ApexPages.StandardSetController(Database.getQueryLocator(QueryBegin + QueryEnd + SortExpr + ' LIMIT 10000'));
				if(con.getResultSize() > 10000){
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'There is more than 10000 search results for given criteria, You should specify more search criteria'));
				}
			}
			List<AGS_ST_Held_Transaction_gne__c> startResult = (List<AGS_ST_Held_Transaction_gne__c>)con.getRecords();
			linkDisputeUtil.setParameters(startResult.size());
	        // Set final List
	        Integer firstVal = (linkDisputeUtil.actualPage-1)*linkDisputeUtil.perPage;
	        Integer showRows = (startResult.size()<firstVal+linkDisputeUtil.perPage)?startResult.size():firstVal+linkDisputeUtil.perPage;
	        for(Integer i=firstVal; i<showRows; i++) {
	        	heldTrans.add(startResult.get(i));
	        }
		}
		return heldTrans;
	}
	
    public PageReference linkDispute(){
        AGS_ST_Held_Transaction_gne__c selectedHeld = new AGS_ST_Held_Transaction_gne__c();
        selectedHeld = [SELECT Id FROM AGS_ST_Held_Transaction_gne__c WHERE Id = :heldTransId limit 1];
        List<AGS_ST_Held_And_Dispute_Junction_gne__c> listHeldDispute = [SELECT AGS_ST_Dispute_Management_gne__c, AGS_ST_Held_Transaction_gne__c, Name FROM AGS_ST_Held_And_Dispute_Junction_gne__c WHERE AGS_ST_Dispute_Management_gne__c = :ApexPages.currentPage().getParameters().get('disputeId') AND AGS_ST_Held_Transaction_gne__c = :heldTransId];
        AGS_ST_DisputeManagement_gne__c selectedDispute = [Select Internal_Status_gne__c, Id From AGS_ST_DisputeManagement_gne__c WHERE Id = :ApexPages.currentPage().getParameters().get('disputeId')];
        String dispStatus = selectedDispute.Internal_Status_gne__c;
        if(dispStatus == 'Corrected Pending SSR' || dispStatus == 'Resolved With Correction' || dispStatus == 'Resolved No Correction'){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Dispute cannot be in status Corrected Pending SSR, Resolved With Correction or Resolved No Correction'));
            return null;
        }else{
            if(listHeldDispute.size() > 0){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'There is already connection between Held and selected Dispute'));
                return null;
            }else{
                AGS_ST_Held_And_Dispute_Junction_gne__c heldDispute = new AGS_ST_Held_And_Dispute_Junction_gne__c();
                heldDispute.AGS_ST_Dispute_Management_gne__c = ApexPages.currentPage().getParameters().get('disputeId');
                heldDispute.AGS_ST_Held_Transaction_gne__c = selectedHeld.Id;
                heldDispute.AGS_ST_ProcessedByEmailBatch_gne__c  = false;
                insert heldDispute;
            }
        }
        return null;
    }
    */
}