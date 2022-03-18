public with sharing class UCPCaseCalloutService {
    // TODO Add private helper methods to create / build valid parameters for each method

    static Map<Id,String> IdToExternalRecordTypeMap = new Map<Id, String>{
        CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_INVOICE_REQUEST) => 'Invoice_Request',
        CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_INVOICE_CORRECTION) => 'Invoice_Correction',
        CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_CHANGE_REQUEST) => 'Change_request',
        CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_COMPLAINT_DELIVERY)=> 'Delivery_Complaint',
        CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_COMPLAINT_MISSING_GOODS) => 'Missing_Damaged_Goods',
        CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_SUPPORT_QUESTION) => 'Question',
        CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_SUPPORT_OTHER) => 'Other',
        CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_COMPLAINT_OTHER) => 'Other'
    };

    public static void sendUpsertCallout(List<Case> casesData){
        // TODO Write HTTP request to be sent to paulina's org using Post method and CaseRESTEndpoint from Paulina's Org
        List<CaseWrapper> wrappedCasesToSend = new List<CaseWrapper>();
        HttpRequest request = new HttpRequest();
        Http http = new Http();
        request.setEndpoint('callout:Paulinas_Org/services/apexrest/Cases');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        for(Case processedCase: casesData){
            CaseWrapper caseWrapper = new CaseWrapper(processedCase);
            wrappedCasesToSend.add(caseWrapper);
            caseWrapper.record_type = IdToExternalRecordTypeMap.get(processedCase.RecordType.DeveloperName);
        }
        String JsonSerialized = JSON.serialize(wrappedCasesToSend);
        request.setBody(JsonSerialized);
        System.debug(request.getBody());
        HTTPResponse response = http.send(request);
        System.debug(response.getBody());
    }

    public static void sendDeleteCallout(List<Case> caseIdsFromParameter){
        // TODO Write HTTP request to be sent to paulina's org using delete method and CaseRESTEndpoint from Paulina's Org
    }

}