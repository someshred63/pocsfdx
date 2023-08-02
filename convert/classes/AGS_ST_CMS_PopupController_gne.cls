public with sharing class AGS_ST_CMS_PopupController_gne {
	public class AGS_ST_Popup_Exception extends Exception {}

	public Boolean isPopupIdValid { get { return (popupId != null); } }
	public Id                              popupId         { get; set; }
	public AGS_ST_FAQ_DYK_gne__c           popup           { get; set; }
	public Integer                         popupNumOfDays  { get; set; }
	public Boolean                         isViewable      { get; set; }

	public AGS_ST_CMS_PopupController_gne() {
		String viewMode = ApexPages.currentPage().getParameters().get('viewmode');
		isViewable = true;
		if( String.isBlank(viewMode) || viewMode.equals('0') || !AGS_ST_Utils.isCCOManager(Userinfo.getProfileId())) {
			isViewable = false;
		}
		popupNumOfDays = 0;
		validatePopupId();
	}

	private void validatePopupId() {
		try {
			popupId = ApexPages.currentPage().getParameters().get('id');
			if(popupId == null) {
				throw new AGS_ST_Popup_Exception();
			}
			String agsStCmsObjName = popupId.getSObjectType().getDescribe().getName();
            if(agsStCmsObjName != 'AGS_ST_FAQ_DYK_gne__c') {
                throw new AGS_ST_Popup_Exception();
            }
            popup = getPopup(popupId);
            if(popup == null) {
            	throw new AGS_ST_Popup_Exception();
            }
            if(popup.StartDate_gne__c != null && popup.EndDate_gne__c != null) {
            	popupNumOfDays = popup.StartDate_gne__c.daysBetween(popup.EndDate_gne__c)+1;
            }
		} catch(Exception ex) {
			popupId = null;
			popup = new AGS_ST_FAQ_DYK_gne__c(
				Type_gne__c = 'Popup', Status_gne__c = 'Inactive'
			);
		}
	}

	private AGS_ST_FAQ_DYK_gne__c getPopup(Id pId) {
		try {
			AGS_ST_FAQ_DYK_gne__c popup = [ 
				SELECT 	Id, TC_Description_Text_gne__c, Status_gne__c, CreatedDate, CreatedById, 
						StartDate_gne__c, EndDate_gne__c
				FROM 	AGS_ST_FAQ_DYK_gne__c
				WHERE 	Id = :pId
				AND 	Type_gne__c = 'Popup'
				LIMIT   1
			];
            if(isViewable && popup != null) {
                Map<String, String> faqMap = new Map<String, String>();
                for(AGS_ST_FAQ_DYK_gne__c faq : [SELECT Id, Question_gne__c FROM AGS_ST_FAQ_DYK_gne__c where Type_gne__c='FAQ']) {
                    faqMap.put(faq.Id, faq.Question_gne__c);
                }
                for(String strId : faqMap.keySet()) {
                	popup.TC_Description_Text_gne__c = popup.TC_Description_Text_gne__c.replace('<a href="#" data-faq-id="'+strId+'"></a>', '<faqLink>'+faqMap.get(strId)+'<faqLinkEnd>');
                }
            }
			return popup;
		} catch(Exception ex) {
			return null;
		}
	}

	public List<SelectOption> getFaqs() {
		List<AGS_ST_FAQ_DYK_gne__c> faqs = [
			SELECT Id, Question_gne__c, Question_number_gne__c, Answer_gne__c 
			FROM AGS_ST_FAQ_DYK_gne__c 
			WHERE Type_gne__c='FAQ' order by Question_number_gne__c
		];
		List<SelectOption> faqSelOpts = new List<SelectOption>();
		faqSelOpts.add( new SelectOption( '', '-Select-' ) );
		for(AGS_ST_FAQ_DYK_gne__c faq : faqs) {
			faqSelOpts.add(
				new SelectOption(faq.Id, faq.Question_number_gne__c + ' ' +  faq.Question_gne__c)
			);
		}
		return faqSelOpts;
	}

	public PageReference save() {
		upsert popup;
		popup = getPopup(popup.Id);
		return null;
	}

    public PageReference backToList() {
    	return goToPopupsList();
    }

	public PageReference goToPopupsList() {
		PageReference pr = new PageReference('/apex/AGS_ST_CMS_gne');
        pr.setRedirect(true);
        return pr;
	}

    public PageReference setActive() {
    	try {
    		if(popup != null && popup.Id != null) {
		    	AGS_ST_FAQ_DYK_gne__c popupToActive = [SELECT Id, Status_gne__c FROM AGS_ST_FAQ_DYK_gne__c WHERE Id = :popup.Id];
		    	popupToActive.Status_gne__c = 'Active';
		    	popup.Status_gne__c = 'Active';
		    	update popupToActive;
    		} else {
    			popup.Status_gne__c = 'Active';
    		}
        } catch(Exception ex) {
            return null;
        }
    	return null;
    }

    public PageReference setInactive() {
    	try {
	        if(popup != null && popup.Id != null) {
		        AGS_ST_FAQ_DYK_gne__c popupToActive = [SELECT Id, Status_gne__c FROM AGS_ST_FAQ_DYK_gne__c WHERE Id = :popup.Id];
		        popupToActive.Status_gne__c = 'Inactive';
		        popup.Status_gne__c = 'Inactive';
		        update popupToActive;
            } else {
                popup.Status_gne__c = 'Inactive';
            }
        } catch(Exception ex) {
            return null;
        }
        return null;
    }
}