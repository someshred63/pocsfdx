//Added: Paras Sharma
//Document: CMGT-FAX-44 - PAN - Spanish Form Analysis v2.0 - FINAL
//ACTIVASE, LUCENTIS, RAPTIVA, RITUXAN RA, NUTROPIN, XOLAIR
public class SCM_MD_PANSpanishForm_AcLuRaRiNuXo extends SCM_MergeDocument{

	protected String caseId;
	
	public SCM_MD_PANSpanishForm_AcLuRaRiNuXo(String caseID, String argLookupId) {
	        super(caseID, argLookupId);
	        caseId = caseID;
	    }
	    
	public override void createMergeFields() {
		//0. Address
		SCM_MergeField add = new SCM_MergeField();
		if(selectedCase.Product_gne__c == null){
			add.fieldValue = '';
		}
		else if(selectedCase.Product_gne__c == 'Respiratory'){
			add.fieldValue = '3060 Ogden Avenue, Suite 101, Lisle, IL 60532';
		}
		else{
			add.fieldValue = '1 DNA Way, Mail Stop #210, South San Francisco, CA 94080';
		}
		
	    add.key = 'Address';
	    add.label = 'Address';
	    add.className = 'SCM_MD_PANSpanishForm_AcLuRaRiNuXo';
		add.checked = false;
        add.displayCheck = false;
        add.displayTextBox = false;
        add.displayLabel = false;
	    this.mergeRecipientInfo.add(add);
		
		//1. Fax
		SCM_MergeField fax = new SCM_MergeField();
		if(selectedCase.Product_gne__c == null){
			fax.fieldValue = '';
		}
		else if(selectedCase.Product_gne__c == 'Endocrinology'){
			fax.fieldValue = 'Fax 1-800-545-0612';
		}
		else if(selectedCase.Product_gne__c == 'Avastin' || selectedCase.Product_gne__c == 'Rituxan' || selectedCase.Product_gne__c == 'Herceptin' || selectedCase.Product_gne__c == 'Cardiology'){
			fax.fieldValue = 'Fax 1-888-249-4919';
		}
		else if(selectedCase.Product_gne__c == 'Tarceva'){
			fax.fieldValue = 'Fax 1-888-249-4970';
		}
		else if(selectedCase.Product_gne__c == 'Dermatology'){
			fax.fieldValue = 'Fax 1-866-481-7762';
		}
		else if(selectedCase.Product_gne__c == 'Respiratory'){
			fax.fieldValue = 'Fax 1-800-704-6612';
		}
		fax.key = 'Fax';
	    fax.label = 'Fax';
	    fax.className = 'SCM_MD_PANSpanishForm_AcLuRaRiNuXo';
		fax.checked = false;
        fax.displayCheck = false;
        fax.displayTextBox = false;
        fax.displayLabel = false;
	    this.mergeRecipientInfo.add(fax);
		
		//2. Partners
		SCM_MergeField part = new SCM_MergeField();
		if(selectedCase.Product_gne__c == null){
			part.fieldValue = '';
		}
		else if(selectedCase.Product_gne__c == 'Avastin' || selectedCase.Product_gne__c == 'Rituxan' || selectedCase.Product_gne__c == 'Herceptin' || selectedCase.Product_gne__c == 'Cardiology'){
			part.fieldValue = 'such as Biogen/IDEC Pharmaceutical, Inc., ';
		}
		else if(selectedCase.Product_gne__c == 'Tarceva'){
			part.fieldValue = 'como OSI Pharmaceuticals, ';
		}
		else if(selectedCase.Product_gne__c == 'Respiratory'){
			part.fieldValue = 'como Novartis Pharmaceuticals Corporation, ';
		}
		
	    part.key = 'Partners';
	    part.label = 'Partners';
	    part.className = 'SCM_MD_PANSpanishForm_AcLuRaRiNuXo';
		part.checked = false;
        part.displayCheck = false;
        part.displayTextBox = false;
        part.displayLabel = false;
	    this.mergeRecipientInfo.add(part);
		
		//3. Track Number
		SCM_MergeField track = new SCM_MergeField();
		if(selectedCase.Product_gne__c == null){
			track.fieldValue = '';
		}
		else if(selectedCase.Product_gne__c == 'Endocrinology'){
			track.fieldValue = 'LF0515 7362303';
		}
		else if(selectedCase.Product_gne__c == 'Avastin' || selectedCase.Product_gne__c == 'Rituxan' || selectedCase.Product_gne__c == 'Herceptin' || selectedCase.Product_gne__c == 'Cardiology'){
			track.fieldValue = 'LA0306 7201504';
		}
		else if(selectedCase.Product_gne__c == 'Tarceva'){
			track.fieldValue = '7572201-TAR090705';
		}
		else if(selectedCase.Product_gne__c == 'Dermatology'){
			track.fieldValue = 'LQ0028 - 7405702';
		}
		else if(selectedCase.Product_gne__c == 'Respiratory'){
			track.fieldValue = 'LX00017380502/XOL9293';
		}
		else if(selectedCase.Product_gne__c == 'Rheumatology'){
			track.fieldValue = 'LR1125 8092800';
		}
		track.key = 'Track Number';
	    track.label = 'Track Number';
	    track.className = 'SCM_MD_PANSpanishForm_AcLuRaRiNuXo';
		track.checked = false;
        track.displayCheck = false;
        track.displayTextBox = false;
        track.displayLabel = false;
	    this.mergeRecipientInfo.add(track);
	    
	    // Case Number
     	SCM_MF_CaseNumber casNum = new SCM_MF_CaseNumber(selectedCase);
		casNum.fieldValue = (casNum.getFieldValue() == null)?'':casNum.getFieldValue();
		this.mergeRecipientInfo.add(casNum);
	    
	    // Patient Id
	    SCM_MF_PatientId patId = new SCM_MF_PatientId(selectedCase);
		patId.fieldValue = (patId.getFieldValue() == null)?'':patId.getFieldValue();
		this.mergeRecipientInfo.add(patId);
		
	}
}