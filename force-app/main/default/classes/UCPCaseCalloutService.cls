public with sharing class UCPCaseCalloutService {

    static final String PAULINAS_ORG_ENDPOINT = 'callout:Paulinas_Org/services/apexrest/cases/';

    static Map<Id, String> IdToExternalRecordTypeMap = new Map<Id, String>{
            CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_INVOICE_REQUEST) => 'Invoice_Request',
            CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_INVOICE_CORRECTION) => 'Invoice_Correction',
            CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_CHANGE_REQUEST) => 'Change_request',
            CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_COMPLAINT_DELIVERY) => 'Delivery_Complaint',
            CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_COMPLAINT_MISSING_GOODS) => 'Missing_Damaged_Goods',
            CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_SUPPORT_QUESTION) => 'Question',
            CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_SUPPORT_OTHER) => 'Other',
            CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_COMPLAINT_OTHER) => 'Other'
    };

    public static void sendUpsertCallout(List<Case> casesData) {
        List<CaseWrapper> wrappedCasesToSend = new List<CaseWrapper>();
        HttpRequest request = new HttpRequest();
        Http http = new Http();
        request.setEndpoint(PAULINAS_ORG_ENDPOINT);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setBody(wrapCasesAndBuildJson(casesData));
        HTTPResponse response = http.send(request);
        System.debug(response.getBody());
    }

    public static void sendDeleteCallout(List<Case> casesReceivedToDelete) {
        HttpRequest request = new HttpRequest();
        Http http = new Http();
        request.setMethod('DELETE');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.setEndpoint(PAULINAS_ORG_ENDPOINT + buildEndpointParameterForDelete(casesReceivedToDelete));
        HttpResponse response = http.send(request);
        System.debug(response.getBody());
    }

    public static String wrapCasesAndBuildJson(List<Case> casesData) {
        List<CaseWrapper> wrappedCasesToSend = new List<CaseWrapper>();
        for (Case processedCase : casesData) {
            if (processedCase.Last_Change_Org_Id__c == 'PAULINA') {
                return null;
            } else {
                CaseWrapper caseWrapper = new CaseWrapper(processedCase);
                caseWrapper.record_type = IdToExternalRecordTypeMap.get(processedCase.RecordType.Id);
                wrappedCasesToSend.add(caseWrapper);
            }
        }
        String jsonSerialized = JSON.serialize(wrappedCasesToSend);
        return jsonSerialized;
    }

    public static String buildEndpointParameterForDelete(List<Case> casesReceivedToDelete) {
        List<String> externalIdList = new List<String>();
        for (Case processedCase : casesReceivedToDelete) {
            externalIdList.add(processedCase.External_Id__c);
        }
        String parameterBuilt = new RestUtilities.UrlParameterBuilder().addParam(PAULINAS_ORG_ENDPOINT, String.join(externalIdList, ',')).build();
        return parameterBuilt;
    }
}