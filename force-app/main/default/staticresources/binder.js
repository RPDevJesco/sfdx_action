class ForEachElement extends HTMLElement {
    constructor() {
        super();
        this.attachShadow({ mode: 'open' });
    }

    connectedCallback() {
        // Ensure the component is fully defined, including its children
        if (document.readyState === "loading") {  // Loading hasn't finished yet
            document.addEventListener("DOMContentLoaded", () => this.render());
        } else {  // `DOMContentLoaded` has already fired
            this.render();
        }
    }

    render() {
        const items = JSON.parse(this.getAttribute('items'));
        // Access the template from the light DOM
        const templateElement = this.querySelector('template');
        if (templateElement) {
            const templateContent = templateElement.content;
            items.forEach(item => {
                const instance = document.importNode(templateContent, true);

                // Perform replacements in the cloned nodes
                this.replaceItemTokens(instance, item);

                this.shadowRoot.appendChild(instance);
            });
        }
    }

    replaceItemTokens(instance, item) {
        // Assuming simple direct text replacement for demonstration
        instance.querySelectorAll('*').forEach(node => {
            if (node.childNodes.length === 1 && node.childNodes[0].nodeType === Node.TEXT_NODE) {
                node.textContent = node.textContent.replace(/\{\{item\}\}/g, item);
            }
        });
    }

}

customElements.define('foreach-element', ForEachElement);
