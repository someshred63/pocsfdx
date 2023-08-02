public class CFAR_EnrollmentWrapper extends CFAR_SObjectWrapper{
    
	public Boolean getIsFrozen(){
        String frozenYearsStr = (String)this.innerObject.get('Trials_Frozen_Accrual_Years_JSON_gne__c');
        if (String.isBlank(frozenYearsStr))
            return false; 
        set<Decimal> frozenYearsSet = (set<Decimal>)JSON.deserialize(frozenYearsStr, set<Decimal>.class);
        date enrollmentDate = (Date)this.innerObject.get('Date_gne__c'); 
        Integer year = enrollmentDate == null  ? null : enrollmentDate.year();
        if (frozenYearsSet.contains(Decimal.valueOf(year) ))
            return true; 
        return false; 
	}
    
    public CFAR_EnrollmentWrapper(SObject innerObject, Boolean selected)
    	{super(innerObject,selected);}  
    
}