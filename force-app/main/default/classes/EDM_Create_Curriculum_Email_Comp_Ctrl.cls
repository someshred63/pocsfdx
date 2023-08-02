global class EDM_Create_Curriculum_Email_Comp_Ctrl{

	public String bureau {get;set;}
	public String bureauName {get;set;}

    public EDM_Create_Curriculum_Email_Comp_Ctrl(){
    	try{
    		bureauName = [Select name from Speaker_Bureau_gne__c where id=:bureau].Name;
    	} catch(Exception e){
    		System.debug(e);
    	}
    }
}