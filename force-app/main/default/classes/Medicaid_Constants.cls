/************************************************************
*  @author: Palani Jayachandran
*  Date: 2021-07-21
*  Description: Utility class to hold all constant values
*  Test class: 
*    
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
public with sharing class Medicaid_Constants {
    public static final String BLANK_VALUE = '';
    public static final String DELIMITED_BY_SPACE = ' ';
    public static final String DELIMITED_BY_COMMA = ',';
    public static final String MEDICAID_STATE = 'MedicaidState';
    public static final String ACTION_TYPE_ARCHIVE = 'Archive';
    public static final String ACTION_TYPE_DELETE = 'Delete';
    public static final String STATUS_DRAFT = 'Draft';
    public static final String STATUS_ONLINE = 'Online';
    public static final String STATUS_ARCHIVED = 'Archived';
    public static final String STATUS_PUBLISHED = 'Published';
    public static final String SUCCESS = 'Success';
    public static final String ERROR = 'Error';
    public static final String ARTICLE_ARCHIVE_SUCCESS_MSG = 'Article Archived Successfully...';
    public static final String ARTICLE_ARCHIVE_ERROR_MSG = 'Article cannot be archived. Please contact system support.';
    public static final String ARTICLE_ARCHIVE_PUBLISH_ERROR_MSG = 'Atleast one article version should be in Published/Online status to Archive.';
    public static final String ARTICLE_DELETE_SUCCESS_MSG = 'Article Deleted Successfully...';
    public static final String ARTICLE_DELETE_ERROR_MSG = 'Article cannot be deleted. Please contact system support.';
    public static final String DUPLICATE_STATE_ERROR_MSG = 'State record already exists...!!!';
    public static final String STATE_NOT_VALID_ERROR_MSG = 'Not a valid State. Please enter the valid state name.';
    public static final String DUPLICATE_LABELER_ERROR_MSG = 'The Labeler: #labeler record already exists.';
    public static final String DUPLICATE_PROGRAM_ERROR_MSG = 'This is the duplicate record of Program Ref#: #ref.';
    public static final String REPLACE_LABELER = '#labeler';
    public static final String REPLACE_STATE = '#state';
    public static final String REPLACE_REFERENCE_NUMBER = '#ref';
}