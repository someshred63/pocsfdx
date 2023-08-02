@RestResource(urlMapping='/sfa2_report_engine/*')
global with sharing class GNE_SFA2_PFG_Report_Engine {
	
	private static final String HTML_COLUMN_ATTRS = 'align="center" style="border:1px solid black;"';
	private static final String HTML_TABLE_ATTRS = 'align="center" style="border:1px solid black;"';
	private static final Pattern PSEUDO_LINK_PATTERN = Pattern.compile('LINK\\("(.+)";"(.+)"\\)');
	private static final String PSEUDO_LINK_FORMAT = 'LINK("{0}";"{1}")';
	private static final String GOOGLE_WORKBOOK_LINK_FORMAT = 'HYPERLINK("{0}","{1}")';
	
	public static Id saveReport(String reportName, DateTime timeStamp, List<ReportRow> reportRows) {
		return saveReport(getReportId(reportName, timeStamp), (Id)null, reportRows);
	}
	
	public static Id saveReport(String reportName, DateTime timeStamp, Id batchJobId, List<ReportRow> reportRows) {
		return saveReport(getReportId(reportName, timeStamp), batchJobId, reportRows);
	}
	
	public static Id saveReport(String reportId, List<ReportRow> reportRows) {
		return saveReport(reportId, (Id)null, reportRows);
	}
	
	public static Id saveReport(String reportId, Id batchJobId, List<ReportRow> reportRows) {
		Id result = null;
		
		if(System.isBatch() || System.isFuture() || System.isScheduled()) {
			result = intSaveReport(reportId, batchJobId, JSON.serialize(reportRows));
		} else {
			Set<String> sLabels = GNE_SFA2_PFG_Util.getSessionLabels();
    		futureSaveReport(reportId, batchJobId, JSON.serialize(reportRows), sLabels!=null ? JSON.serialize(sLabels) : null);
		}
		
		return result;
	}
	
	@future
	public static void futureSaveReport(String reportId, Id batchJobId, String reportJSON, String sessionLabelsJSON) {
		if(sessionLabelsJSON!=null) {
			GNE_SFA2_PFG_Util.setSessionLabels((Set<String>)JSON.deserializeStrict(sessionLabelsJSON, Set<String>.class));
		}
		
		intSaveReport(reportId, batchJobId, reportJSON);
	}	
	
	public static Id intSaveReport(String reportId, Id batchJobId, String reportJSON) {
		Id recId = null;
		
		try {
			List<SFA2_PFG_Report_gne__c> reportPartsToInsert = new List<SFA2_PFG_Report_gne__c>();
			
			Integer maxPartSize = SFA2_PFG_Report_gne__c.Fields.Body_gne__c.getDescribe().getLength();
			Integer size = reportJSON.length();
			
			for(Integer startIdx=0; startIdx<size; startIdx+=maxPartSize) {
				String body = reportJSON.substring(startIdx, Math.min(startIdx+maxPartSize, size));
				SFA2_PFG_Report_gne__c reportPart = new SFA2_PFG_Report_gne__c(
						Report_Id_gne__c = reportId,
						Batch_Job_Id_gne__c = batchJobId,
						Body_gne__c = body, 
						Part_No_gne__c = (startIdx/maxPartSize+1));
				reportPartsToInsert.add(reportPart);
			}
			
			if(!reportPartsToInsert.isEmpty()) {
				insert reportPartsToInsert;
				recId = reportPartsToInsert[0].Id;
			}
		} catch(Exception ex) {
			GNE_SFA2_PFG_ExceptionHandler.handleException(ex);
			GNE_SFA2_PFG_ExceptionHandler.reportExceptions();
		}
		
		return recId;
	}
	
	public static String getReportInJSON(String reportId) {
		String reportJSON = '';
		
		for(SFA2_PFG_Report_gne__c reportPart : [SELECT Body_gne__c FROM SFA2_PFG_Report_gne__c WHERE Report_Id_gne__c = :reportId ORDER BY Part_No_gne__c asc]) {
			reportJSON += reportPart.Body_gne__c;
		}
		
		return reportJSON;
	}
	
	public static List<ReportRow> deserializeReport(String reportId) {
		return (List<ReportRow>)JSON.deserialize(getReportInJSON(reportId),List<ReportRow>.class);
	}
	
	public static String getReportId(String reportName, DateTime timeStamp) {
		return String.format('{0}-{1}-{2}', new String[]{
				reportName, 
				timeStamp.format('yyyyMMdd_hhmmss'), 
				UserInfo.getUserName().substringBefore('@')});
	}
	
	@HttpPost
    global static List<ReportRow> getReport(String reportId) {
        return deserializeReport(reportId);
    }
    
    public static String createPseudoLink(String url, String description) {
    	return String.format(PSEUDO_LINK_FORMAT, new String[]{url, description});
    }
    
    public static String getGoogleWorkbookLink(String url, String description) {
    	return String.format(GOOGLE_WORKBOOK_LINK_FORMAT, new String[]{GNE_SFA2_PFG_Util.getSalesforceURL(url), description});
    }
    
    public static String createHtmlTable(List<ReportRow> reportRows) {
		ReportRow header = reportRows.remove(0);
		String htmlTable = header.getHtmlRow(true);
		
		for(ReportRow row : reportRows) {
			htmlTable += row.getHtmlRow();
		}
		
		htmlTable = '<table ' + HTML_TABLE_ATTRS + '>' + htmlTable + '</table>';
		return htmlTable;
	}
	
	public static List<List<Object>> createCsv(List<ReportRow> reportRows) {
		List<List<Object>> result = new List<List<Object>>();
		
		for(ReportRow row : reportRows) {
			result.add(row.getCsv());
		}
		
		return result;
	}
	
	public static List<List<Object>> createGoogleWorkbookSheet(List<ReportRow> reportRows) {
		List<List<Object>> result = new List<List<Object>>();
		
		for(ReportRow row : reportRows) {
			result.add(row.getGoogleWorkbookRow());
		}
		
		return result;
	}
    
    global class ReportRow {
    	private List<ReportCell> cells = new List<ReportCell>();
    	private Map<String,String> props = new Map<String,String>();
    	
    	public ReportRow(List<Object> a_cells) {
    		for(Object cell : a_cells) {
    			if(cell!=null && cell instanceof ReportCell) {
    				cells.add((ReportCell)cell);
    			} else {
    				cells.add(new ReportCell(cell));	
    			}
    		}
    	}
    	
    	public String getHtmlRow() {
    		return getHtmlRow(false);
    	}
    	
    	public String getHtmlRow(Boolean isHeader) {
    		String result = null;
    		List<String> htmlCells = new List<String>();
    		
    		for(ReportCell cell : cells) {
    			htmlCells.add(cell.getHtmlCell());
    		}
    		
    		if(isHeader) {
    			result = '<tr><th ' + HTML_COLUMN_ATTRS + '>' + String.join(htmlCells,'</th><th ' + HTML_COLUMN_ATTRS + '>') + '</th></tr>';
    		} else {
    			result = '<tr><td ' + HTML_COLUMN_ATTRS + '>' + String.join(htmlCells,'</td><td ' + HTML_COLUMN_ATTRS + '>') + '</td></tr>';
    		}
    		
    		return result;
    	}
    	
    	public List<Object> getCsv() {
    		List<Object> result = new List<Object>();
    		
    		for(ReportCell cell : cells) {
    			result.add(cell.getCsvCell());
    		}
    		
    		return result;
    	}
    	
    	public List<Object> getGoogleWorkbookRow() {
    		List<Object> result = new List<Object>();
    		
    		for(ReportCell cell : cells) {
    			result.add(cell.getGoogleWorkbookCell());
    		}
    		
    		return result;
    	}
    }
    
    global class ReportCell {
    	private String v; // Plain Text 
    	private Map<String,String> props = new Map<String,String>();
    	private transient String html;
    	
    	public ReportCell(Object a_value) {
    		Matcher m;
    		
    		if(a_value!=null && a_value instanceof String && (m = PSEUDO_LINK_PATTERN.matcher((String)a_value)).matches()) {
    			String url = m.group(1);
				String description = m.group(2);
				v = description;
				props.put('gwb', getGoogleWorkbookLink(url, description));
				html = GNE_SFA2_PFG_Util.getSalesforceLink(url, description);
			} else {
				v = String.valueOf(a_value);
			}
		}
		
		public ReportCell(Object a_pt, String a_gwb, String a_html) {
			v = String.valueOf(a_pt);
			props.put('gwb', a_gwb);
			html = a_html;
		}
		
		public String getHtmlCell() {
			return String.isNotBlank(html) ? html : String.valueOf(v);
		}
		
		public Object getGoogleWorkbookCell() {
			String gwb = (String)props.get('gwb');
			return String.isNotBlank(gwb) ? (Object)('=' + gwb) : getCsvCell();
		}
		
		public Object getCsvCell() {
			return v!=null ? v : '';
		}
	}
	
	public interface ReportEngine {
		String getPfgReportName();
	}
}