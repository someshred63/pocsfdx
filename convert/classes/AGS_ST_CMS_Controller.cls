public class AGS_ST_CMS_Controller {
    public List<AGS_ST_FAQ_DYK_gne__c> faqs { get { return getFaqObjs(); } set; }
    public List<AGS_ST_FAQ_DYK_gne__c> dyks { get { return getDykObjs(); } set; }
    public String aboutSunshineAct      { get; set; }
    public String termsCond             { get; set; }
    public String researchPLD           { get; set; }
    public String nonresearchPLD        { get; set; }
    public String bothPLD               { get; set; }
    public String headerDescriptionPD   { get; set; }

    public AGS_ST_FAQ_DYK_gne__c newDyk { get; set; }
    public AGS_ST_FAQ_DYK_gne__c newFaq { get; set; }

    public String dykLabel              { get; set; }
    public Boolean isEditSunAct         { get; set; }
    public Boolean isEditTermsCond      { get; set; }
    public Boolean isEditPaymentDetails { get; set; }
    public Boolean isEditPLD            { get; set; }

    public ToolTipHandler ttHandler     { get; set; }

    private String EDIT_POPUP_PAGE = 'AGS_ST_CMS_Popup_gne';
    public String popupId                   { get; set; }
    public Boolean isCcoManagerProfile      { get; set; }
    public Boolean isSuperAdmin             { get; set; }
    public String cmsPaymentIdDisplayDate   { get; set; }

    public AGS_ST_CMS_Controller(ApexPages.StandardController controller) {
    	List<AGS_ST_FAQ_DYK_gne__c> allCMS = [
            SELECT Id, Type_gne__c, TC_Description_Text_gne__c,
                Did_You_Know_Label_gne__c, Did_You_Know_Text_gne__c,
                Answer_gne__c, Question_gne__c, Question_number_gne__c,
                ToolTip_Type_gne__c, ToolTip_Text_gne__c, ToolTip_Subject_gne__c
            FROM AGS_ST_FAQ_DYK_gne__c
            ORDER BY Question_number_gne__c
        ];

    	for(AGS_ST_FAQ_DYK_gne__c cms : allCMS) {
    		if('About Sunshine Act'.equals(cms.Type_gne__c))
    			aboutSunshineAct = cms.TC_Description_Text_gne__c;
    		else if('Terms Conditions'.equals(cms.Type_gne__c))
    			termsCond = cms.TC_Description_Text_gne__c;
    		else if('ToolTip'.equals(cms.Type_gne__c) && 'ResearchTypeDescription'.equals(cms.ToolTip_Type_gne__c))
    			researchPLD = cms.TC_Description_Text_gne__c;
    		else if('ToolTip'.equals(cms.Type_gne__c) && 'NonResearchTypeDescription'.equals(cms.ToolTip_Type_gne__c))
    			nonresearchPLD = cms.TC_Description_Text_gne__c;
    		else if('ToolTip'.equals(cms.Type_gne__c) && 'BothPaymentTypesDescription'.equals(cms.ToolTip_Type_gne__c))
    			bothPLD = cms.TC_Description_Text_gne__c;
            else if('ToolTip'.equals(cms.Type_gne__c) && 'HeaderDescriptionType'.equals(cms.ToolTip_Type_gne__c))
                headerDescriptionPD = cms.TC_Description_Text_gne__c;
    	}

        ttHandler = new ToolTipHandler();

        newDyk = new AGS_ST_FAQ_DYK_gne__c();
        newFaq = new AGS_ST_FAQ_DYK_gne__c();
        isEditSunAct = false;

        isCcoManagerProfile = AGS_ST_Utils.isCCOManager( Userinfo.getProfileId() ) ||
            UserInfo.getUserName().startsWith('ford.jenna') || UserInfo.getUserName().startsWith('jennaf');

        AGS_ST_Settings_gne__c agsSettings = AGS_ST_Utils.getCustomSettings();
        isSuperAdmin = UserInfo.getUserName().equals(agsSettings.SuperAdmin1_gne__c) ||
            UserInfo.getUserName().equals(agsSettings.SuperAdmin2_gne__c) ||
            UserInfo.getUserName().equals(agsSettings.SuperAdmin3_gne__c);
        cmsPaymentIdDisplayDate = agsSettings.CmsPaymentIdDisplayDate_gne__c.format();

    }

    public static AGS_ST_FAQ_DYK_gne__c getCmsObjectById(String cmsId) {
        return [
            SELECT  Id, Did_You_Know_Label_gne__c, Did_You_Know_Text_gne__c,
                    Answer_gne__c, Question_gne__c, Question_number_gne__c
            FROM    AGS_ST_FAQ_DYK_gne__c
            WHERE   Id = :cmsId
            LIMIT 1
        ];
    }

    public static List<AGS_ST_FAQ_DYK_gne__c> getFaqObjs() {
        return [
            SELECT  Id, Answer_gne__c, Question_gne__c, Question_number_gne__c
            FROM    AGS_ST_FAQ_DYK_gne__c
            WHERE   Type_gne__c = 'FAQ'
            ORDER BY Question_number_gne__c
        ];
    }

    public static List<AGS_ST_FAQ_DYK_gne__c> getDykObjs() {
        return [
            SELECT  Id, Did_You_Know_Label_gne__c, Did_You_Know_Text_gne__c
            FROM    AGS_ST_FAQ_DYK_gne__c
            WHERE   Type_gne__c = 'Did you know'
            ORDER BY CreatedDate
        ];
    }

    public static AGS_ST_FAQ_DYK_gne__c getCmsObjectByType(String type) {
        return [
            SELECT  Id, TC_Description_Text_gne__c
            FROM    AGS_ST_FAQ_DYK_gne__c
            WHERE   Type_gne__c = :type
            LIMIT 1
        ];
    }

    public static List<AGS_ST_FAQ_DYK_gne__c> getPaymentListDescs() {
        return [
            SELECT  Id, Type_gne__c, ToolTip_Type_gne__c, TC_Description_Text_gne__c
            FROM    AGS_ST_FAQ_DYK_gne__c
            WHERE   Type_gne__c = 'ToolTip'
            AND     ToolTip_Type_gne__c IN ('BothPaymentTypesDescription', 'ResearchTypeDescription', 'NonResearchTypeDescription')
            ORDER BY CreatedDate
        ];
    }

    public static List<AGS_ST_FAQ_DYK_gne__c> getPaymentDetailsDescs() {
        return [
            SELECT  Id, Type_gne__c, ToolTip_Type_gne__c, TC_Description_Text_gne__c
            FROM    AGS_ST_FAQ_DYK_gne__c
            WHERE   Type_gne__c = 'ToolTip'
            AND     ToolTip_Type_gne__c IN ('HeaderDescriptionType')
        ];
    }

    public List<AGS_ST_FAQ_DYK_gne__c> getPopups() {
        try {
            Map<String, String> faqMap = new Map<String, String>();
            for(AGS_ST_FAQ_DYK_gne__c faq : getFaqObjs()) {
                faqMap.put(faq.Id, faq.Question_gne__c);
            }
            // TODO: Remove LIMIT and add pagination after adding user selection functionality
            List<AGS_ST_FAQ_DYK_gne__c> popupList = [
                SELECT  Id, TC_Description_Text_gne__c, Status_gne__c, StartDate_gne__c, EndDate_gne__c
                FROM    AGS_ST_FAQ_DYK_gne__c
                WHERE   Type_gne__c = 'Popup'
                ORDER BY EndDate_gne__c DESC
                LIMIT 200
            ];
            for(AGS_ST_FAQ_DYK_gne__c popup : popupList) {
                for(String strId : faqMap.keySet()) {
                    popup.TC_Description_Text_gne__c = popup.TC_Description_Text_gne__c.replace(
                        '<a href="#" data-faq-id="' + strId + '"></a>',
                        '<faqLink>' + faqMap.get(strId) + '<faqLinkEnd>'
                    );
                }
            }
            return popupList;
        } catch(DmlException ex) {
            return new List<AGS_ST_FAQ_DYK_gne__c>();
        }
    }

    public PageReference saveCmsPaymentId() {
        AGS_ST_Settings_gne__c agsSettings = AGS_ST_Utils.getCustomSettings();
        agsSettings.CmsPaymentIdDisplayDate_gne__c = Date.parse(cmsPaymentIdDisplayDate);
        update agsSettings;
        return null;
    }

    public PageReference saveDyk() {
        newDyk.Type_gne__c = 'Did you know';
        insert newDyk;
        newDyk = new AGS_ST_FAQ_DYK_gne__c();
        return null;
    }

    public PageReference saveFaq() {
        newFaq.Type_gne__c = 'FAQ';
        insert newFaq;
        newFaq = new AGS_ST_FAQ_DYK_gne__c();
        return null;
    }

    @RemoteAction
    public static AGS_ST_FAQ_DYK_gne__c editDyk(String dykId) {
        return getCmsObjectById(dykId);
    }

    @RemoteAction
    public static AGS_ST_FAQ_DYK_gne__c editFaq(String faqId) {
        return getCmsObjectById(faqId);
    }

    @RemoteAction
    public static String saveEditFaq(String faqId,String answer, String question, String question_number) {
        AGS_ST_FAQ_DYK_gne__c l = getCmsObjectById(faqId);
        l.Answer_gne__c = answer;
        l.Question_gne__c = question;
        l.Question_number_gne__c = Decimal.valueOf(question_number);
        update l;
        return 'suc';
    }

    @RemoteAction
    public static String saveEditDyk(String dykId,String dykLabel, String dykText) {
        AGS_ST_FAQ_DYK_gne__c l = getCmsObjectById(dykId);
        l.Did_You_Know_Label_gne__c = dykLabel;
        l.Did_You_Know_Text_gne__c = dykText;
        update l;
        return 'suc';
    }

    public PageReference deleteDyk() {
        String dykId = ApexPages.CurrentPage().getParameters().get('dykId');
        AGS_ST_FAQ_DYK_gne__c dyk = getCmsObjectById(dykId);
        delete dyk;
        return null;
    }

    public PageReference deleteFaq() {
        String faqId = ApexPages.CurrentPage().getParameters().get('faqId');
        AGS_ST_FAQ_DYK_gne__c faq = getCmsObjectById(faqId);
        delete faq;
        return null;
    }

    public PageReference editSunAct() {
        isEditSunAct = true;
        return null;
    }

    public PageReference saveSunAct() {
        AGS_ST_FAQ_DYK_gne__c sa = getCmsObjectByType('About Sunshine Act');
        sa.TC_Description_Text_gne__c = aboutSunshineAct;
        update sa;
        isEditSunAct = false;
        return null;
    }

    public PageReference cnclSunAct() {
        aboutSunshineAct = getCmsObjectByType('About Sunshine Act').TC_Description_Text_gne__c;
        isEditSunAct = false;
        return null;
    }

    public PageReference editTermsCond() {
        isEditTermsCond = true;
        return null;
    }

    public PageReference saveTermsCond() {
        AGS_ST_FAQ_DYK_gne__c sa = getCmsObjectByType('Terms Conditions');
        sa.TC_Description_Text_gne__c = termsCond;
        update sa;
        isEditTermsCond = false;
        return null;
    }

    public PageReference cnclTermsCond() {
        termsCond = getCmsObjectByType('Terms Conditions').TC_Description_Text_gne__c;
        isEditTermsCond = false;
        return null;
    }

    public PageReference editPLD() {
        isEditPLD = true;
        return null;
    }

    public PageReference savePLD() {
        List<String> pldTypes = new List<String>{ 'ResearchTypeDescription', 'NonResearchTypeDescription', 'BothPaymentTypesDescription' };
        List<String> pldTexts = new List<String>{ researchPLD, nonresearchPLD, bothPLD };
        List<AGS_ST_FAQ_DYK_gne__c> plds = new List<AGS_ST_FAQ_DYK_gne__c>();
        for(String t : pldTypes) {
            plds.add( new AGS_ST_FAQ_DYK_gne__c() );
        }
        for(AGS_ST_FAQ_DYK_gne__c d : getPaymentListDescs()) {
            for(Integer i = 0; i < pldTypes.size(); i++) {
                if(pldTypes[i] == d.ToolTip_Type_gne__c) {
                    plds[i] = d;
                }
            }
        }
        for(Integer i = 0; i < plds.size(); i++) {
            plds[i].Type_gne__c                 = 'ToolTip';
            plds[i].ToolTip_Type_gne__c         = pldTypes[i];
            plds[i].TC_Description_Text_gne__c  = pldTexts[i];
        }
        upsert plds;
        isEditPLD = false;
        return null;
    }

    public PageReference cnclPLD() {
        for(AGS_ST_FAQ_DYK_gne__c description : getPaymentListDescs()) {
        	if('ResearchTypeDescription'.equals(description.ToolTip_Type_gne__c))
        		researchPLD = description.TC_Description_Text_gne__c;
        	else if('NonResearchTypeDescription'.equals(description.ToolTip_Type_gne__c))
        		nonresearchPLD = description.TC_Description_Text_gne__c;
            else if('BothPaymentTypesDescription'.equals(description.ToolTip_Type_gne__c))
                bothPLD = description.TC_Description_Text_gne__c;
        }
        isEditPLD = false;
        return null;
    }

    public PageReference editPayementDetails() {
        headerDescriptionPD = String.isBlank(headerDescriptionPD) ? null : headerDescriptionPD.replace('<br />', '\n');
        isEditPaymentDetails = true;
        return null;
    }

    public PageReference savePayementDetails() {
        List<String> pdTypes = new List<String>{ 'HeaderDescriptionType' };
        List<String> pdTexts = new List<String>{ headerDescriptionPD };
        List<AGS_ST_FAQ_DYK_gne__c> pds = new List<AGS_ST_FAQ_DYK_gne__c>();
        for(String t : pdTypes) {
            pds.add( new AGS_ST_FAQ_DYK_gne__c() );
        }
        for(AGS_ST_FAQ_DYK_gne__c d : getPaymentDetailsDescs()) {
            for(Integer i = 0; i < pdTypes.size(); i++) {
                if(pdTypes[i] == d.ToolTip_Type_gne__c) {
                    pds[i] = d;
                }
            }
        }
        for(Integer i = 0; i < pds.size(); i++) {
            pds[i].Type_gne__c                 = 'ToolTip';
            pds[i].ToolTip_Type_gne__c         = pdTypes[i];
            pds[i].TC_Description_Text_gne__c  = String.isBlank(pdTexts[i]) ? null : pdTexts[i].replace('\n', '<br />');
            if('HeaderDescriptionType'.equals(pds[i].ToolTip_Type_gne__c))
                headerDescriptionPD = pds[i].TC_Description_Text_gne__c;
        }
        upsert pds;
        isEditPaymentDetails = false;
        return null;
    }

    public PageReference cancelPayementDetails() {
        headerDescriptionPD = null;
        for(AGS_ST_FAQ_DYK_gne__c description : getPaymentDetailsDescs()) {
            if('HeaderDescriptionType'.equals(description.ToolTip_Type_gne__c))
                headerDescriptionPD = description.TC_Description_Text_gne__c;
        }
        isEditPaymentDetails = false;
        return null;
    }

    public PageReference goToPopup() {
    	PageReference pr;
        if(popupId != null) {
            pr = new PageReference('/apex/' + EDIT_POPUP_PAGE + '?id=' + popupId + '&viewmode=0');
        } else {
        	pr = new PageReference('/apex/' + EDIT_POPUP_PAGE);
        }
        pr.setRedirect(true);
        return pr;
    }

    public PageReference goToPopupView() {
    	PageReference pr = new PageReference('/apex/' + EDIT_POPUP_PAGE + '?id=' + popupId+ '&viewmode=1');
        pr.setRedirect(true);
        return pr;
    }

    public PageReference deletePopup() {
        try {
            delete [ SELECT Id FROM AGS_ST_FAQ_DYK_gne__c WHERE Type_gne__c = 'Popup' AND Id = :popupId ];
        } catch(DmlException ex) {}
        return null;
    }

    /** @date 4/2/2014
    * @Author Konrad Malinowski
    * @description ToolTipHandler class
    */
    public class ToolTipHandler {
        public List<ToolTipType>            ttTypes         { get; set; }
        public List<ToolTipWrapper>         toolTipWraps    { get; set; }
        public String                       toolTipType     { get; set; }
        public Map<String, ToolTipWrapper>  typeToObjWrapTtMap {
            get {
                Map<String, ToolTipWrapper> ttMap = new Map<String, ToolTipWrapper>();
                for(ToolTipWrapper ttWrap : toolTipWraps) {
                    ttMap.put( ttWrap.ttType.typeValue, ttWrap );
                }
                return ttMap;
            }
        }

        public ToolTipHandler() {
            ttTypes = new List<ToolTipType>{
                new ToolTipType('User Details',     'User Details'),
                new ToolTipType('Filters',          'Filters'),
                new ToolTipType('What',             'What'),
                new ToolTipType('Export',           'Export'),
                new ToolTipType('Detail1',          'Export Detail 1'),
                new ToolTipType('Detail2',          'Export Detail 2'),
                new ToolTipType('Phone',            'Phone'),
                new ToolTipType('Login',            'Login'),
                new ToolTipType('CMS Payment ID',   'CMS Payment ID')
            };
            List<AGS_ST_FAQ_DYK_gne__c> tts = getToolTips();
            Map<String, AGS_ST_FAQ_DYK_gne__c> typeToObjTtsMap = new Map<String, AGS_ST_FAQ_DYK_gne__c>();
            for(AGS_ST_FAQ_DYK_gne__c obj : tts) {
                typeToObjTtsMap.put( obj.ToolTip_Type_gne__c, obj );
            }
            toolTipWraps = new List<ToolTipWrapper>();
            for(ToolTipType t : ttTypes) {
                ToolTipWrapper ttWrap = new ToolTipWrapper( t, typeToObjTtsMap.get(t.typeValue) ) ;
                toolTipWraps.add(ttWrap);
            }
        }

        public List<AGS_ST_FAQ_DYK_gne__c> getToolTips() {
            return [
                SELECT  Id, ToolTip_Subject_gne__c, ToolTip_Text_gne__c, ToolTip_Type_gne__c
                FROM    AGS_ST_FAQ_DYK_gne__c
                WHERE   Type_gne__c = 'ToolTip'
            ];
        }

        public PageReference editToolTip() {
            typeToObjWrapTtMap.get(toolTipType).isEdit = true;
            return null;
        }

        public PageReference saveToolTip() {
            ToolTipWrapper ttWrap = typeToObjWrapTtMap.get(toolTipType);
            AGS_ST_FAQ_DYK_gne__c ttObj = ttWrap.ttObj;
            update ttObj;
            ttWrap.isEdit = false;
            return null;
        }

        public PageReference cancelToolTip() {
            refreshToolTips();
            typeToObjWrapTtMap.get(toolTipType).isEdit = false;
            return null;
        }

        public void refreshToolTips() {
            List<AGS_ST_FAQ_DYK_gne__c> tts = getToolTips();
            Map<String, AGS_ST_FAQ_DYK_gne__c> typeToObjTtsMap = new Map<String, AGS_ST_FAQ_DYK_gne__c>();
            for(AGS_ST_FAQ_DYK_gne__c obj : tts) {
                typeToObjTtsMap.put( obj.ToolTip_Type_gne__c, obj );
            }
            for(ToolTipWrapper ttWrap : toolTipWraps) {
                ttWrap.ttObj = typeToObjTtsMap.get( ttWrap.ttType.typeValue );
            }
        }
    }

    /** @date 4/2/2014
    * @Author Konrad Malinowski
    * @description ToolTipType class
    */
    public class ToolTipType {
        public String typeValue { get; set; }
        public String typeLabel { get; set; }
        public ToolTipType(String typeValue, String typeLabel) {
            this.typeValue = typeValue;
            this.typeLabel = typeLabel;
        }
    }

    /** @date 4/2/2014
    * @Author Konrad Malinowski
    * @description ToolTipWrapper class
    */
    public class ToolTipWrapper {
        public ToolTipType              ttType  { get; set; }
        public AGS_ST_FAQ_DYK_gne__c    ttObj   { get; set; }
        public Boolean                  isEdit  { get; set; }
        public ToolTipWrapper(ToolTipType ttType, AGS_ST_FAQ_DYK_gne__c ttObj) {
            this.ttType = ttType;
            this.ttObj = ttObj;
            isEdit = false;
        }
    }
}