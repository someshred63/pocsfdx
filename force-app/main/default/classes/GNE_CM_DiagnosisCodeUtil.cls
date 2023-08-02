public without sharing class GNE_CM_DiagnosisCodeUtil 
{
	public static final String ICD9_REGEX = '(^|\\s|\\()[V]\\d\\d((\\.\\d)|(\\.\\d\\d))?($|\\s|\\))|(^|\\s|\\()\\d\\d\\d((\\.\\d)|(\\.\\d\\d))?($|\\s|\\))';
	public static final String ICD10_REGEX = '(^|\\s|\\()[a-tv-zA-TV-Z][0-9][a-zA-Z0-9]((\\.[a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9])|(\\.[a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9])|(\\.[a-zA-Z0-9][a-zA-Z0-9])|(\\.[a-zA-Z0-9]))?($|\\s|\\))';
	private static final Pattern ICD9_PATTERN = Pattern.compile(ICD9_REGEX);
	private static final Pattern ICD10_PATTERN = Pattern.compile(ICD10_REGEX);
	
	public static Integer getVersion(String diagnosisCode) 
	{
		if (String.isBlank(diagnosisCode)) 
		{
			return null;
		}
		
		Matcher m = GNE_CM_DiagnosisCodeUtil.ICD9_PATTERN.matcher(diagnosisCode);
        if (m.matches()) 
        {
        	return 9;
        }
        
        if (m.find()) 
        { 
        	return 9;
        }
        
		m = GNE_CM_DiagnosisCodeUtil.ICD10_PATTERN.matcher(diagnosisCode);	
    	if (m.matches()) 
    	{
    		return 10;
    	}
    	
    	if (m.find()) 
        { 
        	return 10;
        }
		return null;		
	}
	
	public Map<String, Integer> extractVersion(Set<String> diagnosisCodes) 
	{
		Map<String, Integer> result = new Map<String, Integer>();
		if (diagnosisCodes != null)
		{
			for(String diagnosisCode : diagnosisCodes)
			{
				Integer version = GNE_CM_DiagnosisCodeUtil.getVersion(diagnosisCode);
				if (version != null) 
				{
					result.put(diagnosisCode, version);
				}
			}
		}
		return result;
	}
	
	private static String trimSpecialCharacters(String diagnosisCode) 
	{
		diagnosisCode = diagnosisCode.trim();
		if (diagnosisCode.startsWith('(')) 
		{
			diagnosisCode = diagnosisCode.substring(1);
		}
		if (diagnosisCode.endsWith(')')) 
		{
			diagnosisCode = diagnosisCode.substring(0, diagnosisCode.length() - 1);
		}
		return diagnosisCode;	
	}
		
	public static String extract(String diagnosisCode, Boolean fallbackToSelf) 
	{
		if (String.isBlank(diagnosisCode)) 
		{
			return fallbackToSelf ? diagnosisCode : null;
		}

	    Matcher m = GNE_CM_DiagnosisCodeUtil.ICD9_PATTERN.matcher(diagnosisCode);
        if (m.find()) 
        {
        	return trimSpecialCharacters(m.group(0));
        }
        
        if (m.matches()) 
        {
        	return diagnosisCode.trim();	
        }
        
    	m = GNE_CM_DiagnosisCodeUtil.ICD10_PATTERN.matcher(diagnosisCode);	
    	if (m.find()) 
    	{
    		return trimSpecialCharacters(m.group(0));
    	}
    	
    	if (m.matches()) 
        {
        	return diagnosisCode.trim();	
        }
    	
		return fallbackToSelf ? diagnosisCode : null;
	}
	
	public static String extract(String diagnosisCode)
	{
		return GNE_CM_DiagnosisCodeUtil.extract(diagnosisCode, false);
	}
	
	public static Set<String> extract(Set<String> diagnosisCodes) 
	{
		Set<String> result = new Set<String>();
		if (diagnosisCodes != null)
		{
			for(String diagnosisCode : diagnosisCodes)
			{
				String extractedDiagnosisCode = GNE_CM_DiagnosisCodeUtil.extract(diagnosisCode, false);
				if (extractedDiagnosisCode != null)			
				{
					result.add(extractedDiagnosisCode);
				}
			}
		}
		return result;
	}
	
	public static Boolean isProductOnLabel(String product, String diagnosisCode)
    {
        if (String.isBlank(product) || String.isBlank(diagnosisCode)) 
        {
            return false;
        }
        
        try 
        {
            return (new Set<String>(GNE_CM_Product_ICD9_Labels__c.getInstance(product).Label__c.split(';'))).contains(GNE_CM_DiagnosisCodeUtil.extract(diagnosisCode, false));
        }
        catch (Exception ex) 
        {
            return false;
        }
    }
    
    public static Set<String> getOnLabel(String product)
    {
        try 
        {
            return new Set<String>(GNE_CM_Product_ICD9_Labels__c.getInstance(product).Label__c.split(';'));
        }
        catch (Exception ex) 
        {
            return new Set<String>();
        }
    }
	
}