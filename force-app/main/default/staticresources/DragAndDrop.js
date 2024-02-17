const DragAndDrop = {
    init(go, $, diagramContainer) {
        // *****************************
        // Second, set up a GoJS Diagram
        // *****************************

        let myDiagram = new go.Diagram(diagramContainer,  // create a Diagram for the DIV HTML element
            {
                layout: $(go.TreeLayout),
                "undoManager.isEnabled": true
            });

        // define a Node template
        myDiagram.nodeTemplate =
            $(go.Node, "Auto",
                { locationSpot: go.Spot.Center },
                new go.Binding('location'),
                $(go.Shape, "Rectangle",
                    { fill: 'white' },
                    // Shape.fill is bound to Node.data.color
                    new go.Binding("fill", "color"),
                    // this binding changes the Shape.fill when Node.isHighlighted changes value
                    new go.Binding("fill", "isHighlighted", (h, shape) => {
                        if (h) return "red";
                        const c = shape.part.data.color;
                        return c ? c : "white";
                    }).ofObject()),  // binding source is Node.isHighlighted
                $(go.TextBlock,
                    { margin: 3, font: "bold 16px sans-serif", width: 140, textAlign: 'center' },
                    // TextBlock.text is bound to Node.data.key
                    new go.Binding("text")),
                { // on mouse-over, highlight the node
                    mouseDragEnter: (e, node) => node.isHighlighted = true,
                    mouseDragLeave: (e, node) => node.isHighlighted = false,
                    // on a mouse-drop add a link from the dropped-upon node to the new node
                    mouseDrop: (e, node) => {
                        const newnode = e.diagram.selection.first();
                        if (!mayConnect(node, newnode)) return;
                        const incoming = newnode.findLinksInto().first();
                        if (incoming) e.diagram.remove(incoming);
                        e.diagram.model.addLinkData( { from: node.key, to: newnode.key });
                    }
                }
            );

        // define a Link template
        myDiagram.linkTemplate =
            $(go.Link,
                // two path Shapes: the transparent one becomes visible during mouse-over
                $(go.Shape, { isPanelMain: true, strokeWidth: 6, stroke: "transparent" },
                    new go.Binding("stroke", "isHighlighted", h => h ? "red" : "transparent").ofObject()),
                $(go.Shape, { isPanelMain: true, strokeWidth: 1 }),
                $(go.Shape, { toArrow: "Standard" }),
                { // on mouse-over, highlight the link
                    mouseDragEnter: (e, link) => link.isHighlighted = true,
                    mouseDragLeave: (e, link) => link.isHighlighted = false,
                    // on a mouse-drop splice the new node in between the dropped-upon link's fromNode and toNode
                    mouseDrop: (e, link) => {
                        const oldto = link.toNode;
                        const newnode = e.diagram.selection.first();
                        if (!mayConnect(newnode, oldto)) return;
                        if (!mayConnect(link.fromNode, newnode)) return;
                        link.toNode = newnode;
                        e.diagram.model.addLinkData({ from: newnode.key, to: oldto.key });
                    }
                }
            );

        // Decide whether a link from node1 to node2 may be created by a drop operation
        function mayConnect(node1, node2) {
            return node1 !== node2;
        }

        myDiagram.model = new go.GraphLinksModel(
            [
                { key: 1, text: "Alpha", color: "lightblue" },
                { key: 2, text: "Beta", color: "orange" },
                { key: 3, text: "Gamma", color: "lightgreen" },
                { key: 4, text: "Delta", color: "pink" }
            ],
            [
                { from: 1, to: 2 },
                { from: 1, to: 3 }
            ]);
    }
}

window.DragAndDrop = DragAndDrop;