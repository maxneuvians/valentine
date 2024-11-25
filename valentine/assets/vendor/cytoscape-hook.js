const CytoscapeHook = {
    mounted() {
        console.log("Cytoscape Hook mounted");
        cytoscape.use(edgehandles); // register extension
        this.initializeCytoscape();
    },

    updated() {
        console.log("Cytoscape Hook updated");
    },

    destroyed() {
        console.log("Cytoscape Hook destroyed");
        if (this.cy) {
            this.cy.destroy();
        }
    },

    initializeCytoscape() {
        const nodes = JSON.parse(this.el.dataset.nodes || "[]");
        const edges = JSON.parse(this.el.dataset.edges || "[]");

        this.user = this.el.dataset.user || "user-" + Math.floor(Math.random() * 1000);

        this.cy = cytoscape({
            container: document.getElementById("cy"),
            elements: [...nodes, ...edges],
            style: [
                {
                    selector: 'node',
                    style: {
                        'background-color': '#2da44e',
                        'label': 'data(label)',
                        'color': '#ffffff',
                        'text-valign': 'center',
                        'text-halign': 'center',
                        'width': 100,
                        'height': 40,
                        'shape': 'rectangle',
                        'font-size': '12px',
                        'text-wrap': 'wrap',
                        'text-max-width': 80
                    }
                },
                {
                    selector: 'node:selected',
                    style: {
                        'background-color': '#1a7f37',
                        'border-width': 2,
                        'border-color': '#3fb950'
                    }
                },
                {
                    selector: 'edge',
                    style: {
                        'width': 2,
                        'line-color': '#57606a',
                        'target-arrow-color': '#57606a',
                        'target-arrow-shape': 'triangle',
                        'curve-style': 'bezier',
                        'label': 'data(label)',
                        'font-size': '10px',
                        'text-rotation': 'autorotate'
                    }
                }
            ],
            layout: {
                name: 'preset',
                fit: false
            }
        });

        // the default values of each option are outlined below:
        let defaults = {
            canConnect: function (sourceNode, targetNode) {
                // whether an edge can be created between source and target
                return !sourceNode.same(targetNode); // e.g. disallow loops
            },
            edgeParams: function (sourceNode, targetNode) {
                // for edges between the specified source and target
                // return element object to be passed to cy.add() for edge
                return {};
            },
            hoverDelay: 150, // time spent hovering over a target node before it is considered selected
            snap: true, // when enabled, the edge can be drawn by just moving close to a target node (can be confusing on compound graphs)
            snapThreshold: 50, // the target node must be less than or equal to this many pixels away from the cursor/finger
            snapFrequency: 15, // the number of times per second (Hz) that snap checks done (lower is less expensive)
            noEdgeEventsInDraw: true, // set events:no to edges during draws, prevents mouseouts on compounds
            disableBrowserGestures: true // during an edge drawing gesture, disable browser gestures such as two-finger trackpad swipe and pinch-to-zoom
        };

        this.eh = cy.edgehandles(defaults);

        this.bindEvents();
        this.setupEventHandlers();
    },

    bindEvents() {
        this.cy.on("free", "node", (evt) => {
            evt.target.data("active_user", null);
            this.pushEventTo(this.el, "free", { localJs: true, node: { id: evt.target.id() } });
        })

        this.cy.on("grab", "node", (evt) => {
            evt.target.data("active_user", this.user);
            this.pushEventTo(this.el, "grab", { localJs: true, node: { id: evt.target.id() }, user: this.user });
        });


        this.cy.on("position", "node", (evt) => {
            if (evt.target.data("active_user") !== this.user) {
                return;
            }
            this.pushEventTo(this.el, "position", { localJs: true, node: { id: evt.target.id(), position: evt.target.position() } });
        });
    },

    setupEventHandlers() {
        this.handleEvent("updateGraph", ({ event, payload }) => {
            console.log("Received updateGraph event:", event, payload);
            switch (event) {
                case "add_node":
                    this.addNode(payload);
                    break;

                case "free":
                    this.free(payload);
                    break;

                case "grab":
                    this.grab(payload);
                    break;

                case "position":
                    this.position(payload);
                    break;

                default:
                    console.warn("Unknown update type:", event);
            }
        });
    },

    addNode(node) {
        const newNode = this.cy.add(node);
    },

    free(node) {
        // The node has been freed
        this.cy.getElementById(node.data.id).grabify();
    },

    grab(node) {
        // Another user has grabbed the node
        this.cy.getElementById(node.data.id).ungrabify();
    },

    position(node) {
        this.cy.getElementById(node.data.id).position(node.position)
    }
};

export default CytoscapeHook;