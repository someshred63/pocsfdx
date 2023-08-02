/**
 *  Class that allows specifying a list of attachments by key, and determining those attachments.
 **/
public with sharing class GFRS_AttachmentCollector {
    
    /**
     *  Map of attachment SFDC attachment ids and the associated keys.
     *  <p>Used as an intermediary to determine the sfdc ids, and the list of keys to 
     **/
    private Map<Id,String> keyMap;
    
    /**
     *  Map of the keys and the associated attachment
     **/
    private Map<id,Attachment> attachments;
    
    public GFRS_AttachmentCollector( Attachment[] attachments ){
        this.attachments = new Map<id,Attachment>( attachments );
        
        for( Attachment a : attachments ){
            a.body = null;
        }
    }
    
    /**
     *  Determines whether the attachments have been retrieved.
     *  @return (Boolean)
     **/
    public Boolean foundAttachments(){
        return( this.attachments.size() > 0 );
    }
    
    /**
     *  Finds a particular attachment by a key
     *  <p>Note, the attachments must be found already</p>
     *  @param key (String)
     *  @return Attachment - the found attachment registered with that key or null if one was not found.
     **/
    public Attachment getFoundAttachmentByKey( String key ){
        //system.debug(key);
        Id targetId = convertStringToId( key );
        if( targetId == null ) return( null );
        
        if( this.attachments.containsKey( key )){
            return( this.attachments.get( key ));
        } else {
            return( null );
        }
    }
    
    /**
     *  Finds a particular attachment by a key, or makes an attachment using the parent id
     *  <p>Utility method, exactly the same as getFoundAttachmentByKey, but creates an attachment if one was not found</p>
     *  @param String key - key to find the attachment under
     *  @param Id newParentId - Id to consider the parent of the attachment if it needs to be created
     *  @return Attachment - the found attachment registered with that key or a new attachment with ParentId = parentId
     ***/
    public Attachment getFoundAttachmentByKeyOrMakeOne( String key, Id newParentId ){
        //system.debug(key);
        //system.debug(newParentId);
        Attachment result = getFoundAttachmentByKey( key );
        if( result == null ){
            result = new Attachment( ParentId = newParentId );
        }
        return( result );
    }
    
    /** Converts a string to an id **/
    private id convertStringToId( String key ){
        //system.debug(key);
        if(key == null) {
            return key;
        }
        Id testVal;
        try {
            testVal = Id.valueOf( key );
            return( testVal );
        } catch( Exception err ){
            return( null );
        }
    }
}