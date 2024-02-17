/**
 * Created by jglov on 2/2/2024.
 */

import { LightningElement, api } from 'lwc';

export default class TextModule extends LightningElement {
    @api content = 'Default text content for the TextModule component. Please provide content to display.';
}