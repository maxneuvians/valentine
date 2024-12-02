import cytoscape from 'cytoscape';
import edgehandles from 'cytoscape-edgehandles';

const CytoscapeHook = {
    mounted() {
        console.log("Cytoscape Hook mounted");
        cytoscape.use(edgehandles);
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
                    selector: 'node[type="actor"]',
                    style: {
                        'background-color': '#fff',
                        'border-color': '#000',
                        'border-width': 2,
                        'label': 'data(label)',
                        'color': '#000',
                        'text-valign': 'bottom',
                        'text-halign': 'center',
                        'width': 120,
                        'height': 50,
                        'shape': 'rectangle',
                        'font-size': '18px',
                        'text-wrap': 'wrap',
                        'text-max-width': 80,
                        'text-margin-y': 10
                    }
                },
                {
                    selector: 'node[type="process"]',
                    style: {
                        'background-color': '#fff',
                        'border-color': '#000',
                        'border-width': 2,
                        'label': 'data(label)',
                        'color': '#000',
                        'text-valign': 'bottom',
                        'text-halign': 'center',
                        'width': 100,
                        'height': 100,
                        'shape': 'ellipse',
                        'font-size': '18px',
                        'text-wrap': 'wrap',
                        'text-max-width': 80,
                        'text-margin-y': 10
                    }
                },
                {
                    selector: 'node[type="datastore"]',
                    style: {
                        'background-color': '#fff',
                        'border-color': '#000',
                        'border-width': 2,
                        'label': 'data(label)',
                        'color': '#000',
                        'text-valign': 'bottom',
                        'text-halign': 'center',
                        'width': 120,
                        'height': 50,
                        'shape': 'round-octagon',
                        'font-size': '18px',
                        'text-wrap': 'wrap',
                        'text-max-width': 80,
                        'text-margin-y': 10
                    }
                },
                {
                    selector: 'node:selected',
                    style: {
                        'background-color': 'rgb(219, 241, 254)',
                        'border-width': 3,
                        'border-color': 'rgb(86, 189, 249)'
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
                        'text-rotation': 'autorotate',
                        'text-background-color': '#ffffff',
                        'text-background-opacity': 1,
                        'text-background-padding': 3
                    }
                },
                {
                    selector: 'edge:selected',
                    style: {
                        'line-color': '#3fb950',
                        'target-arrow-color': '#3fb950',
                        'width': 3
                    }
                },
                {
                    selector: '.eh-handle',
                    style: {
                        'background-color': '#3fb950',
                        'width': 12,
                        'height': 12,
                        'shape': 'ellipse',
                        'overlay-opacity': 0
                    }
                },
                {
                    selector: '.eh-hover',
                    style: {
                        'background-color': '#1a7f37'
                    }
                },
                {
                    selector: '.eh-preview, .eh-ghost-edge',
                    style: {
                        'line-color': '#3fb950',
                        'target-arrow-color': '#3fb950',
                        'target-arrow-shape': 'triangle'
                    }
                },
                {
                    selector: ':parent',
                    css: {
                        'text-valign': 'top',
                        'text-halign': 'center',
                        'shape': 'round-rectangle',
                        'corner-radius': "10",
                        'padding': 75,
                        'border-color': '#EE4B2B',
                        'border-width': 2,
                        "border-style": "dashed",
                        'label': 'data(label)',
                        'text-margin-y': -10
                    }
                },
            ],
            layout: {
                name: 'preset',
                fit: false
            }
        });

        let defaults = {
            canConnect: function (sourceNode, targetNode) {
                return !sourceNode.same(targetNode);
            },
            edgeParams: function (sourceNode, targetNode) {
                id = "edge-" + Math.floor(Math.random() * 1000);
                return { data: { id: id, label: "Data flow" } };
            },
            hoverDelay: 150,
            snap: true,
            snapThreshold: 50,
            snapFrequency: 15,
            noEdgeEventsInDraw: true,
            disableBrowserGestures: true
        };

        this.eh = this.cy.edgehandles(defaults);

        this.bindEvents(this.cy);
        this.setupEventHandlers();
    },

    bindEvents(cy) {
        window.addEventListener('resize', () => {
            cy.style.width = '100%';
            cy.style.height = '100%';
            cy.resize();
            cy.fit();
        });

        cy.on("cxttapstart", "node", (evt) => {
            this.eh.start(evt.target);
        });

        cy.on('ehcomplete', (event, sourceNode, targetNode, addedEdge) => {
            this.pushEventTo(this.el, "ehcomplete", { localJs: true, edge: { id: addedEdge.id(), source: sourceNode.id(), target: targetNode.id() } });
        });

        cy.on("free", "node", (evt) => {
            evt.target.data("active_user", null);
            this.pushEventTo(this.el, "free", { localJs: true, node: { id: evt.target.id() } });
        })

        cy.on("grab", "node", (evt) => {
            evt.target.data("active_user", this.user);
            this.pushEventTo(this.el, "grab", { localJs: true, node: { id: evt.target.id() }, user: this.user });
        });

        cy.on("position", "node", (evt) => {
            if (evt.target.data("active_user") !== this.user) {
                return;
            }
            if (evt.target.data('type') === "trust_boundary") {
                evt.target.descendants().forEach((node) => {
                    this.pushEventTo(this.el, "position", { localJs: true, node: { id: node.id(), position: node.position() } });
                });
                return;
            } else {
                this.pushEventTo(this.el, "position", { localJs: true, node: { id: evt.target.id(), position: evt.target.position() } });
            }
        });

        cy.on("select", "node", (evt) => {
            this.pushEventTo(this.el, "select", { id: evt.target.id(), label: evt.target.data().label, group: evt.target.group() });
        });

        cy.on("unselect", "node", (evt) => {
            this.pushEventTo(this.el, "unselect", { id: evt.target.id(), group: evt.target.group() });
        });

        cy.on("select", "edge", (evt) => {
            this.pushEventTo(this.el, "select", { id: evt.target.id(), label: evt.target.data().label, group: evt.target.group() });
        });

        cy.on("unselect", "edge", (evt) => {
            this.pushEventTo(this.el, "unselect", { id: evt.target.id(), group: evt.target.group() });

        });
    },

    setupEventHandlers() {
        this.handleEvent("updateGraph", ({ event, payload }) => {
            console.log("Received updateGraph event:", event, payload);
            switch (event) {
                case "add_node":
                    this.addNode(payload);
                    break;

                case "clear_dfd":
                    this.clearDFD();
                    break

                case "delete":
                    this.deleteElement(payload);
                    break;

                case "ehcomplete":
                    this.ehcomplete(payload);

                case "fit_view":
                    this.fitView();
                    break;

                case "free":
                    this.free(payload);
                    break;

                case "grab":
                    this.grab(payload);
                    break;

                case "group_nodes":
                    this.groupNodes(payload);
                    break;

                case "merge_group":
                    this.mergeGroup(payload);
                    break;

                case "position":
                    this.position(payload);
                    break;

                case "remove_elements":
                    this.removeElements(payload);
                    break;

                case "remove_group":
                    this.removeGroup(payload);
                    break;

                case "update_metadata":
                    this.updateMetadata(payload);
                    break;

                default:
                    console.warn("Unknown update type:", event);
            }
        });
    },

    addNode(node) {
        this.cy.add(node);
    },

    clearDFD() {
        this.cy.elements().remove();
    },

    deleteElement(element) {
        const el = this.cy.getElementById(element.data.id);
        if (el) {
            el.remove();
        }
    },

    ehcomplete(edge) {
        this.cy.add({
            data: edge.data
        });
    },

    fitView() {
        this.cy.fit();
    },

    free(node) {
        this.cy.getElementById(node.data.id).grabify();
    },

    grab(node) {
        this.cy.getElementById(node.data.id).ungrabify();
    },

    groupNodes({ node, children }) {
        if (children.length === 0) {
            return;
        }
        this.cy.add(node).unselect();
        children.forEach((childID) => {
            this.cy.getElementById(childID).move({ parent: node.data.id });
            this.cy.getElementById(childID).unselect();
        });
    },

    mergeGroup({ node, children, purge }) {
        children.forEach((childID) => {
            this.cy.getElementById(childID).move({ parent: node });
        });
        purge.forEach((id) => {
            this.cy.getElementById(id).unselect();
            this.cy.getElementById(id).remove();
        });
    },

    position(node) {
        this.cy.getElementById(node.data.id).position(node.position)
    },

    removeElements(elements) {
        Object.keys(elements.nodes).forEach((id) => {
            this.cy.getElementById(id).unselect();
            this.cy.getElementById(id).remove();
        });
        Object.keys(elements.edges).forEach((id) => {
            this.cy.getElementById(id).unselect();
            this.cy.getElementById(id).remove();
        });
    },

    removeGroup(node) {
        this.cy.getElementById(node.data.id).children().forEach((child) => {
            child.move({ parent: null });
        });
        this.cy.getElementById(node.data.id).unselect();
        this.cy.getElementById(node.data.id).remove();
    },

    updateMetadata({ id, field, value }) {
        this.cy.getElementById(id).data(field, value);
    }
};

export default CytoscapeHook;