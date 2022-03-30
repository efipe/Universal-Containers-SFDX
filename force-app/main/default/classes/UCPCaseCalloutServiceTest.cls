/**
 * Created by POTERFI on 3/25/2022.
 */
@IsTest
public with sharing class UCPCaseCalloutServiceTest {

    @TestSetup
    public static void setupTest() {
        Case firstCase = new Case();
        Case secondCase = new Case();
        firstCase.External_Id__c = '1';
        secondCase.External_Id__c = '2';
        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        insert new List<Case>{
                firstCase, secondCase
        };
    }

    @IsTest
    static void testSendUpsert() {
        Set<String> extIds = new Set<String>();
        for (Case c : [SELECT Id, External_Id__c FROM Case]){
            extIds.add(c.External_Id__c);
        }
        HTTPMockFactory responseOK = new HTTPMockFactory();
        HttpResponse expectedResponse = responseOK.respond(new HttpRequest());
        Test.setMock(HttpCalloutMock.class, responseOK);

        Test.startTest();
        HttpResponse response = UCPCaseCalloutService.sendUpsertCallout(extIds);
        Test.stopTest();

        System.assertEquals(expectedResponse.getStatus(), response.getStatus());
        System.assertEquals(expectedResponse.getStatusCode(), response.getStatusCode());
    }


    @IsTest
    static void testSendDelete() {
        Set<String> extIds = new Set<String>();
        for (Case c : [SELECT Id, External_Id__c FROM Case]){
            extIds.add(c.External_Id__c);
        }
        HTTPMockFactory responseOK = new HTTPMockFactory();
        HttpResponse expectedResponse = responseOK.respond(new HttpRequest());
        Test.setMock(HttpCalloutMock.class, responseOK);

        Test.startTest();
        HttpResponse response = UCPCaseCalloutService.sendDeleteCallout(extIds);
        Test.stopTest();

        System.assertEquals(expectedResponse.getStatus(), response.getStatus());
        System.assertEquals(expectedResponse.getStatusCode(), response.getStatusCode());
    }

    @IsTest
    static void shouldReturnJSONWithWrappedCases() {
        List<CaseWrapper> wrappedCases = new List<CaseWrapper>();
        List<Case> cases = [SELECT Id, Subject, External_Id__c, Preferred_language__c, RecordType.DeveloperName, Status, Priority, Origin, Description, Comments, SuppliedName, SuppliedPhone, SuppliedEmail, Last_Change_Org_Id__c FROM Case LIMIT 2];
        System.assertNotEquals(true, cases.isEmpty());
        for (Case processedCase : cases) {
            CaseWrapper wrapped = new CaseWrapper(processedCase);
            wrappedCases.add(wrapped);
        }
        Test.startTest();
        String result = UCPCaseCalloutService.wrapCasesAndBuildJson(cases);
        Test.stopTest();
        List<CaseWrapper> resultWrappedCases = (List<CaseWrapper>) JSON.deserialize(result, List<CaseWrapper>.class);
        System.assertEquals(cases.size(),resultWrappedCases.size());
    }

    @IsTest
    static void shouldBuildParameterForDelete() {
        Case firstCase = new Case();
        Case secondCase = new Case();
        firstCase.External_Id__c = '1';
        secondCase.External_Id__c = '2';
        List<Case> casesToBuildParameterFrom = new List<Case>();
        casesToBuildParameterFrom.add(firstCase);
        casesToBuildParameterFrom.add(secondCase);
        String desiredResult = '?external_id=1,2';

        Test.startTest();
        String parameterResult = UCPCaseCalloutService.buildEndpointParameterForDelete(casesToBuildParameterFrom);
        Test.stopTest();

        System.assertEquals(desiredResult, parameterResult);
    }

}