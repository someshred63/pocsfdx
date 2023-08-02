public class GNE_SFA2_PREP_Testing_Information_Ctrl extends GNE_SFA2_PREP_Base_Ctrl {
	public Id accId {get; private set;}
	public List<Object> tInfosList {get;}
	public String[] columnHeaders { get { return new String[]{
		'Test Type', 'Test Method', 'Test Component', 'Test Hierarchy', 'Stage Tested', 'Refers To',
		'% TC', '% Global', 'Test Volume/Year'};
	}}
	
	public String urlForNewRecord { get { return SFA2_PREP_Account_Testing_Info_gne__c.sObjectType.getDescribe().getKeyPrefix() + '/e'; }}
	public Boolean newButtonEnabled { get { return true; }}
	
	private transient String[] columnApiNames = new String[]{
		String.valueOf(SFA2_PREP_Account_Testing_Info_gne__c.Test_Type_gne__c),
		String.valueOf(SFA2_PREP_Account_Testing_Info_gne__c.Test_Method_gne__c),
		String.valueOf(SFA2_PREP_Account_Testing_Info_gne__c.Test_Component_gne__c),
		String.valueOf(SFA2_PREP_Account_Testing_Info_gne__c.Test_Hierarchy_gne__c),
		String.valueOf(SFA2_PREP_Account_Testing_Info_gne__c.Stage_Tested_gne__c),
		String.valueOf(SFA2_PREP_Account_Testing_Info_gne__c.Referred_Account_gne__c),
		String.valueOf(SFA2_PREP_Account_Testing_Info_gne__c.Percent_of_TC_gne__c),
		String.valueOf(SFA2_PREP_Account_Testing_Info_gne__c.Percent_of_Global_gne__c),
		String.valueOf(SFA2_PREP_Account_Testing_Info_gne__c.Testing_Volume_Month_gne__c)
	};
	
	private transient List<TestingInfoWrapper> tInfos;
	
	
	public GNE_SFA2_PREP_Testing_Information_Ctrl() {
		this(ApexPages.currentPage().getParameters().get('id'));
	}
	
	public GNE_SFA2_PREP_Testing_Information_Ctrl(Id a_accId) {
		super();
		accId = a_accId;
		buildTestingInfoList();
	}
	
	private void buildTestingInfoList() {
		tInfos = new List<TestingInfoWrapper>();
		
		for(SFA2_PREP_Account_Testing_Info_gne__c tInfo : GNE_SFA2_PREP_Util.getTestingInfos(new Set<Id>{accId})) {
			tInfos.add(new TestingInfoWrapper(tInfo));
		}
	}
	
	@RemoteAction @ReadOnly
	public static ControllerData getInitData(String accId) {
  		ControllerData result = new ControllerData(accId);
	
	  	try {
	  		result.copyFrom(result.ctrl);
	  	} catch(Exception ex) {
	  		result.retURL = getErrorPageUrl('getInitData', ex);
	  	}
	  	
	  	result.onActionFinish('getInitData');
	  	return result;
	}
	
	private static String getErrorPageUrl(String actionName, Exception ex) {
  		return GNE_SFA2_PREP_Base_Ctrl.setErrorPageReference(
  				actionName, ex, Page.GNE_SFA2_PREP_Testing_Information).getUrl();
  	}
	
	public class ControllerData extends GNE_SFA2_PREP_Base_Ctrl.ControllerData {
		@TestVisible private String accId;
		@TestVisible private List<String> columnHeaders;
		@TestVisible private String[] columnApiNames;
		@TestVisible private List<TestingInfoWrapper> tInfos;
		
		public ControllerData(String a_accId) {
			super();
			ctrl = new GNE_SFA2_PREP_Testing_Information_Ctrl(a_accId);
		}
		
		protected override void copyFrom(GNE_SFA2_PREP_Base_Ctrl a_ctrl) {
			super.copyFrom(a_ctrl);
			accId = ((GNE_SFA2_PREP_Testing_Information_Ctrl)a_ctrl).accId;
			columnHeaders = ((GNE_SFA2_PREP_Testing_Information_Ctrl)a_ctrl).columnHeaders;
			columnApiNames = ((GNE_SFA2_PREP_Testing_Information_Ctrl)a_ctrl).columnApiNames;
			tInfos = ((GNE_SFA2_PREP_Testing_Information_Ctrl)a_ctrl).tInfos;
		}
		
		protected override void copyTo(GNE_SFA2_PREP_Base_Ctrl a_ctrl) {
			super.copyTo(a_ctrl);
		}
	}
	
	public class TestingInfoWrapper {
		@TestVisible private SFA2_PREP_Account_Testing_Info_gne__c record;
		
		public TestingInfoWrapper(SFA2_PREP_Account_Testing_Info_gne__c a_record) {
			record = a_record;
		}
	}
}