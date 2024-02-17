/**
 * Created by jglov on 2/2/2024.
 */

import { LightningElement, track, api } from 'lwc';

export default class DynamicLearningEngine extends LightningElement {
    @api textModuleText = '';
    @api currentModuleType = ''; // Default to an empty string or your initial module type
    @track showModule = false; // New state to control visibility of the content

    get isTextModule() {
        return this.currentModuleType === 'textModule' && this.showModule;
    }

    get isQuizModule() {
        return this.currentModuleType === 'quizModule' && this.showModule;
    }

    get isVideoModule() {
        return this.currentModuleType === 'videoModule' && this.showModule;
    }

    toggleModuleDisplay() {
        this.showModule = !this.showModule;
    }
}