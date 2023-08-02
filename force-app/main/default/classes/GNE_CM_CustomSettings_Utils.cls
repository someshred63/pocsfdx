public with sharing class GNE_CM_CustomSettings_Utils 
{
	
	public static List<String> getValues(List<sObject> csValuesList, String environment)
	{		
		List<String> listValues = new List<String>();
		Set<String> customFieldsSet = new Set<String>();
		
		if(csValuesList != null && csValuesList.size() > 0)
		{ 
			String csName = csValuesList.getSObjectType().getDescribe().getName();	
			Schema.DescribeSObjectResult csDescription = csValuesList.getSObjectType().getDescribe();
			
			Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
	    	Map<String, Schema.SObjectField> fieldMap = schemaMap.get(csName).getDescribe().fields.getMap();
	    	
	    	for(Schema.SObjectField field : fieldMap.values())
	    	{
	    		if(field.getDescribe().isCustom())
	    		{
	    			customFieldsSet.add(field.getDescribe().getName());
	    		}
	    	}
	  
	    	if(customFieldsSet.contains('Value__c') && customFieldsSet.contains('Environment__c'))
	    	{ 
				for(Integer i=0, j=csValuesList.size(); i<j; i++)
				{
					String strObjectValue = String.valueOf(csValuesList.get(i).get('Value__c'));
					String strObjectEnv = String.valueOf(csValuesList.get(i).get('Environment__c'));
					
					if(String.valueOf(csValuesList.get(i).get('Environment__c')) == environment || String.valueOf(csValuesList.get(i).get('Environment__c')).toLowerCase() == 'all')
					{
						listValues.add(String.valueOf(csValuesList.get(i).get('Value__c')));
					}	
				}
			}
		}
		System.debug('[DZ] listValues: ' + listValues);	
		return listValues;
	}

}