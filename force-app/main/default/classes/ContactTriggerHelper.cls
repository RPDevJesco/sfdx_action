/**
 * Created by jglov on 8/18/2023.
 */

public with sharing class ContactTriggerHelper {
    public static void BeforeInsertValidateEmailAddress(List<Contact> newContacts, Map<Id, Contact> oldContactMap) {
        for(Contact newContact : newContacts) {
            Contact oldContact = oldContactMap.get(newContact.Id);
            if(oldContact != null && oldContact.Email != newContact.Email) {
                UTIL_Fields.ValidInfoType validationResult = UTIL_Fields.validateContactInfo(newContact.Email);

                if (validationResult == UTIL_Fields.ValidInfoType.EMAIL) {
                    // Input is a valid email, proceed with email logic
                }
            }
        }
    }

    public static void BeforeInsertValidatePhoneNumber(List<Contact> newContacts, Map<Id, Contact> oldContactMap) {
        for(Contact newContact : newContacts) {
            Contact oldContact = oldContactMap.get(newContact.Id);
            if(oldContact != null && oldContact.Phone != newContact.Phone) {
                UTIL_Fields.ValidInfoType validationResult = UTIL_Fields.validateContactInfo(newContact.Phone);

                if (validationResult == UTIL_Fields.ValidInfoType.PHONE) {
                    // Input is a valid email, proceed with email logic
                }
            }
        }
    }
}