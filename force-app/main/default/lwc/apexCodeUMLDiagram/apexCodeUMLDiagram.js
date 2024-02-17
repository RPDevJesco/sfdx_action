import { LightningElement, wire, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import GOJS_SOURCE from '@salesforce/resourceUrl/GoJS_Source';
const GOJS_SCRIPT = GOJS_SOURCE + '/goJS/release/go.js';
import getDocumentation from '@salesforce/apex/ApexDocumentationController.getDocumentation';

export default class ApexCodeUmlDiagram extends LightningElement {
    @track documentationData;
    goJsInitialized = false;

    @wire(getDocumentation)
    wiredDocumentation({ error, data }) {
        if (data) {
            this.documentationData = data;
            this.initializeDiagram();
        } else if (error) {
            console.error('Error fetching Apex documentation data', error);
        }
    }

    connectedCallback() {
        if (this.goJsInitialized) {
            return;
        }
        this.goJsInitialized = true;

        loadScript(this, GOJS_SCRIPT)
            .then(() => {
                if (this.documentationData) {
                    this.initializeDiagram();
                }
            })
            .catch(error => {
                console.error("Error loading GoJS library", error);
            });
    }

    initializeDiagram() {
        if (!this.documentationData || !window.go) return;

        const go = window.go;
        const $ = go.GraphObject.make;

        const myDiagram = $(go.Diagram, this.template.querySelector('.diagram-container'));

        // Node Template
        myDiagram.nodeTemplate =
            $(go.Node, "Auto",
                $(go.Shape, "Rectangle",
                    { fill: "lightyellow" },
                    new go.Binding("fill", "color")
                ),
                $(go.Panel, "Table",
                    { defaultRowSeparatorStroke: "black" },
                    $(go.TextBlock,
                        { row: 0, margin: 5, alignment: go.Spot.Center },
                        new go.Binding("text", "name")
                    ),
                    $(go.TextBlock,
                        { row: 2, margin: 5, alignment: go.Spot.Left, wrap: go.TextBlock.WrapFit },
                        new go.Binding("text", "methods", methods => methods.join('\n'))
                    )
                )
            );

        if (this.documentationData) {
            let groupedData = this.groupByParentClass(this.documentationData);

            myDiagram.model = new go.GraphLinksModel({
                copiesArrays: true,
                copiesArrayObjects: true,
                linkCategoryProperty: "relationship",
                nodeDataArray: groupedData,
                linkDataArray: [] // Adjust this if you have relationships
            });
        }
    }

    groupByParentClass(data) {
        const grouped = {};

        data.forEach(doc => {
            if (!grouped[doc.ParentClass__c]) {
                grouped[doc.ParentClass__c] = {
                    key: doc.Id,
                    name: doc.ParentClass__c,
                    properties: [doc.Parameters__c], // You might also want to handle properties similarly to methods if multiple properties are expected.
                    methods: [doc.MethodSignature__c + ' ' + doc.MethodName__c + (doc.Parameters__c ? doc.Parameters__c  : '')]
                };
            } else {
                grouped[doc.ParentClass__c].methods.push(doc.MethodSignature__c + ' ' + doc.MethodName__c + (doc.Parameters__c ? doc.Parameters__c  : ''));
            }
        });

        return Object.values(grouped);
    }
}