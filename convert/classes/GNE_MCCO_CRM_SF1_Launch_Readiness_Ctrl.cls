public with sharing class GNE_MCCO_CRM_SF1_Launch_Readiness_Ctrl {
	
	private final Id PAGE_ID;
	public Boolean isPage { get; set; }
	
	public List<GNE_MCCO_CRM_Launch_Readiness_Page__c> menuItemsList { get; private set; }
	public List<GNE_MCCO_CRM_Launch_Readiness_Content__c> sectionList { get; private set; }
	
	private GNE_MCCO_CRM_Launch_Readiness_Page__c page { get; private set; }
	public String pageColor { get; private set; }
	public String pageLogo { get; private set; }
	public final String librariesListJson { get; private set; }

	public GNE_MCCO_CRM_SF1_Launch_Readiness_Ctrl() {
		
		isPage = false;
		
		PAGE_ID = (ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != '') ? ApexPages.currentPage().getParameters().get('id') : null;
		
		if(String.IsNotBlank(PAGE_ID)) {
			isPage = true;
		}
		
		if(isPage) {
			sectionList = getContent(PAGE_ID);
			pageColor = getPage(PAGE_ID).Color_gne__c;
			pageLogo = getPage(PAGE_ID).Logo_gne__c;
		} else {
			menuItemsList = getMenuItems();
		}
		
		librariesListJson = JSON.serializePretty(getLibrariesList());
		
	}
	
    private List<Library> getLibrariesList() {
    	List<Library> libs = new List<Library>();
    	for(ContentWorkspace workSpace : [SELECT Id, Name, CreatedBy.Id, CreatedBy.Name FROM ContentWorkspace LIMIT 5000]) {
    		libs.add(
				new Library(workSpace.Id, workSpace.Name, workSpace.CreatedBy.Name, workSpace.CreatedBy.Id)
			);
    	}
        return libs;
    }
    

	private List<GNE_MCCO_CRM_Launch_Readiness_Page__c> getMenuItems() {
		return [SELECT Id, Name, Title_gne__c, Active_gne__c, Color_gne__c FROM GNE_MCCO_CRM_Launch_Readiness_Page__c WHERE Active_gne__c = true AND Type_gne__c = 'Launch Readiness' ORDER BY Name];
	}
	
	private GNE_MCCO_CRM_Launch_Readiness_Page__c getPage(String pageId) {
		if(page != null && page.Id == pageId) {
			return page;
		} else {
			return [SELECT Id, Color_gne__c, Logo_gne__c FROM GNE_MCCO_CRM_Launch_Readiness_Page__c WHERE Id = :pageId LIMIT 1];
		}
	}
	
	private List<GNE_MCCO_CRM_Launch_Readiness_Content__c> getContent(String pageId) {
		List<GNE_MCCO_CRM_Launch_Readiness_Content__c> result = [SELECT Id, Name, Active_gne__c, Content_gne__c, Target_Completion_Date_gne__c, Type_gne__c, Order_gne__c FROM GNE_MCCO_CRM_Launch_Readiness_Content__c WHERE Launch_Readiness_Page__c = :pageId AND Active_gne__c = true ORDER BY Order_gne__c];
		
		for(GNE_MCCO_CRM_Launch_Readiness_Content__c item : result) {			
			
			if(item.Target_Completion_Date_gne__c != null) {
				
				String month = (String.valueOf(item.Target_Completion_Date_gne__c.month()).length() == 1 ? '0' : '') + item.Target_Completion_Date_gne__c.month();
				String day = (String.valueOf(item.Target_Completion_Date_gne__c.day()).length() == 1 ? '0' : '') + item.Target_Completion_Date_gne__c.day();
				String year = String.valueOf(item.Target_Completion_Date_gne__c.year());

				item.Content_gne__c = item.Content_gne__c.replace('{{ Target_Completion_Date }}', '<strong style="color: #BE302C">' + month + '/' + day + '/' + year + '</strong>');
				
			}
			
		}
		 
		return result;
	}
	
	@ReadOnly
	@RemoteAction
    public static List<LibraryContent> getUserLibraryContent(String libId, Integer displayLength, Integer displayStart) {
    	List<LibraryContent> result = new List<LibraryContent>();

        String query = 'SELECT Id, LatestPublishedVersionId, FileType, ContentModifiedDate, ContentSize, Description, FileExtension, Owner.Id, Owner.Name, Title, ParentId FROM ContentDocument ';
        
        if(!String.isEmpty(libId)) {
        	query += ' WHERE ParentId = :libId ';
        } else {
        	query += ' WHERE PublishStatus = \'R\' ';
        }

        query += ' ORDER BY Title ASC';
        query += ' LIMIT ' +  displayLength;
        if (displayStart > 0) {
        	query += ' OFFSET ' + displayStart;
        }
        
        System.debug(query);
        System.debug(Database.query(query));

		for(ContentDocument doc : Database.query(query)) {
			result.add(
				new LibraryContent(	doc.Id, doc.LatestPublishedVersionId, doc.FileType, doc.ContentModifiedDate, doc.ContentSize, doc.Description, doc.FileExtension, doc.Owner.Id, doc.Owner.Name, doc.Title, doc.ParentId, null )
			);
		}

        return result;
    }
	        
    /*
     * Wrapper Virtual Class
     *
     * FileIcons
     */ 
 	public class LibraryContent extends FileIcons {
    	
    	public Id Id { get; private set; }
    	public Id LatestPublishedVersionId { get; private set; }
    	public String FileType { get; private set; }
    	public DateTime ContentModifiedDate { get; private set; }
    	public Integer ContentSize { get; private set; }
    	public String Description { get; private set; }
    	public String FileExtension { get; private set; }
    	public Id OwnerId { get; private set; }
    	public String OwnerName { get; private set; }
    	public String Title { get; private set; }
    	public Id ParentId { get; private set; }
    	public String Icon { get; private set; }
    	public String IconSmall { get; private set; }
    	public List<LibraryVersion> ContentVersions { get; private set; }
	   	
	   	public LibraryContent(Id Id, Id LatestPublishedVersionId, String FileType, DateTime ContentModifiedDate, Integer ContentSize, String Description, String FileExtension, Id OwnerId, String OwnerName, String Title, Id ParentId, List<LibraryVersion> versions) {
	   		this.Id 						= Id;
	   		this.LatestPublishedVersionId 	= LatestPublishedVersionId;
	   		this.FileType 					= FileType;
	   		this.ContentModifiedDate 		= ContentModifiedDate;
	   		this.ContentSize 				= ContentSize;
	   		this.Description 				= Description;
	   		this.FileExtension 				= FileExtension;
	   		this.OwnerId 					= OwnerId;
	   		this.OwnerName 					= OwnerName;
	   		this.Title 						= Title;
	   		this.ParentId 					= ParentId;
	   		this.Icon 						= getMediumIcon(FileType);
	   		this.IconSmall 					= getSmallIcon(FileType);
	   		this.ContentVersions			= versions;
	   	}
	   	
    }
        
    /*
     * Wrapper Class
     *
     * LibraryVersion
     */        
    public class LibraryVersion {
    	
    	public Id Id { get; private set; }
    	public String CreatedByName { get; private set; }
    	public Id CreatedById { get; private set; }
    	public DateTime CreatedDate { get; private set; }
    	public String FileType { get; private set; }
    	public String FileExtension { get; private set; }
    	public DateTime ContentModifiedDate { get; private set; }
    	public String Description { get; private set; }
    	public DateTime LastModifiedDate { get; private set; }
    	public String ReasonForChange { get; private set; }
    	public Integer ContentSize { get; private set; }
    	public String Title { get; private set; }
    	public String VersionNumber { get; private set; }
    	public String PublishStatus { get; private set; }
    	
    	public LibraryVersion(Id Id, String CreatedByName, Id CreatedById, DateTime CreatedDate, String FileType, String FileExtension, DateTime ContentModifiedDate, String Description, DateTime LastModifiedDate, String ReasonForChange, Integer ContentSize, String Title, String VersionNumber, String PublishStatus) {
    		this.Id 					= Id;
    		this.CreatedByName 			= CreatedByName;
    		this.CreatedById 			= CreatedById;
    		this.CreatedDate 			= CreatedDate;
    		this.FileType		 		= FileType;
    		this.FileExtension 			= FileExtension;
    		this.ContentModifiedDate 	= ContentModifiedDate;
    		this.Description 			= Description;
    		this.LastModifiedDate 		= LastModifiedDate;
    		this.ReasonForChange 		= ReasonForChange;
    		this.ContentSize 			= ContentSize;
    		this.Title 					= Title;
    		this.VersionNumber 			= VersionNumber;
    		this.PublishStatus 			= PublishStatus;
    	}
    }
        
    /*
     * Wrapper Class
     *
     * Library
     */      
    public class Library implements Comparable  {
    	
    	public String Id { get; private set; }
    	public String Name { get; private set; }
    	public String CreatedByName { get; private set; }
    	public String CreatedById { get; private set; }
    	
    	public Library(String Id, String Name, String CreatedByName, String CreatedById) {
    		this.Id 			= Id;
    		this.Name 			= Name;
    		this.CreatedByName 	= CreatedByName;
    		this.CreatedById 	= CreatedById;
    	}
    	
        public Integer compareTo(Object compareTo) {
            Library comparableData = (Library)compareTo;
            Integer result = 0;
            if (this.Name == comparableData.Name) {
                result = 0;
            } else if (this.Name > comparableData.Name) {
                result = 1;
            } else {
                result = -1;
            }

            return result;
        }

    }
        
    /*
     * Wrapper Virtual Class
     *
     * FileIcons
     */ 
     public virtual class FileIcons {
     	
		private final Map<String, String> iconsMap = new Map<String, String> {
		    'BMP' => 'doctype_image_',
		    'CSV' => 'doctype_csv_',
		    'EXCEL' => 'doctype_excel_',
		    'EXCEL_X' => 'doctype_excel_',
		    'EXE' => 'doctype_exe_',
		    'GIF' => 'doctype_image_',
		    'HTML' => 'doctype_html_',
		    'JPG' => 'doctype_image_',
		    'MOV' => 'doctype_video_',
		    'WMV' => 'doctype_video_',
		    'MP4' => 'doctype_mp4_',
		    'MP3' => 'doctype_audio_',
		    'PDF' => 'doctype_pdf_',
		    'PNG' => 'doctype_image_',
		    'POWER_POINT' => 'doctype_ppt_',
		    'POWER_POINT_X' => 'doctype_ppt_',
		    'TEXT' => 'doctype_txt_',
		    'UNKNOWN' => 'doctype_unknown_',
		    'WORD' => 'doctype_word_',
		    'WORD_X' => 'doctype_word_',
		    'XML' => 'doctype_xml_',
		    'ZIP' => 'doctype_zip_',
		    'PACK' => 'doctype_pack_'
	   	};
	   	
	   	protected String getSmallIcon(String fileType) {
	   		String icon = iconsMap.get(fileType);
	   		if(!String.isEmpty(icon)) {
	   			return icon + '16.png';
	   		} else {
	   			return 'doctype_unknown_16.png';
	   		}
	   	}
	   		   	
	   	protected String getMediumIcon(String fileType) {
	   		String icon = iconsMap.get(fileType);
	   		if(!String.isEmpty(icon)) {
	   			return icon + '32.png';
	   		} else {
	   			return 'doctype_unknown_32.png';
	   		}
	   	}
	   		   	
	   	protected String getBigIcon(String fileType) {
	   		String icon = iconsMap.get(fileType);
	   		if(!String.isEmpty(icon)) {
	   			return icon + '48.png';
	   		} else {
	   			return 'doctype_unknown_48.png';
	   		}
	   	}
	   	
     }
		
}