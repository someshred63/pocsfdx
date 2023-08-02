/*
Created:		2009.01.11
By:				Sanat Gersappa
Description:	Extends SCM_MergeFieldGroup to create the Comments field found in most fax cover sheets.
*/

public class SCM_MF_Comments extends SCM_MergeFieldGroup {
	public SCM_MF_Comments() {
		SCM_MF_TextArea CommentField = new SCM_MF_TextArea();
        this.headerText = 'Comments';       
        this.key = 'Comments';
        this.isFieldGroup = true;
        this.subFields.add(CommentField);
        this.className = 'SCM_MF_Comments';
        
	}
}