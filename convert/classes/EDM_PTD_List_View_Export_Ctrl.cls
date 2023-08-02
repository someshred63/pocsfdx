public with sharing class EDM_PTD_List_View_Export_Ctrl {
    public List<ExportAttachmentsWrapper> ptdFormatedToExport { get; private set; }
	public Boolean singleParentMode { get; private set; }
	public String docName { get; private set; }
	public String filterBy { get; set; }

	public EDM_PTD_List_View_Export_Ctrl() {
		String parentExeSumId = ApexPages.currentPage().getParameters().get('parentExeSumId');
		filterBy = ApexPages.currentPage().getParameters().get('filterBy');
		singleParentMode = String.isBlank(parentExeSumId) ? false : true;
        ptdFormatedToExport = formatAttachmentRecordsForExport(retrievePTDs(parentExeSumId));
        if (ptdFormatedToExport != null && ptdFormatedToExport.size() > 0 && !singleParentMode) {
            docName = 'All-PTDs.xls';
        } else if(ptdFormatedToExport != null && ptdFormatedToExport.size() > 0 && singleParentMode) {
            docName = ptdFormatedToExport[0].attRecord.EDM_Parent_IABP_gne__r.EDM_Drawloop_IABP_Name_gne__c + '-PTDs.xls';
        } else {
            docName = 'no-records.xls';
        }
	}

	private List<EDM_Attachment_gne__c> retrievePTDs(String parentExeSumId) {
		List<String> queryFieldList = new List<String>{
				'Id', 'Name', 'EDM_Responsible_Party_gne__c', 'EDM_Responsible_Party_gne__r.Name', 'EDM_Document_Name_gne__c', 'EDM_Due_Date_gne__c',
				'EDM_Link_gne__c', 'EDM_Upload_Date_gne__c', 'EDM_ABS_Review_Status_gne__c', 'EDM_Complete_gne__c', 'EDM_File_Name_gne__c',
				'EDM_Parent_IABP_gne__c', 'EDM_Parent_IABP_gne__r.Name', 'EDM_Parent_IABP_gne__r.EDM_Name_gne__c', 'EDM_Resultant_Due_Date_gne__c',
				'EDM_Parent_IABP_gne__r.EDM_Year_gne__c', 'EDM_Parent_IABP_gne__r.EDM_Parent_AABP_gne__r.EDM_Group_gne__c',
				'EDM_Parent_IABP_gne__r.EDM_Parent_AABP_gne__r.EDM_Unit_gne__c', 'EDM_Parent_IABP_gne__r.EDM_Parent_AABP_gne__r.EDM_Team_gne__c',
				'EDM_Parent_IABP_gne__r.EDM_Parent_IABP_gne__r.EDM_Status_gne__c', 'EDM_Parent_IABP_gne__r.EDM_Drawloop_IABP_Name_gne__c', 'EDM_Revised_Due_Date_gne__c',
				'EDM_Parent_IABP_gne__r.EDM_Type_of_Event_gne__c','EDM_Parent_IABP_gne__r.EDM_Meeting_Date_gne__c','EDM_Parent_IABP_gne__r.EDM_City_gne__c',
				'EDM_Parent_IABP_gne__r.EDM_State_gne__c','EDM_Parent_IABP_gne__r.EDM_Optional_Detail_gne__c','EDM_Parent_IABP_gne__r.EDM_End_Date_gne__c',
				'(SELECT Id, Name, CreatedDate FROM Attachments)'
		};

		String query = 'SELECT ';
		query += String.join(queryFieldList, ', ');
		query += ' FROM EDM_Attachment_gne__c';
		query += ' WHERE EDM_Pull_Through_Doc_gne__c = true';
		query += ' AND EDM_System_Type_gne__c = null';
		query += ' AND EDM_Parent_IABP_gne__r.EDM_ExeSum_Finalized_gne__c != null';
		if (singleParentMode) {
			query += ' and EDM_Parent_IABP_gne__c = \'' + parentExeSumId + '\'';
		} else {
			query += ' and EDM_Parent_IABP_gne__c IN (Select Id from EDM_IABP_gne__c WHERE EDM_Historical_gne__c = false)';
		}

		if (String.isNotBlank(filterBy)) {
			query += createFilterByClause();
		}

		query += ' ORDER BY EDM_Due_Date_gne__c, CreatedDate LIMIT 10000';
		return Database.query(query);
	}

    private List<ExportAttachmentsWrapper> formatAttachmentRecordsForExport(List<EDM_Attachment_gne__c> retrievePTDRecords) {
        List<ExportAttachmentsWrapper> exportAttWrpList = new List<ExportAttachmentsWrapper>();
        for(EDM_Attachment_gne__c attRecord : retrievePTDRecords) {
            if(!attRecord.Attachments.isEmpty()) {
				for(Attachment att : attRecord.Attachments) {
					exportAttWrpList.add(new ExportAttachmentsWrapper(attRecord, att));
				}
			} else {
				exportAttWrpList.add(new ExportAttachmentsWrapper(attRecord, null));
			}
        }
        return exportAttWrpList;
    }

	private String createFilterByClause() {

		List<String> querySearchableFieldList = new List<String> {
				'Name', 'EDM_Responsible_Party_gne__r.Name', 'EDM_Document_Name_gne__c',
				'EDM_ABS_Review_Status_gne__c', 'EDM_File_Name_gne__c',
				'EDM_Parent_IABP_gne__r.Name', 'EDM_Parent_IABP_gne__r.EDM_Name_gne__c',
				'EDM_Parent_IABP_gne__r.EDM_Year_gne__c', 'EDM_Parent_IABP_gne__r.EDM_Parent_AABP_gne__r.EDM_Group_gne__c',
				'EDM_Parent_IABP_gne__r.EDM_Parent_AABP_gne__r.EDM_Unit_gne__c', 'EDM_Parent_IABP_gne__r.EDM_Parent_AABP_gne__r.EDM_Team_gne__c',
				'EDM_Parent_IABP_gne__r.EDM_Parent_IABP_gne__r.EDM_Status_gne__c', 'EDM_Parent_IABP_gne__r.EDM_Drawloop_IABP_Name_gne__c'
		};

		String result = ' AND ( ';
		result += String.join(querySearchableFieldList, ' LIKE \'%' + filterBy + '%\' OR ');
		result += ' LIKE \'%' + filterBy + '%\'';
		result += ' ) ';
		return result;
	}

	public String getHostName() {
        String host = ApexPages.CurrentPage().getHeaders().get('host');
        return host;
    }

	public class ExportAttachmentsWrapper {
        public EDM_Attachment_gne__c attRecord {get; private set;}
        public Attachment att {get; private set;}

        public ExportAttachmentsWrapper(EDM_Attachment_gne__c rec, Attachment att) {
            this.attRecord = rec;
            this.att = att;
        }
	}
}