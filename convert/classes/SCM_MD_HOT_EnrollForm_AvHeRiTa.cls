public class SCM_MD_HOT_EnrollForm_AvHeRiTa extends SCM_MergeDocument_Hotline{
    public SCM_MD_HOT_EnrollForm_AvHeRiTa(String hotLineId,String docLookupId) { 
        super(hotLineId,docLookupId);
    }
    
    public override void createMergeFields() {
    	this.mergeRecipientInfo.add(new SCM_MF_HotlineID(selectedHotline));
    }
}