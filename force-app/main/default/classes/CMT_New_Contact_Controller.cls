public with sharing class CMT_New_Contact_Controller {
    
    ApexPages.StandardController controller;
    //private List<CMT_Contact_Category_gne__c> categories;
    public CMT_Contact_gne__c currentContact { get; set; }
    //public String selectedCategory { get; set; }
    //public boolean isOtherRendered { get; set; }
    
    public CMT_New_Contact_Controller(ApexPages.StandardController controller) {
        this.controller = controller;
        //categories = [select Name from CMT_Contact_Category_gne__c];
        //isOtherRendered = false;
        currentContact = (CMT_Contact_gne__c) controller.getRecord();
        loadParameters();
    }
    
    public PageReference cancel()
    {
    	if (currentContact.Category_gne__c == null)
    	{
    		throw new CMT_Exception('Category ID not passed from page');
    	}
    	return CMT_MiscUtils.viewLinkPageRef(currentContact.Category_gne__c);
    }
    
    private void loadParameters() {
    	 currentContact.Meeting_gne__c =  System.currentPagereference().getParameters().get('mId');
    	 currentContact.Category_gne__c =  System.currentPagereference().getParameters().get('cId');
    }
    
    /*private List<SelectOption> contactCategories { get; set; }
    
    public List<SelectOption> getContactCategories() {
        contactCategories = new List<SelectOption>();
        
        for(CMT_Contact_Category_gne__c c : categories) {
            contactCategories.add(new SelectOption(c.Id, c.Name));
        }
        
        contactCategories.add(new SelectOption('Other','Other'));
        
        return contactCategories;
    } 
        
    public String newCategory { get; set; }
    
    public void checkIfOtherIsSelected() {
        if(selectedCategory == 'Other') {
            isOtherRendered = true;
        } else {
            isOtherRendered = false;
        }
    }
    
    public PageReference save() {
        
        // check if contact category group exists
        /*List<CMT_Contact_Category_Group_gne__c> categoryGroups = [ select Name from CMT_Contact_Category_Group_gne__c ];
        if((categoryGroups != null)&&(categoryGroups.isEmpty())) {
        	// no category groups exist - create one
        	CMT_Contact_Category_Group_gne__c groupToAdd = new CMT_Contact_Category_Group_gne__c();
        	insert groupToAdd;
        }
        
        // select group category
        List<CMT_Contact_Category_Group_gne__c> existingCategoryGroups = [ select Name from CMT_Contact_Category_Group_gne__c ];
        
        // insert new category
        if((isOtherRendered)&&(newCategory != '')) {
            CMT_Contact_Category_gne__c categoryToAdd = new CMT_Contact_Category_gne__c();
            categoryToAdd.Name = newCategory;
            categoryToAdd.Contact_Category_Group_gne__c = existingCategoryGroups[0].Id;
            categoryToAdd.Meeting_gne__c = currentContact.Meeting_gne__c;
            insert categoryToAdd; 
            currentContact.Category_gne__c = categoryToAdd.Id;
        } else {
        	currentContact.Category_gne__c = selectedCategory;	
        }
        
        return controller.save();
    }*/
    
}