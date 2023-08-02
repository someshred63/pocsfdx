//--------------------------------------------------------------------------------
// COMPONENT: SFA Primary Care
//     CLASS: GNE_Alternate_Name_Dao
//   PURPOSE: Dao for Alternate_Name_gne__c, a related list on Account   
// 
//   CREATED: 05/2010  
//--------------------------------------------------------------------------------	
public with sharing class GNE_Alternate_Name_Dao extends GNE_Base_Dao {
   
	public static final String NAME = 'Alternate_Name_gne__c';
	public static final String FIELD_LIST = 'Id, Alternate_Name_gne__c, Account_Name_gne__c';

	public GNE_Alternate_Name_Dao(boolean testCase)	{
		IsTestCase = testCase;
	}
	
    public List<Alternate_Name_gne__c> getAccountsByAlternateName(String nm) {       
		String whereClause = getWhereClause(nm);
		return getAccountsByAlternateName(nm, whereClause);
	}
	
	public List<Alternate_Name_gne__c> getAccountsByAlternateName(String nm, String whereClause) {
		return String.isNotBlank(whereClause) ? getSObjectListByWhere(FIELD_LIST, NAME, whereClause, 'Name') : new List<Alternate_Name_gne__c>();
	}
	
	public String getWhereClause(String nm) {
		String whereClause = '';
		String[] splitFields;
		
		if (!isNullOrEmpty(nm)) splitFields = nm.split(' ');
    	if (splitFields != null && splitFields.size() > 0)
    	{
    			whereClause += addSqlWhereLikeInside(String.valueOf(Alternate_Name_gne__c.Alternate_Name_gne__c), splitFields);
    			whereClause = removeLeadingAnd(whereClause);
    	}
    	
    	return whereClause;
	} 
}