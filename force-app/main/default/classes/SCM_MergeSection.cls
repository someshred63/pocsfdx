public class SCM_MergeSection {
	public String key {get; set;}
//	public String value{get; set;}
	public Boolean visible{get; set;}
	
	public SCM_MergeSection()
	{
		key='';
		visible=false;
	}
	public SCM_MergeSection(String keyVal, Boolean visibilityVal)
	{
		key=keyVal;
		visible=visibilityVal;
	}
}