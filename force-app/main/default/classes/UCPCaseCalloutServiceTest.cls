/**
 * Created by POTERFI on 3/25/2022.
 */
@IsTest
public with sharing class UCPCaseCalloutServiceTest {

    @IsTest
    static void testUpsertCallout() {
        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());

        Test.startTest();
        HttpResponse res = UCPCaseCalloutService.sendUpsertCallout();
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        String expectedValue = '{"example":"test"}';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());
    }


    @IsTest
    static void testDeleteCallout() {

    }

}