/**
 * Created by POTERFI on 3/17/2022.
 */

public with sharing class CaseUtilities {
    public static final String RT_INVOICE_REQUEST = 'Invoice_request';
    public static final String RT_INVOICE_CORRECTION = 'Invoice_Correction';
    public static final String RT_CHANGE_REQUEST = 'Change_request';
    public static final String RT_COMPLAINT_DELIVERY = 'Complaint_Delivery';
    public static final String RT_COMPLAINT_MISSING_GOODS = 'Complaint_Missing_or_damaged_goods';
    public static final String RT_SUPPORT_QUESTION = 'Support_question';
    public static final String RT_SUPPORT_OTHER = 'Support_other';
    public static final String RT_COMPLAINT_OTHER = 'Complaint_other';

    private static Map<String, Id> recordTypeByDevName;

    public static Id getRecordTypeIdByDevName(String rtDevName) {
        if( recordTypeByDevName == null) {
            recordTypeByDevName = new Map<String, Id>();
            for (RecordTypeInfo rtInfo: Case.getSObjectType().getDescribe().getRecordTypeInfos()){
                recordTypeByDevName.put(rtInfo.getDeveloperName(), rtInfo.getRecordTypeId());
            }
        }
        return recordTypeByDevName.get(rtDevName);
    }
}