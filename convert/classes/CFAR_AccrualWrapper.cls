public class CFAR_AccrualWrapper extends CFAR_SObjectWrapper{
	
	public Boolean isFrozen {
		get{
			Decimal projected = (Decimal)this.innerObject.get('Projected_Accrual_gne__c');
			Decimal actual = (Decimal)this.innerObject.get('Actual_gne__c');
			if (projected == actual)
				return true; 
            return false;
			}
		private set;
	}
    
    public CFAR_AccrualWrapper(SObject innerObject, Boolean selected)
	{
		super(innerObject,selected);
	}
    	
    	
}