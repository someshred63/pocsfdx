public class SCM_MD_Hotline_SMN extends SCM_MergeDocument_Hotline{
	
	public SCM_MD_Hotline_SMN(String hotlineId,String docLookupId)
	{
		super(hotlineId,doclookupId);
	}
    public virtual override void createMergeFields() 
    {
        this.mergeRecipientInfo.add( new SCM_MF_HotlineID(selectedHotline));
    } 
}