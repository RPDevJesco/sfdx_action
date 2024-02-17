import { LightningElement, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import BINDER_SOURCE from '@salesforce/resourceUrl/binder';

export default class TestComponent extends LightningElement {
    @track items = ['Item 1', 'Item 2', 'Item 3'];

    get itemsJson() {
        return JSON.stringify(this.items);
    }

    renderedCallback() {
        if (this.binderLoaded) {
            return;
        }
        this.binderLoaded = true;

        loadScript(this, BINDER_SOURCE)
            .then(() => {
                console.log('Binder library loaded');
            })
            .catch(error => {
                console.error('Error loading the binder library:', error);
            });
    }
}