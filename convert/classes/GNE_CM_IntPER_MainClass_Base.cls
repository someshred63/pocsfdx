public with sharing virtual class GNE_CM_IntPER_MainClass_Base  extends GNE_CM_MPS_PlaceHolderBase {
	private GNE_CM_IntPer_MH_Base_Ctrllr baseComponentController;
	private Map<String, GNE_CM_IntPer_MH_Base_Ctrllr>componentControllerMap; //new
    public Patient_Enrollment_Request_gne__c patenrol { get; set; } 
    public Map<String,String> rxMap { get; set; }     

	public virtual GNE_CM_IntPer_MH_Base_Ctrllr getBaseComponentController() {
		return baseComponentController;
	}

	//new getter for the hashmap
	public virtual Map<String, GNE_CM_IntPer_MH_Base_Ctrllr> getComponentControllerMap(){
		return componentControllerMap;
	}
	
	//new method for putting value in the hashmap
	public virtual void setComponentControllerMap(String product, GNE_CM_IntPer_MH_Base_Ctrllr compController){
		if(componentControllerMap == null) {
			componentControllerMap = new Map<String, GNE_CM_IntPer_MH_Base_Ctrllr>();
		}
		componentControllerMap.put(product,compController); 
	}

	public virtual void setComponentController(GNE_CM_IntPer_MH_Base_Ctrllr compController) {
		baseComponentController = compController;
	}

	public GNE_CM_IntPER_MainClass_Base getThis() {
		return this;
	}
	
	public virtual void componentControllerSetupComplete(String product) {
	
	}
	
}