import { LightningElement, api, track } from 'lwc';
import getBoardColumns from '@salesforce/apex/AzureConnection.getBoardColumns';
import getDetailedWorkItems from '@salesforce/apex/AzureConnection.getDetailedWorkItems';
import updateWorkItemState from '@salesforce/apex/AzureConnection.updateWorkItemState';
import { loadScript } from 'lightning/platformResourceLoader';
import GOJS_SOURCE from '@salesforce/resourceUrl/GoJS_Source';
const GOJS_SCRIPT = GOJS_SOURCE + '/goJS/release/go.js';
// There are only three note colors by default, blue, red, and yellow but you could add more here:
const noteColors = ['#009CCC', '#CC293D', '#FFD700'];
export default class AzureKanbanBoard extends LightningElement {
    @api OrganizationName;
    @api ProjectName;
    @api UserName;
    @api PersonalAccessToken;

    @track textareaValue = {};

    textareaValueObject = {
        class: "go.GraphLinksModel",
        nodeDataArray: [],
        linkDataArray: []
    };

    azureKanbanBoardHelp = 'The Azure Kanban Board allows for you to update Microsoft Azure Dev Ops tasks. Update here and it will update it on the Microsoft site for you. Additionally,' +
        'the kanban board will automatically show all new tasks that are assigned to you.';

    azureKanbanBoardHelpVideo = 'https://www.youtube.com/watch?v=dn7SB0E1svY';
    connectedCallback() {
        loadScript(this, GOJS_SCRIPT)
            .then(() => {
                console.log('GoJS library loaded');
                getBoardColumns({
                    setOrganizationName: this.OrganizationName,
                    setProjectName: this.ProjectName,
                    setUserName: this.UserName,
                    setPersonalAccessToken: this.PersonalAccessToken
                })
                    .then(result => {
                        console.log(result);
                        this.textareaValueObject.nodeDataArray = JSON.parse(result);
                    });
                getDetailedWorkItems({
                    setOrganizationName: this.OrganizationName,
                    setProjectName: this.ProjectName,
                    setUserName: this.UserName,
                    setPersonalAccessToken: this.PersonalAccessToken
                })
                    .then(result => {
                        this.workItems = JSON.parse(JSON.stringify(result));
                        this.workItems.forEach(item => item.showAddComment = false);

                        // Process and append work items to nodeDataArray
                        this.workItems.forEach(workItem => {
                            // Transform your work item into the format you want, this is just an example
                            // "key":1, "text":"text for oneA", "group":"Problems", "color":"0", "loc":"12 55.52284749830794"
                            const transformedWorkItem = {
                                key: workItem.Id, // or any unique property of workItem
                                text: workItem.Title, // or any other property
                                group: this.findNodeByState(workItem.State),
                                color: "0",
                                loc: this.getLocationForState(workItem.State)
                            };
                            // Push the transformed work item to nodeDataArray
                            this.textareaValueObject.nodeDataArray.push(transformedWorkItem);
                        });
                        this.poolLayoutTest();
                    })
            })
            .catch(error => {
                console.log("Error loading library:", error.message || error);
            });
    }

    findNodeByState(state) {
        let node = this.textareaValueObject.nodeDataArray.find(node => node.text === state && node.isGroup === true);
        return node ? node.key : null;
    }

    getLocationForState(state) {
        // Find the base location for the provided state
        const node = this.textareaValueObject.nodeDataArray.find(node => node.text === state && node.isGroup === true);
        if (!node) return "0 0"; // Default location if not found

        // Parse the base location to adjust the y-coordinate
        const [x, y] = node.loc.split(" ").map(Number);

        // Shift the y-coordinate down. Adjust the value `50` as per your requirement.
        const newY = y + 50;

        return `${x} ${newY}`;
    }

    highlightGroup(myDiagram, grp, show) {
        if (show) {
            const part = myDiagram.toolManager.draggingTool.currentPart;
            if (part.containingGroup !== grp) {
                grp.isHighlighted = true;
                return;
            }
        }
        grp.isHighlighted = false;
    }

    setNodeTemplate($, go, myDiagram, getNoteColor, noteColors) {
        myDiagram.nodeTemplate =
            $(go.Node, "Horizontal",
                new go.Binding("location", "loc", go.Point.parse).makeTwoWay(go.Point.stringify),
                $(go.Shape, "Rectangle", {
                        fill: '#009CCC', strokeWidth: 1, stroke: '#009CCC',
                        width: 6, stretch: go.GraphObject.Vertical, alignment: go.Spot.Left,
                        // if a user clicks the colored portion of a node, cycle through colors
                        click: (e, obj) => {
                            myDiagram.startTransaction("Update node color");
                            let newColor = parseInt(obj.part.data.color) + 1;
                            if (newColor > noteColors.length - 1) newColor = 0;
                            myDiagram.model.setDataProperty(obj.part.data, "color", newColor);
                            myDiagram.commitTransaction("Update node color");
                        }
                    },
                    new go.Binding("fill", "color", getNoteColor),
                    new go.Binding("stroke", "color", getNoteColor)
                ),
                $(go.Panel, "Auto",
                    $(go.Shape, "Rectangle", { fill: "white", stroke: '#CCCCCC' }),
                    $(go.Panel, "Table",
                        { width: 130, minSize: new go.Size(NaN, 50) },
                        $(go.TextBlock,
                            {
                                name: 'TEXT',
                                margin: 6, font: '11px Lato, sans-serif', editable: true,
                                stroke: "#000", maxSize: new go.Size(130, NaN),
                                alignment: go.Spot.TopLeft
                            },
                            new go.Binding("text", "text").makeTwoWay())
                    )
                )
            );
    }

    // Function to update the work item state
    updateWorkItemStateHandler(organizationName, projectName, userName, personalAccessToken, workItemId, newState) {
        return updateWorkItemState({
            setOrganizationName: organizationName,
            setProjectName: projectName,
            setUserName: userName,
            setPersonalAccessToken: personalAccessToken,
            workItemId: workItemId,
            newState: newState
        });
    }

    setGroupTemplate($, go, myDiagram) {
        myDiagram.groupTemplate =
            $(go.Group, "Vertical",
                {
                    selectable: false,
                    selectionObjectName: "SHAPE", // even though its not selectable, this is used in the layout
                    layerName: "Background",  // all lanes are always behind all nodes and links
                    layout: $(go.GridLayout,  // automatically lay out the lane's subgraph
                        {
                            wrappingColumn: 1,
                            cellSize: new go.Size(1, 1),
                            spacing: new go.Size(5, 5),
                            alignment: go.GridLayout.Position,
                            comparer: (a, b) => {  // can re-order tasks within a lane
                                const ay = a.location.y;
                                const by = b.location.y;
                                if (isNaN(ay) || isNaN(by)) return 0;
                                if (ay < by) return -1;
                                if (ay > by) return 1;
                                return 0;
                            }
                        }),
                    computesBoundsIncludingLocation: true,
                    computesBoundsAfterDrag: true,  // needed to prevent recomputing Group.placeholder bounds too soon
                    handlesDragDropForMembers: true,  // don't need to define handlers on member Nodes and Links
                    mouseDragEnter: (e, grp, prev) => {
                        this.highlightGroup(myDiagram, grp, true);
                    },
                    mouseDragLeave: (e, grp, next) => {
                        this.highlightGroup(myDiagram, grp, false);
                    },
                    mouseDrop: (e, grp) => {
                        if (e.diagram.selection.all(n => !(n instanceof go.Group))) {
                            const ok = grp.addMembers(grp.diagram.selection, true);
                            if (!ok) {
                                grp.diagram.currentTool.doCancel();
                            } else {
                                //If node was successfully added to the group, update its state
                                const selectedNode = e.diagram.selection.first();

                                this.updateWorkItemStateHandler(
                                    this.OrganizationName,
                                    this.ProjectName,
                                    this.UserName,
                                    this.PersonalAccessToken,
                                    selectedNode.data.key,
                                    selectedNode.containingGroup.key
                                )
                                    .then(() => {
                                        console.log('State updated successfully');
                                        // Reload or refresh the work items or just update the specific work item's state in the UI.
                                    })
                                    .catch(error => {
                                        console.log('Error updating state', error);
                                    });
                            }
                        } else {
                            grp.diagram.currentTool.doCancel();
                        }
                    },
                    subGraphExpandedChanged: grp => {
                        const shp = grp.selectionObject;
                        if (grp.diagram.undoManager.isUndoingRedoing) return;
                        if (grp.isSubGraphExpanded) {
                            shp.width = grp.data.savedBreadth;
                        } else {  // remember the original width
                            if (!isNaN(shp.width)) grp.diagram.model.set(grp.data, "savedBreadth", shp.width);
                            shp.width = NaN;
                        }
                    }
                },
                new go.Binding("location", "loc", go.Point.parse).makeTwoWay(go.Point.stringify),
                new go.Binding("isSubGraphExpanded", "expanded").makeTwoWay(),
                // the lane header consisting of a TextBlock and an expander button
                $(go.Panel, "Horizontal",
                    { name: "HEADER", alignment: go.Spot.Left },
                    $("SubGraphExpanderButton", { margin: 5 }),  // this remains always visible
                    $(go.TextBlock,  // the lane label
                        { font: "15px Lato, sans-serif", editable: true, margin: new go.Margin(2, 0, 0, 0) },
                        // this is hidden when the swimlane is collapsed
                        new go.Binding("visible", "isSubGraphExpanded").ofObject(),
                        new go.Binding("text").makeTwoWay())
                ),  // end Horizontal Panel
                $(go.Panel, "Auto",  // the lane consisting of a background Shape and a Placeholder representing the subgraph
                    $(go.Shape, "Rectangle",  // this is the resized object
                        { name: "SHAPE", fill: "#F1F1F1", stroke: null, strokeWidth: 4 },  // strokeWidth controls space between lanes
                        new go.Binding("fill", "isHighlighted", h => h ? "#D6D6D6" : "#F1F1F1").ofObject(),
                        new go.Binding("desiredSize", "size", go.Size.parse).makeTwoWay(go.Size.stringify)),
                    $(go.Placeholder,
                        { padding: 12, alignment: go.Spot.TopLeft }),
                    $(go.TextBlock,  // this TextBlock is only seen when the swimlane is collapsed
                        {
                            name: "LABEL", font: "15px Lato, sans-serif", editable: true,
                            angle: 90, alignment: go.Spot.TopLeft, margin: new go.Margin(4, 0, 0, 2)
                        },
                        new go.Binding("visible", "isSubGraphExpanded", e => !e).ofObject(),
                        new go.Binding("text").makeTwoWay())
                )  // end Auto Panel
            );  // end Group
    }

    setDraggingTool(go, myDiagram) {
        // Customize the dragging tool:
        // When dragging a node set its opacity to 0.6 and move it to be in front of other nodes
        myDiagram.toolManager.draggingTool.doActivate = function() {
            go.DraggingTool.prototype.doActivate.call(this);
            this.currentPart.opacity = 0.6;
            this.currentPart.layerName = "Foreground";
        }
        myDiagram.toolManager.draggingTool.doDeactivate = function() {
            this.currentPart.opacity = 1;
            this.currentPart.layerName = "";
            go.DraggingTool.prototype.doDeactivate.call(this);
        }
    }

    getNoteColor(num) {
        return noteColors[Math.min(num, noteColors.length - 1)];
    }

    poolLayoutTest() {
        if (!window.go) return;
        const go = window.go;
        const $ = go.GraphObject.make;
        let itemId = this.currentWorkItemId;
        let itemSelected = this.selectedItem;
        // define a custom grid layout that makes sure the length of each lane is the same
        // and that each lane is broad enough to hold its subgraph
        class PoolLayout extends go.GridLayout {
            constructor() {
                super();
                this.MINLENGTH = 200;  // this controls the minimum length of any swimlane
                this.MINBREADTH = 100;  // this controls the minimum breadth of any non-collapsed swimlane
                this.cellSize = new go.Size(1, 1);
                this.wrappingColumn = Infinity;
                this.wrappingWidth = Infinity;
                this.spacing = new go.Size(0, 0);
                this.alignment = go.GridLayout.Position;
            }

            doLayout(coll) {
                const diagram = this.diagram;
                if (diagram === null) return;
                diagram.startTransaction("PoolLayout");
                // make sure all of the Group Shapes are big enough
                const minlen = this.computeMinPoolLength();
                diagram.findTopLevelGroups().each(lane => {
                    if (!(lane instanceof go.Group)) return;
                    const shape = lane.selectionObject;
                    if (shape !== null) {  // change the desiredSize to be big enough in both directions
                        const sz = this.computeLaneSize(lane);
                        shape.width = (!isNaN(shape.width)) ? Math.max(shape.width, sz.width) : sz.width;
                        // if you want the height of all of the lanes to shrink as the maximum needed height decreases:
                        shape.height = minlen;
                        // if you want the height of all of the lanes to remain at the maximum height ever needed:
                        //shape.height = (isNaN(shape.height) ? minlen : Math.max(shape.height, minlen));
                        const cell = lane.resizeCellSize;
                        if (!isNaN(shape.width) && !isNaN(cell.width) && cell.width > 0) shape.width = Math.ceil(shape.width / cell.width) * cell.width;
                        if (!isNaN(shape.height) && !isNaN(cell.height) && cell.height > 0) shape.height = Math.ceil(shape.height / cell.height) * cell.height;
                    }
                });
                // now do all of the usual stuff, according to whatever properties have been set on this GridLayout
                super.doLayout(coll);
                diagram.commitTransaction("PoolLayout");
            };

            // compute the minimum length of the whole diagram needed to hold all of the Lane Groups
            computeMinPoolLength() {
                let len = this.MINLENGTH;
                myDiagram.findTopLevelGroups().each(lane => {
                    const holder = lane.placeholder;
                    if (holder !== null) {
                        const sz = holder.actualBounds;
                        len = Math.max(len, sz.height);
                    }
                });
                return len;
            }

            // compute the minimum size for a particular Lane Group
            computeLaneSize(lane) {
                // assert(lane instanceof go.Group);
                const sz = new go.Size(lane.isSubGraphExpanded ? this.MINBREADTH : 1, this.MINLENGTH);
                if (lane.isSubGraphExpanded) {
                    const holder = lane.placeholder;
                    if (holder !== null) {
                        const hsz = holder.actualBounds;
                        sz.width = Math.max(sz.width, hsz.width);
                    }
                }
                // minimum breadth needs to be big enough to hold the header
                const hdr = lane.findObject("HEADER");
                if (hdr !== null) sz.width = Math.max(sz.width, hdr.actualBounds.width);
                return sz;
            }
        }
        // end PoolLayout class

        const myDiagram =
            new go.Diagram(this.template.querySelector('.diagram-container'),
                {
                    // make sure the top-left corner of the viewport is occupied
                    contentAlignment: go.Spot.Center,
                    // use a simple layout to stack the top-level Groups next to each other
                    layout: $(PoolLayout),
                    // disallow nodes to be dragged to the diagram's background
                    mouseDrop: e => {
                        e.diagram.currentTool.doCancel();
                    },
                    // a clipboard copied node is pasted into the original node's group (i.e. lane).
                    "commandHandler.copiesGroupKey": true,
                    // automatically re-layout the swim lanes after dragging the selection
                    "SelectionMoved": relayoutDiagram,  // this DiagramEvent listener is
                    "SelectionCopied": relayoutDiagram, // defined above
                    "undoManager.isEnabled": true,
                    // allow TextEditingTool to start without selecting first
                    "textEditingTool.starting": go.TextEditingTool.SingleClick
                });

        this.setDraggingTool(go, myDiagram);

        // this is called after nodes have been moved
        function relayoutDiagram() {
            let selectedNode = myDiagram.selection.first();
            if (selectedNode instanceof go.Node) {
                console.log('Moved Node ID:', selectedNode.data.key);
                console.log('Moved Node Data:', JSON.stringify(selectedNode.data));
                console.log('Node is in group:', selectedNode.containingGroup ? selectedNode.containingGroup.key : 'null');
            }
        }

        this.setNodeTemplate($, go, myDiagram, this.getNoteColor(), noteColors);

        this.setGroupTemplate($, go, myDiagram);

        myDiagram.addDiagramListener("ChangedSelection", function(e) {
            let node = e.diagram.selection.first();  // get the first selected node
            if (node instanceof go.Node) {
                itemId = node.data.key;  // assuming the node's key is the ID
                itemSelected = JSON.stringify(node.data);  // the full data object
            } else {
                itemId = null;
                itemSelected = null;
            }
        });

        myDiagram.model = go.Model.fromJson(this.textareaValueObject);
        this.textareaValue = JSON.stringify(this.textareaValueObject);
    }
}