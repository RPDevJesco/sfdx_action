import { LightningElement, wire, track } from 'lwc';
import getDocumentation from '@salesforce/apex/ApexDocumentationController.getDocumentation';

const COLUMNS = [
    { label: 'Class Name', fieldName: 'ParentClass__c' },
    { label: 'Properties', fieldName: 'PropertyName__c' },
    { label: 'Method Name', fieldName: 'MethodName__c' },
    { label: 'Method Signature', fieldName: 'MethodSignature__c' },
    { label: 'Parameters', fieldName: 'Parameters__c' },
    { label: 'Param Desc', fieldName: 'Description__c' },
    { label: 'Fields Used', fieldName: 'FieldReference__c' },
    { label: 'Return Value', fieldName: 'Return__c' }
];

export default class ApexCodeDocumentation extends LightningElement {
    @track columns = COLUMNS;
    @track documentationData;
    isLoading = true;

    @wire(getDocumentation)
    wiredDocumentation({ error, data }) {
        if (data) {
            this.documentationData = data;
            this.isLoading = false;
        } else if (error) {
            console.error("Error fetching Apex code documentation: ", error);
            this.isLoading = false;
        }
    }
}