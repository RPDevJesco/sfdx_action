/**
 * Created by jglov on 2/2/2024.
 */

import { LightningElement, api } from 'lwc';

export default class VideoModule extends LightningElement {
    @api videoUrl;

    renderedCallback() {
        this.createVideoElement();
    }

    createVideoElement() {
        // Ensuring we only insert the video element once
        const container = this.template.querySelector('.video-container');
        if (!container.hasChildNodes()) { // Check if the video element already exists
            const video = document.createElement('video');
            video.setAttribute('controls', '');

            const source = document.createElement('source');
            source.setAttribute('src', this.videoUrl);
            source.setAttribute('type', 'video/mp4');

            video.appendChild(source);
            container.appendChild(video);
        }
    }
}