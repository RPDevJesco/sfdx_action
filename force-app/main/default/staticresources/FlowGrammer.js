const generateFlowGrammer = {

    figureGenerator(go) {
        // two custom figures, for "For Each" loops
        go.Shape.defineFigureGenerator("ForEach", (shape, w, h) => {
            var param1 = shape ? shape.parameter1 : NaN; // length of triangular area in direction that it is pointing
            if (isNaN(param1)) param1 = 10;
            var d = Math.min(h / 2, param1);
            var geo = new go.Geometry();
            var fig = new go.PathFigure(w, h - d, true);
            geo.add(fig);
            fig.add(new go.PathSegment(go.PathSegment.Line, w / 2, h));
            fig.add(new go.PathSegment(go.PathSegment.Line, 0, h - d));
            fig.add(new go.PathSegment(go.PathSegment.Line, 0, 0));
            fig.add(new go.PathSegment(go.PathSegment.Line, w, 0).close());
            geo.spot1 = go.Spot.TopLeft;
            geo.spot2 = new go.Spot(1, 1, 0, Math.min(-d + 2, 0));
            return geo;
        });

        go.Shape.defineFigureGenerator("EndForEach", (shape, w, h) => {
            var param1 = shape ? shape.parameter1 : NaN; // length of triangular area in direction that it is pointing
            if (isNaN(param1)) param1 = 10;
            var d = Math.min(h / 2, param1);
            var geo = new go.Geometry();
            var fig = new go.PathFigure(w, d, true);
            geo.add(fig);
            fig.add(new go.PathSegment(go.PathSegment.Line, w, h));
            fig.add(new go.PathSegment(go.PathSegment.Line, 0, h));
            fig.add(new go.PathSegment(go.PathSegment.Line, 0, d));
            fig.add(new go.PathSegment(go.PathSegment.Line, w / 2, 0).close());
            geo.spot1 = new go.Spot(0, 0, 0, Math.min(d, 0));
            geo.spot2 = go.Spot.BottomRight;
            return geo;
        });
    },

    init(go, $, myDiagram, myPalette, myOverview) {
        // initialize main Diagram
        myDiagram =
            new go.Diagram("myDiagramDiv",
                {
                    allowMove: false,
                    allowCopy: false,
                    "SelectionDeleting": e => {  // before a delete happens
                        // handle deletions by excising the node and reconnecting the link where the node had been
                        new go.List(e.diagram.selection).each(part => deletingNode(part));
                    },
                    layout: $(ParallelLayout, { angle: 90, layerSpacing: 21, nodeSpacing: 30 }),
                    "ExternalObjectsDropped": e => {  // handle drops from the Palette
                        var newnode = e.diagram.selection.first();
                        if (!newnode) return;
                        if (!(newnode instanceof go.Group) && newnode.linksConnected.count === 0) {
                            // when the selection is dropped but not hooked up to the rest of the graph, delete it
                            e.diagram.removeParts(e.diagram.selection, false);
                        } else {
                            e.diagram.commandHandler.scrollToPart(newnode);
                        }
                    },
                    "undoManager.isEnabled": true
                });

        // dragged nodes are translucent so that the user can see highlighting of links and nodes
        myDiagram.findLayer("Tool").opacity = 0.5;

        this.figureGenerator(go);

        // some common styles for most of the node templates
        function nodeStyle() {
            return {
                deletable: false,
                locationSpot: go.Spot.Center,
                mouseDragEnter: (e, node) => {
                    var sh = node.findObject("SHAPE");
                    if (sh) sh.fill = "lime";
                },
                mouseDragLeave: (e, node) => {
                    var sh = node.findObject("SHAPE");
                    if (sh) sh.fill = "white";
                },
                mouseDrop: dropOntoNode
            };
        }

        function shapeStyle() {
            return { name: "SHAPE", fill: "white" };
        }

        function textStyle() {
            return [
                { name: "TEXTBLOCK", textAlign: "center", editable: true },
                new go.Binding("text").makeTwoWay()
            ];
        }

        // define the Node templates
        myDiagram.nodeTemplate =  // regular action steps
            $(go.Node, "Auto", nodeStyle(),
                { deletable: true },  // override nodeStyle()
                { minSize: new go.Size(10, 20) },
                $(go.Shape, shapeStyle()),
                $(go.TextBlock, textStyle(),
                    { margin: 4 })
            );

        myDiagram.nodeTemplateMap.add("Start",
            $(go.Node, "Auto", nodeStyle(),
                { desiredSize: new go.Size(32, 32) },
                $(go.Shape, "Circle", shapeStyle()),
                $(go.TextBlock, textStyle(), "Start")
            ));

        myDiagram.nodeTemplateMap.add("End",
            $(go.Node, "Auto", nodeStyle(),
                { desiredSize: new go.Size(32, 32) },
                $(go.Shape, "Circle", shapeStyle()),
                $(go.TextBlock, textStyle(), "End")
            ));

        myDiagram.nodeTemplateMap.add("For",
            $(go.Node, "Auto", nodeStyle(),
                { minSize: new go.Size(64, 32) },
                $(go.Shape, "ForEach", shapeStyle()),
                $(go.TextBlock, textStyle(), "For Each",
                    { margin: 4 })
            ));

        myDiagram.nodeTemplateMap.add("EndFor",
            $(go.Node, nodeStyle(),
                $(go.Shape, "EndForEach", shapeStyle(),
                    { desiredSize: new go.Size(4, 4) })
            ));

        myDiagram.nodeTemplateMap.add("While",
            $(go.Node, "Auto", nodeStyle(),
                { minSize: new go.Size(32, 32) },
                $(go.Shape, "ForEach", shapeStyle(),
                    { angle: -90, spot2: new go.Spot(1, 1, -6, 0) }),
                $(go.TextBlock, textStyle(), "While",
                    { margin: 4 })
            ));

        myDiagram.nodeTemplateMap.add("EndWhile",
            $(go.Node, nodeStyle(),
                $(go.Shape, "Circle", shapeStyle(),
                    { desiredSize: new go.Size(4, 4) })
            ));

        myDiagram.nodeTemplateMap.add("If",
            $(go.Node, "Auto", nodeStyle(),
                { minSize: new go.Size(64, 32) },
                $(go.Shape, "Diamond", shapeStyle()),
                $(go.TextBlock, textStyle(), "If")
            ));

        myDiagram.nodeTemplateMap.add("EndIf",
            $(go.Node, nodeStyle(),
                $(go.Shape, "Diamond", shapeStyle(),
                    { desiredSize: new go.Size(4, 4) })
            ));

        myDiagram.nodeTemplateMap.add("Switch",
            $(go.Node, "Auto", nodeStyle(),
                { minSize: new go.Size(64, 32) },
                $(go.Shape, "TriangleUp", shapeStyle()),
                $(go.TextBlock, textStyle(), "Switch")
            ));

        myDiagram.nodeTemplateMap.add("Merge",
            $(go.Node, nodeStyle(),
                $(go.Shape, "TriangleDown", shapeStyle(),
                    { desiredSize: new go.Size(4, 4) })
            ));

        function groupColor(cat) {
            switch (cat) {
                case "If": return "rgba(255,0,0,0.05)";
                case "For": return "rgba(0,255,0,0.05)";
                case "While": return "rgba(0,0,255,0.05)";
                default: return "rgba(0,0,0,0.05)";
            }
        }

        // define the Group template, required but unseen
        myDiagram.groupTemplate =
            $(go.Group, "Spot",
                {
                    locationSpot: go.Spot.Center,
                    layout: $(ParallelLayout, { angle: 90, layerSpacing: 24, nodeSpacing: 30 }),
                    mouseDragEnter: (e, group) => {
                        var sh = group.findObject("SHAPE");
                        if (sh) sh.stroke = "lime";
                    },
                    mouseDragLeave: (e, group) => {
                        var sh = group.findObject("SHAPE");
                        if (sh) sh.stroke = null;
                    },
                    mouseDrop: dropOntoNode
                },
                $(go.Panel, "Auto",
                    $(go.Shape, "RoundedRectangle",
                        { fill: "rgba(0,0,0,0.05)", strokeWidth: 0, spot1: go.Spot.TopLeft, spot2: go.Spot.BottomRight },
                        new go.Binding("fill", "cat", groupColor)),
                    $(go.Placeholder)
                ),
                $(go.Shape, "LineH",
                    {
                        name: "SHAPE",
                        alignment: go.Spot.Bottom,
                        height: 0, stretch: go.GraphObject.Horizontal,
                        stroke: null, strokeWidth: 8
                    })
            );

        myDiagram.linkTemplate =
            $(go.Link,
                {
                    selectable: false,
                    deletable: false,
                    routing: go.Link.AvoidsNodes, corner: 5,
                    toShortLength: 2,
                    // links cannot be deleted
                    // If a node from the Palette is dragged over this node, its outline will turn green
                    mouseDragEnter: (e, link) => { if (!isLoopBack(link)) link.isHighlighted = true; },
                    mouseDragLeave: (e, link) => { link.isHighlighted = false; },
                    // if a node from the Palette is dropped on a link, the link is replaced by links to and from the new node
                    mouseDrop: dropOntoLink
                },
                $(go.Shape, { isPanelMain: true, stroke: "transparent", strokeWidth: 8 },
                    new go.Binding("stroke", "isHighlighted", h => h ? "lime" : "transparent").ofObject()),
                $(go.Shape, { isPanelMain: true, stroke: "black", strokeWidth: 1.5 }),
                $(go.Shape, { toArrow: "Standard", strokeWidth: 0 })
                // $(go.TextBlock, { segmentIndex: -2, segmentFraction: 0.75, editable: true },
                //   new go.Binding("text").makeTwoWay(),
                //   new go.Binding("background", "text", t => t ? "white" : null))
            );

        function isLoopBack(link) {
            if (!link || !link.fromNode || !link.toNode) return false;
            if (link.fromNode.containingGroup !== link.toNode.containingGroup) return false;
            var cat = link.fromNode.category;
            return (cat === "EndFor" || cat === "EndWhile" || cat === "EndIf");
        }

        // A node dropped onto a Merge node is spliced into a link coming into that node;
        // otherwise it is spliced into a link that is coming out of that node.
        function dropOntoNode(e, oldnode) {
            if (oldnode instanceof go.Group) {
                var merge = oldnode.layout.mergeNode;
                if (merge) {
                    var it = merge.findLinksOutOf();
                    while (it.next()) {
                        var link = it.value;
                        if (link.fromNode.containingGroup !== link.toNode.containingGroup) {
                            dropOntoLink(e, link);
                            break;
                        }
                    }
                }
            } else if (oldnode instanceof go.Node) {
                var cat = oldnode.category;
                if (cat === "Merge" || cat === "End" || cat === "EndFor" || cat === "EndWhile" || cat === "EndIf") {
                    var link = oldnode.findLinksInto().first();
                    if (link) dropOntoLink(e, link);
                } else {
                    var link = oldnode.findLinksOutOf().first();
                    if (link) dropOntoLink(e, link);
                }
            }
        }

        // Splice a node into a link.
        // If the new node is of category "For" or "While" or "If", create a Group and splice it in,
        // and add the new node to that group, and add any other desired nodes and links to that group.
        function dropOntoLink(e, oldlink) {
            if (!(oldlink instanceof go.Link)) return;
            var diagram = e.diagram;
            var newnode = diagram.selection.first();
            if (!(newnode instanceof go.Node)) return;
            if (!newnode.isTopLevel) return;
            if (isLoopBack(oldlink)) {
                // can't add nodes into links going back to the "For" node
                diagram.remove(newnode);
                return;
            }

            var fromnode = oldlink.fromNode;
            var tonode = oldlink.toNode;
            if (newnode.category === "") {  // add simple step into chain of actions
                newnode.containingGroup = oldlink.containingGroup;
                // Reconnect the existing link to the new node
                oldlink.toNode = newnode;
                // Then add links from the new node to the old node
                if (newnode.category === "If") {
                    diagram.model.addLinkData({ from: newnode.key, to: tonode.key });
                    diagram.model.addLinkData({ from: newnode.key, to: tonode.key });
                } else {
                    diagram.model.addLinkData({ from: newnode.key, to: tonode.key });
                }
            } else if (newnode.category === "For" || newnode.category === "While") {  // add loop group
                // add group for loop
                var groupdata = { isGroup: true, cat: newnode.category };
                diagram.model.addNodeData(groupdata);
                var group = diagram.findNodeForData(groupdata);
                group.containingGroup = oldlink.containingGroup;
                diagram.select(group);

                newnode.containingGroup = group;

                var enddata = { category: "End" + newnode.category };
                diagram.model.addNodeData(enddata);
                var endnode = diagram.findNodeForData(enddata);
                endnode.containingGroup = group;
                endnode.location = e.documentPoint;

                diagram.model.addLinkData({ from: newnode.key, to: endnode.key });
                diagram.model.addLinkData({ from: endnode.key, to: newnode.key });

                // Reconnect the existing link to the new node
                oldlink.toNode = newnode;
                // Then add a link from the end node to the old node
                diagram.model.addLinkData({ from: endnode.key, to: tonode.key });
            } else if (newnode.category === "If") {  // add Conditional group
                // add group for conditional
                var groupdata = { isGroup: true, cat: newnode.category };
                diagram.model.addNodeData(groupdata);
                var group = diagram.findNodeForData(groupdata);
                group.containingGroup = oldlink.containingGroup;
                diagram.select(group);

                newnode.containingGroup = group;

                var enddata = { category: "EndIf" };
                diagram.model.addNodeData(enddata);
                var endnode = diagram.findNodeForData(enddata);
                endnode.containingGroup = group;
                endnode.location = e.documentPoint;

                var truedata = { from: newnode.key, to: endnode.key, text: "true" };
                diagram.model.addLinkData(truedata);
                var truelink = diagram.findLinkForData(truedata);
                var falsedata = { from: newnode.key, to: endnode.key, text: "false" };
                diagram.model.addLinkData(falsedata);
                var falselink = diagram.findLinkForData(falsedata);

                // Reconnect the existing link to the new node
                oldlink.toNode = newnode;
                // Then add a link from the new node to the old node
                diagram.model.addLinkData({ from: endnode.key, to: tonode.key });
            } else if (newnode.category === "Switch") {  // add multi-way Switch group
                // add group for loop
                var groupdata = { isGroup: true, cat: newnode.category };
                diagram.model.addNodeData(groupdata);
                var group = diagram.findNodeForData(groupdata);
                group.containingGroup = oldlink.containingGroup;
                diagram.select(group);

                newnode.containingGroup = group;

                var enddata = { category: "Merge" };
                diagram.model.addNodeData(enddata);
                var endnode = diagram.findNodeForData(enddata);
                endnode.containingGroup = group;
                endnode.location = e.documentPoint;

                var yesdata = { text: "yes,\ndo it" };
                diagram.model.addNodeData(yesdata);
                var yesnode = diagram.findNodeForData(yesdata);
                yesnode.containingGroup = group;
                yesnode.location = e.documentPoint;
                diagram.model.addLinkData({ from: newnode.key, to: yesnode.key, text: "yes" });
                diagram.model.addLinkData({ from: yesnode.key, to: endnode.key });

                var nodata = { text: "no,\ndon't" };
                diagram.model.addNodeData(nodata);
                var nonode = diagram.findNodeForData(nodata);
                nonode.containingGroup = group;
                nonode.location = e.documentPoint;
                diagram.model.addLinkData({ from: newnode.key, to: nonode.key, text: "no" });
                diagram.model.addLinkData({ from: nonode.key, to: endnode.key });

                var maybedata = { text: "??" };
                diagram.model.addNodeData(maybedata);
                var maybenode = diagram.findNodeForData(maybedata);
                maybenode.containingGroup = group;
                maybenode.location = e.documentPoint;
                diagram.model.addLinkData({ from: newnode.key, to: maybenode.key, text: "maybe" });
                diagram.model.addLinkData({ from: maybenode.key, to: endnode.key });

                // Reconnect the existing link to the new node
                oldlink.toNode = newnode;
                // Then add a link from the end node to the old node
                diagram.model.addLinkData({ from: endnode.key, to: tonode.key });
            }
            diagram.layoutDiagram(true);
        }

        function deletingNode(node) {  // excise node from the chain that it is in
            if (!(node instanceof go.Node)) return;
            if (node instanceof go.Group) {
                var externals = node.findExternalLinksConnected();
                var next = null;
                externals.each(link => {
                    if (link.fromNode.isMemberOf(node)) next = link.toNode;
                });
                if (next) {
                    externals.each(link => {
                        if (link.toNode.isMemberOf(node)) link.toNode = next;
                    });
                }
            } else if (node.category === "") {
                var next = node.findNodesOutOf().first();
                if (next) {
                    new go.List(node.findLinksInto()).each(link => link.toNode = next);
                }
            }
        }

        // initialize Palette
        myPalette =
            new go.Palette(myPalette,
                {
                    maxSelectionCount: 1,
                    nodeTemplateMap: myDiagram.nodeTemplateMap,
                    model: new go.GraphLinksModel([
                        { text: "Action" },
                        { text: "For Each", category: "For" },
                        { text: "While", category: "While" },
                        { text: "If", category: "If" },
                        { text: "Switch", category: "Switch" }
                    ])
                });

        // initialize Overview
        myOverview =
            new go.Overview(myOverview,
                {
                    observed: myDiagram,
                    contentAlignment: go.Spot.Center
                });
    },

    // Show the diagram's model in JSON format that the user may edit
    save(saveDataModel, myDiagram) {
        saveDataModel = myDiagram.model.toJson();
        myDiagram.isModified = false;
    },

    load(saveDataModel, myDiagram, go) {
        myDiagram.model = go.Model.fromJson(saveDataModel);
    },

    newDiagram(go, myDiagram) {
        myDiagram.model = new go.GraphLinksModel(
            {
                nodeDataArray:
                    [
                        {"key":1, "text":"S", "category":"Start"},
                        {"key":2, "text":"E", "category":"End"}
                    ],
                linkDataArray:
                    [
                        {"from":1, "to":2}
                    ]
            });
    }
}
window.generateFlowGrammer = generateFlowGrammer;