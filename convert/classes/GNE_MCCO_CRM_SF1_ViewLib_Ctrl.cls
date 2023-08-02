public with sharing class GNE_MCCO_CRM_SF1_ViewLib_Ctrl{
	public String workspaceId {get; private set;}
	public String searchTerm {get; private set;}
	public String tagCsv {get; private set;}
	
	public GNE_MCCO_CRM_SF1_ViewLib_Ctrl() {
		searchTerm = ApexPages.currentPage().getParameters().get('searchTerm'); 
		if(String.isNotEmpty(searchTerm) && searchTerm.endsWith('"') && searchTerm.startsWith('"')){
			searchTerm = searchTerm.substringAfter('"').substringBeforeLast('"');
		}
		
		workspaceId = ApexPages.currentPage().getParameters().get('searchWorkspaceIds');
		if(String.isNotEmpty(workspaceId)){
			if(workspaceId.indexOfIgnoreCase('ALL_WORKSPACES') != -1){
				workspaceId = '';
			} else if(workspaceId.endsWith(']') && workspaceId.startsWith('[')) {
				workspaceId = workspaceId.replace('"','\'').replace('[','(').replace(']',')');
			}
		}

		tagCsv = ApexPages.currentPage().getParameters().get('searchTags');
		if(String.isNotEmpty(tagCsv) && tagCsv.endsWith(']') && tagCsv.startsWith('[')){
			tagCsv = tagCsv.replace('"','').replace('[','').replace(']','');
		}
	}

	@RemoteAction
	@ReadOnly
	public static Integer getRecordsCount(String libId, String search){
		String query = 'SELECT Id FROM ContentDocument ';
        
        if(!String.isEmpty(libId)) {
        	query += ' WHERE ParentId IN ' + libId + ' ';
        } else {
        	query += ' WHERE PublishStatus IN (\'R\', \'P\') ';
        }
        
        if(!String.isEmpty(search)) {
        	query += ' AND Title Like \'%' + search + '%\'';
        }
        return Database.query(query).size();
	}

	/*
     * Return List of wrapper class LibraryContent for JS libraryWidget (AJAX)
     *
     * return List<LibraryContent>
     */
    @RemoteAction
    @ReadOnly
    public static LibraryContentWrapper getUserLibraryContent(String libId, Integer displayLength, Integer displayStart, String search, String tagList) {
    	List<LibraryContent> result = new List<LibraryContent>();
    	Set<String> tags = new Set<String>();
    	Boolean tagSearch = false;
    	Boolean partialSearch = displayLength > 0;
    	if(String.isNotEmpty(tagList)){
    		tagSearch = true;
    		tags.addAll(tagList.split(','));
    	}

        String query = 'SELECT Id, LatestPublishedVersionId, FileType, ContentModifiedDate, ContentSize, Description, FileExtension, Owner.Id, Owner.Name, Title, ParentId, LatestPublishedVersion.TagCsv FROM ContentDocument ';
        
        if(!String.isEmpty(libId)) {
        	query += ' WHERE ParentId IN ' + libId + ' ';
        } else {
        	query += ' WHERE PublishStatus IN (\'R\', \'P\') ';
        }
        
        if(!String.isEmpty(search)) {
        	query += ' AND Title Like \'%' + search + '%\'';
        }
        query += ' ORDER BY Title ASC';
        if (displayStart > 0) {
        	query += ' OFFSET ' + displayStart;
        }
        
        System.debug(query);
        Integer recordsCount = 0;
        Integer lastRecord = displayStart;
		for(ContentDocument doc : Database.query(query)) {
			lastRecord ++;
			Boolean isValid = true;
			if(tagSearch){
				isValid = false;
				if(String.isNotEmpty(doc.LatestPublishedVersion.TagCsv)){
					for(String tagItem :doc.LatestPublishedVersion.TagCsv.split(',')){
						if(tags.contains(tagItem)){
							isValid = true;
							break;
						}
					}
				}

			} 
			if(isValid) {
				result.add(
					new LibraryContent(	doc.Id, doc.LatestPublishedVersionId, doc.FileType, doc.ContentModifiedDate, doc.ContentSize, doc.Description, doc.FileExtension, doc.Owner.Id, doc.Owner.Name, doc.Title, doc.ParentId, null )
				);
			}
			if(partialSearch && ++recordsCount >= displayLength){
				break;
			}
		}

        return new LibraryContentWrapper(result, lastRecord);
    }

    public class LibraryContentWrapper{
    	public List<LibraryContent> results {get; private set;}
    	public Integer lastRecordNum {get; private set;}

    	public LibraryContentWrapper(List<LibraryContent> res, Integer lastRec){
    		this.results = res;
    		this.lastRecordNum = lastRec;
    	}
    }

    /*
     * Wrapper Class
     *
     * LibraryContent
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
    public class LibraryVersion  {
    	
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