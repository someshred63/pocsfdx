/**
 * @author Tech Mahindra
 * @date June 2023
 * @description This class is created to provide access to documents when GFRS user is applying 
 *              for a funding request of an existing organization
 */
public without sharing class GFRS_Ltng_OrgDocumentUtil {
    /**
     * @description This method provide document access to the user querying the document. 
     *              If the default document access is not there then it will create 
     *              a ContentDocumentLink to provide access.
     * @param documentId This holds the ContentDocumentId
     * @param userId This holds current user id
     * @return List<ContentDocumentLink>
     */
    public static List<ContentDocumentLink> getContentDocumentLinks(Id documentId, Id userId) {
        List<ContentDocumentLink> cdLinks = null;
        try {
            cdLinks = new List<ContentDocumentLink>();
            Boolean userLinkFound = false;
            for (ContentDocumentLink cdLink: [
                SELECT LinkedEntityId, ContentDocumentId FROM ContentDocumentLink 
                WHERE ContentDocumentId =: documentId
            ]) {
                if (cdLink.LinkedEntityId == userId) {
                    userLinkFound = true;
                }
                cdLinks.add(cdLink);
            }
            if (!userLinkFound) {
                ContentDocumentLink cdLink = new ContentDocumentLink();
                cdLink.ContentDocumentId = documentId;
                cdLink.LinkedEntityId = userId;
                cdLink.ShareType = 'I';
                cdLink.Visibility = 'AllUsers';
                insert cdLink;
                cdLinks.add(cdLink);
            }
        } catch(Exception ex) {
            System.debug(ex.getMessage() + ' | ' + ex.getStackTraceString());
        }
        return cdLinks;
    }
}