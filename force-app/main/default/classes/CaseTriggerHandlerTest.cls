@IsTest
public with sharing class CaseTriggerHandlerTest {

    @IsTest
    private static void shouldInitializeCaseDataOnInsert() {
        Case newCase = new Case();

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        insert newCase;
        Test.stopTest();

        Case caseAfterInsert = [SELECT Id, Last_status_change_date__c, Last_Change_Org_Id__c, External_Id__c, Preferred_language__c, Status FROM Case WHERE Id = :newCase.Id LIMIT 1];
        System.assertNotEquals(null, caseAfterInsert.Last_status_change_date__c);
        System.assertEquals(Date.today(), caseAfterInsert.Last_status_change_date__c.date());
        System.assertEquals(CaseTriggerHelper.MY_LAST_CHANGE_ORG_NAME, caseAfterInsert.Last_Change_Org_Id__c);
        System.assertNotEquals(null, caseAfterInsert.External_Id__c);
        System.assertNotEquals(null, caseAfterInsert.Preferred_language__c);
        System.assertNotEquals(null, caseAfterInsert.Status);
    }

    @isTest
    private static void shouldAssignBookingToCaseBeforeInsert() {
        Schedule_booking__c booking = new Schedule_booking__c();
        // Nowy booking z wygenerowana nazwa
        // SOQL bookingu
        // stworzyc Case z tym polem
        // insert Case w start/Stop
        // SOQL Danych z Case'a
        // assert id bookingu z case'a do Id bookingu stworzonego
    }

    @isTest
    private static void shouldNotAssignBookingToCaseBeforeInsertNoValue() {
        // Nowy booking z wygenerowana nazwa
        // SOQL bookingu
        // stworzyc Case BEZ TEGO pola
        // insert Case w start/Stop
        // SOQL Danych z Case'a
        // assertNotEquals / assertEquals | null id bookingu z case'a do Id bookingu stworzonego
    }

    @IsTest
    private static void shouldNotAssignBookingToCaseBeforeInsertNoBooking() {
        // Stworzyc booking
        // stworzyc Case z nazwa nieistniejacego bookingu
        // insert Case w start/Stop
        // SOQL Danych z Case'a
        // assert id bookingu z case'a do Id bookingu stworzonego && id bookingu na casie != id bookingu na lookupie w casie
    }

    /*
    !!!!!!!! OPCJONALNIE !!!!!!!
    test dla kilku Case'ow naraz, wylać może bulkBefore
     */


}