@RestResource(UrlMapping='/iPhoneSearchUsers/*')
global with sharing class iPhone_UserSearch {

    @HttpPost
    global static iPhone_Commons_gne.RestResponse processRequest(SearchRequest request) {
        return iPhone_Commons_gne.buildResponse(
                new UserResponseBuilder(),
                request
        );
    }

    class UserResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {

        public iPhone_Commons_gne.RestResponse build(Object args) {
            SearchRequest sr = (SearchRequest) args;
            GNE_SFA2_User_Solr_DAO.SolrServiceResponse response = new GNE_SFA2_User_Solr_DAO().searchUsers(sr.searchParams, sr.paginationData, sr.pageSize);
            return new SearchResponse(new List<GNE_SFA2_User_Solr_DAO.UserInfo>(response.getUsers()), response.getPaginationResponse(), sr.pageSize);
        }
    }

    private class SearchResponse extends iPhone_Commons_gne.RestResponse {
        private List<GNE_SFA2_User_Solr_DAO.UserInfo> users;
        public GNE_SFA2_SBC_DAO.PaginationDataWrapper paginationData;

        public SearchResponse(List<GNE_SFA2_User_Solr_DAO.UserInfo> users, GNE_SFA2_SBC_DAO.PaginationResponse paginationResponse, Integer pageSize) {
            this.users = users;
            this.paginationData = new GNE_SFA2_SBC_DAO.PaginationDataWrapper(paginationResponse, pageSize);
        }

    }

    global class SearchRequest implements iPhone_Commons_gne.BaseArgs {
        public String unixId;
        public GNE_SFA2_User_Solr_DAO.SearchParams searchParams;
        public GNE_SFA2_SBC_DAO.PaginationDataWrapper paginationData;
        public Integer pageSize;
        public Boolean searchMore;
        public String tid;

        public String getIPhoneRequestId() {
            return tid;
        }
    }
}