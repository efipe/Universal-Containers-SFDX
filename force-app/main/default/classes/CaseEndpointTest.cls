/**
 * Created by POTERFI on 3/29/2022.
 */

@IsTest
private class CaseEndpointTest {

    @TestSetup
    public static void setupTest() {
        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Case newCase = new Case();
        newCase.External_Id__c = '12345';
        insert newCase;

    }

    @IsTest
    static void shouldUpsertCases() {
        Case testCase = [SELECT Id, External_Id__c FROM Case LIMIT 1];
        Case insertedCase = [SELECT Id, Subject, External_Id__c, Preferred_language__c, RecordType.DeveloperName, Status, Priority, Origin, Description, Comments, SuppliedName, SuppliedPhone, SuppliedEmail, Last_Change_Org_Id__c FROM Case WHERE Id = :testCase.Id LIMIT 1];
        CaseWrapper wrappedCase = new CaseWrapper(insertedCase);

        RestRequest request = new RestRequest();
        insertedCase.Subject = 'updated';
        String serializedCase = JSON.serialize(new List<CaseWrapper>{wrappedCase});
        request.requestBody = Blob.valueOf(serializedCase);
        RestContext.request = request;
        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        CaseEndpoint.upsertCases();
        Test.stopTest();

        Case upsertedCase = [SELECT Id FROM Case WHERE Id = :insertedCase.Id LIMIT 1];
        System.assertNotEquals(insertedCase, upsertedCase);
    }

    @IsTest
    static void shouldDeleteCases() {
        Case testCase = [SELECT Id, External_Id__c FROM Case LIMIT 1];

        RestRequest request = new RestRequest();
        request.addParameter('external_id', '12345');
        RestContext.request = request;

        RestResponse expectedResponse = new RestResponse();
        expectedResponse.statusCode = 200;
        RestContext.response = expectedResponse;

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        CaseEndpoint.deleteCases();
        Test.stopTest();

        Case caseAfterDelete = [SELECT Id, External_Id__c, IsDeleted FROM Case WHERE Id = :testCase.Id ALL ROWS];
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals(true, caseAfterDelete.IsDeleted);
    }

    @IsTest
    static void shouldReturn400WrongParameterProvidedOnDelete(){
        Case testCase = [SELECT Id, External_Id__c FROM Case LIMIT 1];

        RestRequest request = new RestRequest();
        request.addParameter('external_id', '');
        RestContext.request = request;

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        System.debug(RestContext.request);
        CaseEndpoint.deleteCases();
        Test.stopTest();

        RestResponse expectedResponse = new RestResponse();
        String respBody = 'Wrong parameter provided';
        expectedResponse.statusCode = 400;
        expectedResponse.responseBody = Blob.valueOf(respBody);
        RestContext.response = expectedResponse;

        Case caseAfterDelete = [SELECT Id, External_Id__c, IsDeleted FROM Case WHERE Id = :testCase.Id ALL ROWS];
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals(Blob.valueOf(respBody), RestContext.response.responseBody);
        System.assertEquals(false, caseAfterDelete.IsDeleted);
    }

    @IsTest
    static void shouldReturn400NoCaseFoundOnDelete(){
        Case testCase = [SELECT Id, External_Id__c FROM Case LIMIT 1];
        RestRequest request = new RestRequest();
        request.addParameter('external_id', '44');
        RestContext.request = request;

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        CaseEndpoint.deleteCases();
        Test.stopTest();

        RestResponse expectedResponse = new RestResponse();
        String respBody = 'Case with given id not found';
        expectedResponse.statusCode = 400;
        expectedResponse.responseBody = Blob.valueOf(respBody);
        RestContext.response = expectedResponse;

        Case caseAfterDelete = [SELECT Id, External_Id__c, IsDeleted FROM Case WHERE Id = :testCase.Id ALL ROWS];
        System.assertEquals(400, RestContext.response.statusCode);
        System.assertEquals(Blob.valueOf(respBody), RestContext.response.responseBody);
        System.assertEquals(false, caseAfterDelete.IsDeleted);
    }

}