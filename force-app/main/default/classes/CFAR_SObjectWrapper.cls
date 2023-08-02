public virtual class CFAR_SObjectWrapper {
	
	public CFAR_SObjectWrapper(){
		
	}

	public CFAR_SObjectWrapper(sObject sobj){
		innerObject=sobj; 
	}
	
	
	public CFAR_SObjectWrapper(SObject innerObject, Boolean selected) {
			this.innerObject = innerObject;
			this.selected = selected;
	}
	
	public SObject innerObject {get; set;}
	public Boolean selected {get; set;}	
	public String tempValue {get;set;}

}