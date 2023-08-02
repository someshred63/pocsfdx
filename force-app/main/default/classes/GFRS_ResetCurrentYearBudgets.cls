/**
 *  Batchable that determines the current year's budgets.
 *
 *  <p>To bypass an issue where salesforce is unable to perform a roll-up summary
 *  based on 'smartDates' (such as the current year), this batch is responsible
 *  for evaluating budgets on the turn of the year</p>
 *  
 *  <code>
 *  GFRS_ResetCurrentYearBudgets clear = new GFRS_ResetCurrentYearBudgets();
 *  Database.executeBatch( clear );
 *  </code>
 **/
global class GFRS_ResetCurrentYearBudgets implements Database.Batchable<SObject> {
	
	global final String query;
	
	/**
	 *  Constructor
	 *  <p>orgFilter is mainly used to tests to avoid the 'no more than one executeBatch' error.</p>
	 *  
	 *  @param orgFilter (id) the organization to update.
	 **/
	global GFRS_ResetCurrentYearBudgets( id orgFilter ){
		String whereClause = (orgFilter != null)?' where id =\'' + orgFilter + '\'' : '';
		this.query = 'select id, Name from gFRS_Organization__c' + whereClause;
	}
	
	global Database.QueryLocator start( Database.BatchableContext bc ){
		return( Database.getQueryLocator( query ));
	}
	
	global void execute( Database.BatchableContext bc, gFRS_Organization__c[] scope ){
		gFRS_Util_NoShare.calculateOrganizationTotalApprovedCurrentYear(new Map<id,gFRS_Organization__c>( scope ));
	}
	
	global void finish( Database.BatchableContext bc ){}
}