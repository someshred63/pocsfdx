public with sharing abstract class GNE_Crud_Dao extends GNE_Base_Dao 
{  
	public String setupPagerQueryWhere( String objName, String fieldList, String sqlWhere, GNE_Base_Pager pager)
	{		
		String returnVal = '';  
		  
		if (HideDeleted != null && HideDeleted == true)
		{						
			if (!(sqlWhere == null || sqlWhere == '')) sqlWhere += ' AND ';		
			sqlWhere += ' is_deleted__c = false';
		}
		
        try
        {
        	String sortOrder = '';
        	
        	if (!(pager.CurrSort == null || pager.CurrSort == ''))        	 
        	{
        		sortOrder = pager.CurrSort + ' ' + pager.currSortOrder;
        	} else
        	{
        		sortOrder = 'Name '  + pager.currSortOrder;
        	}	
        	
        	String countQuery;
        	String query = getSql( fieldList, objName, sqlWhere, sortOrder);			
						
			if (!(sqlWhere == null || sqlWhere == ''))			
			{
				countQuery = 'select count() from ' + objName + ' where ' + sqlWhere;
			}
			else
			{
				countQuery = 'select count() from ' + objName;
			}      
			
			System.debug('SQL Count Query: ' + sqlWhere);
											
            Integer recCount;
			if (IsTestCase != null && IsTestCase == true)
			{
				recCount = Database.countQuery(countQuery + ' limit 2');
			}
			else
			{
				recCount = Database.countQuery(countQuery + ' limit 200');
			}
		
            pager.setRecordCount( recCount);                         
            query += ' limit ' + pager.getLimit();
        	
        	returnVal = query;
        }
        catch (Exception ex)
        {
            System.debug('Exception Caught in GNE_Crud_Dao. Message='+ex);
        }
		
        return returnVal;
    }
}