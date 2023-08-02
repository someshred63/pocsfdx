/** 
    * @Author ADMD Team
    * @date 24/01/2014
    * @description  gFRS_MultiselectPickListController class is used in gFRS_MultiselectPickList component
    */
    
public with sharing class gFRS_MultiselectPickListController {
	
	public List<String> leftSelectedCont   { get; set; }
	public List<String> rightSelectedCont  { get; set; }
	public List<Selectoption> leftOptions  { get; set; }
	public List<Selectoption> rightOptions { get; set; }
	public List<String>finalSelectedItems  { get; set; }
    
    /** 
    * @Author ADMD Team
    * @date 24/01/2014
    * @description  gFRS_MultiselectPickListController class constructor
    */
	public gFRS_MultiselectPickListController(){
		leftSelectedCont  =new List<String>();
		rightSelectedCont =new List<String>();
	}
	
	/** 
    * @Author ADMD Team
    * @date 24/01/2014
    * @description  selectclick - method responsible for moving selected options
    	from left selectlist in right
    */
	public PageReference selectclick(){
		if(leftSelectedCont != null && leftSelectedCont.size()>0 &&  leftOptions!= null && leftOptions.size()>0){

			List<Selectoption> optionsToMoveOnRight   = new List<Selectoption>();
			List<Selectoption> leftSelectListSnapshot = leftOptions;

			for(String item:leftSelectedCont){
				for(integer i=0;i<leftOptions.size();i++){
					if(leftOptions[i].getValue()==item){
						optionsToMoveOnRight.add(leftOptions[i]);
						leftSelectListSnapshot.remove(i);
					}
				}
			}
			leftOptions=leftSelectListSnapshot;
			if(rightOptions != null ){
				rightOptions.addAll(optionsToMoveOnRight);
			}else{
				rightOptions=optionsToMoveOnRight;
			}
			rightOptions.sort();
			leftSelectedCont.clear();
			setFinalSelectedItems();
		}
		return null;
	}
	
	/** 
    * @Author ADMD Team
    * @date 24/01/2014
    * @description  unselectclick - method responsible for moving selected options
    	from right selectlist in left
    */
	public PageReference unselectclick(){
		if(rightSelectedCont != null && rightSelectedCont.size()>0 &&  rightOptions!= null && rightOptions.size()>0){
			List<Selectoption> optionsToMoveOnLeft     = new List<Selectoption>();
			List<Selectoption> rightSelectListSnapshot = rightOptions;
			
			for(String item:rightSelectedCont){
				for(integer i=0;i<rightOptions.size();i++){
					if(rightOptions[i].getValue()==item){
						optionsToMoveOnLeft.add(rightOptions[i]);
						rightSelectListSnapshot.remove(i);
					}
				}
			}
			rightOptions=rightSelectListSnapshot;
			if(leftOptions != null ){
				leftOptions.addAll(optionsToMoveOnLeft);
			}else{
				leftOptions=optionsToMoveOnLeft;
			}
			leftOptions.sort();
			rightSelectedCont.clear();
			setFinalSelectedItems();
			
		}
		
		return null;

    }
    
    /** 
    * @Author ADMD Team
    * @date 24/01/2014
    * @description  setFinalSelectedItems - method responsible for setting selected field
    */
    public void setFinalSelectedItems(){
    	if(finalSelectedItems != null){
    		finalSelectedItems.clear();
    	}else{
    		finalSelectedItems=new List<String>();
    	}
    		
    	for(Selectoption optionItem:rightOptions){
    		finalSelectedItems.add(optionItem.getValue());
    	}
    }
}