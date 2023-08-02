public class SCM_MF_HotlineID extends SCM_MergeField {

	public SCM_MF_HotlineID(Hotline_gne__c hotline)
	{
		//SCM_MergeField mf = new SCM_MergeField();
        key = 'HotlineID';
        displayTextbox =false;
        displayLabel = false;
        fieldValue = hotline.Name;
        displayCheck=false;
	}
}