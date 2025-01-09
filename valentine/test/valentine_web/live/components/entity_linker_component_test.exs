defmodule ValentineWeb.WorkspaceLive.Components.EntityLinkerComponentTest do
  use ValentineWeb.ConnCase

  import Phoenix.LiveViewTest
  alias Valentine.Composer
  import Valentine.ComposerFixtures

  alias ValentineWeb.WorkspaceLive.Components.EntityLinkerComponent

  defp setup_component(_) do
    workspace = workspace_fixture()

    assumption = assumption_fixture(%{workspace_id: workspace.id})
    mitigation = mitigation_fixture(%{workspace_id: workspace.id})
    threat = threat_fixture(%{workspace_id: workspace.id})

    assigns = %{
      __changed__: %{},
      id: "linker-component",
      source_entity_type: :assumption,
      target_entity_type: :mitigations,
      entity: assumption,
      linked_entities: [],
      linkable_entities: [mitigation],
      workspace_id: workspace.id,
      patch: ~p"/workspaces/#{mitigation.workspace_id}/mitigations"
    }

    socket = %Phoenix.LiveView.Socket{
      assigns: assigns
    }

    %{
      assigns: assigns,
      assumption: assumption,
      mitigation: mitigation,
      socket: socket,
      threat: threat
    }
  end

  describe "render/1" do
    setup [:setup_component]

    test "displays the source and target entities in the title", %{assigns: assigns} do
      html = render_component(EntityLinkerComponent, assigns)
      assert html =~ "Link assumption to mitigation"
    end

    test "display content for a linked assumption", %{assigns: assigns, assumption: assumption} do
      assigns = Map.put(assigns, :linked_entities, [assumption])
      html = render_component(EntityLinkerComponent, assigns)
      assert html =~ assumption.content
    end

    test "displays content for a linked mitigation", %{assigns: assigns, mitigation: mitigation} do
      assigns = Map.put(assigns, :linked_entities, [mitigation])
      html = render_component(EntityLinkerComponent, assigns)
      assert html =~ mitigation.content
    end

    test "displays threat statement for link threat", %{assigns: assigns, threat: threat} do
      assigns = Map.put(assigns, :linked_entities, [threat])
      html = render_component(EntityLinkerComponent, assigns)
      assert html =~ Composer.Threat.show_statement(threat)
    end
  end

  describe "handle_event/3" do
    setup [:setup_component]

    test "removes an entity from the linked entities", %{assumption: assumption, socket: socket} do
      socket = put_in(socket.assigns.linked_entities, [assumption])
      socket = put_in(socket.assigns.linkable_entities, [])

      {:noreply, socket} =
        EntityLinkerComponent.handle_event("remove_entity", %{"id" => assumption.id}, socket)

      assert socket.assigns.linked_entities == []
      assert socket.assigns.linkable_entities == [assumption]
    end

    test "links a mitigation to an assumption", %{
      assumption: assumption,
      mitigation: mitigation,
      socket: socket
    } do
      socket =
        update_in(socket.assigns, fn assigns ->
          assigns
          |> Map.put(:entity, Valentine.Repo.preload(assumption, :mitigations))
          |> Map.put(:linked_entities, [mitigation])
          |> Map.put(:linkable_entities, [])
          |> Map.put(:source_entity_type, :assumption)
          |> Map.put(:target_entity_type, :mitigations)
          |> Map.put(:flash, %{})
        end)

      {:noreply, socket} =
        EntityLinkerComponent.handle_event("save", %{}, socket)

      assert socket.assigns.linked_entities == [mitigation]
      assert socket.assigns.linkable_entities == []

      assert (Composer.get_mitigation!(mitigation.id)
              |> Valentine.Repo.preload(:assumptions)).assumptions == [assumption]
    end

    test "removes a mitigation from an assumption", %{
      assumption: assumption,
      mitigation: mitigation,
      socket: socket
    } do
      Composer.add_mitigation_to_assumption(assumption, mitigation)

      socket =
        update_in(socket.assigns, fn assigns ->
          assigns
          |> Map.put(:entity, Valentine.Repo.preload(assumption, :mitigations))
          |> Map.put(:linked_entities, [])
          |> Map.put(:linkable_entities, [mitigation])
          |> Map.put(:source_entity_type, :assumption)
          |> Map.put(:target_entity_type, :mitigations)
          |> Map.put(:flash, %{})
        end)

      {:noreply, socket} =
        EntityLinkerComponent.handle_event("save", %{}, socket)

      assert socket.assigns.linked_entities == []
      assert socket.assigns.linkable_entities == [mitigation]

      assert (Composer.get_mitigation!(mitigation.id)
              |> Valentine.Repo.preload(:assumptions)).assumptions == []
    end

    test "links a threat to an assumption", %{
      assumption: assumption,
      threat: threat,
      socket: socket
    } do
      socket =
        update_in(socket.assigns, fn assigns ->
          assigns
          |> Map.put(:entity, Valentine.Repo.preload(assumption, :threats))
          |> Map.put(:linked_entities, [threat])
          |> Map.put(:linkable_entities, [])
          |> Map.put(:source_entity_type, :assumption)
          |> Map.put(:target_entity_type, :threats)
          |> Map.put(:flash, %{})
        end)

      {:noreply, socket} =
        EntityLinkerComponent.handle_event("save", %{}, socket)

      assert socket.assigns.linked_entities == [threat]
      assert socket.assigns.linkable_entities == []

      assert (Composer.get_threat!(threat.id)
              |> Valentine.Repo.preload(:assumptions)).assumptions == [assumption]
    end

    test "removes a threat from an assumption", %{
      assumption: assumption,
      threat: threat,
      socket: socket
    } do
      Composer.add_threat_to_assumption(assumption, threat)

      socket =
        update_in(socket.assigns, fn assigns ->
          assigns
          |> Map.put(:entity, Valentine.Repo.preload(assumption, :threats))
          |> Map.put(:linked_entities, [])
          |> Map.put(:linkable_entities, [threat])
          |> Map.put(:source_entity_type, :assumption)
          |> Map.put(:target_entity_type, :threats)
          |> Map.put(:flash, %{})
        end)

      {:noreply, socket} =
        EntityLinkerComponent.handle_event("save", %{}, socket)

      assert socket.assigns.linked_entities == []
      assert socket.assigns.linkable_entities == [threat]

      assert (Composer.get_threat!(threat.id)
              |> Valentine.Repo.preload(:assumptions)).assumptions == []
    end

    test "links an assumption to a mitigation", %{
      assumption: assumption,
      mitigation: mitigation,
      socket: socket
    } do
      socket =
        update_in(socket.assigns, fn assigns ->
          assigns
          |> Map.put(:entity, Valentine.Repo.preload(mitigation, :assumptions))
          |> Map.put(:linked_entities, [assumption])
          |> Map.put(:linkable_entities, [])
          |> Map.put(:source_entity_type, :mitigation)
          |> Map.put(:target_entity_type, :assumptions)
          |> Map.put(:flash, %{})
        end)

      {:noreply, socket} =
        EntityLinkerComponent.handle_event("save", %{}, socket)

      assert socket.assigns.linked_entities == [assumption]
      assert socket.assigns.linkable_entities == []

      assert (Composer.get_mitigation!(mitigation.id)
              |> Valentine.Repo.preload(:assumptions)).assumptions == [assumption]
    end

    test "removes an assumption from a mitigation", %{
      assumption: assumption,
      mitigation: mitigation,
      socket: socket
    } do
      Composer.add_assumption_to_mitigation(mitigation, assumption)

      socket =
        update_in(socket.assigns, fn assigns ->
          assigns
          |> Map.put(:entity, Valentine.Repo.preload(mitigation, :assumptions))
          |> Map.put(:linked_entities, [])
          |> Map.put(:linkable_entities, [assumption])
          |> Map.put(:source_entity_type, :mitigation)
          |> Map.put(:target_entity_type, :assumptions)
          |> Map.put(:flash, %{})
        end)

      {:noreply, socket} =
        EntityLinkerComponent.handle_event("save", %{}, socket)

      assert socket.assigns.linked_entities == []
      assert socket.assigns.linkable_entities == [assumption]

      assert (Composer.get_mitigation!(mitigation.id)
              |> Valentine.Repo.preload(:assumptions)).assumptions == []
    end

    test "links a threat to a mitigation", %{
      mitigation: mitigation,
      threat: threat,
      socket: socket
    } do
      socket =
        update_in(socket.assigns, fn assigns ->
          assigns
          |> Map.put(:entity, Valentine.Repo.preload(mitigation, :threats))
          |> Map.put(:linked_entities, [threat])
          |> Map.put(:linkable_entities, [])
          |> Map.put(:source_entity_type, :mitigation)
          |> Map.put(:target_entity_type, :threats)
          |> Map.put(:flash, %{})
        end)

      {:noreply, socket} =
        EntityLinkerComponent.handle_event("save", %{}, socket)

      assert socket.assigns.linked_entities == [threat]
      assert socket.assigns.linkable_entities == []

      assert (Composer.get_threat!(threat.id)
              |> Valentine.Repo.preload(:mitigations)).mitigations == [mitigation]
    end

    test "removes a threat from a mitigation", %{
      mitigation: mitigation,
      threat: threat,
      socket: socket
    } do
      Composer.add_threat_to_mitigation(mitigation, threat)

      socket =
        update_in(socket.assigns, fn assigns ->
          assigns
          |> Map.put(:entity, Valentine.Repo.preload(mitigation, :threats))
          |> Map.put(:linked_entities, [])
          |> Map.put(:linkable_entities, [threat])
          |> Map.put(:source_entity_type, :mitigation)
          |> Map.put(:target_entity_type, :threats)
          |> Map.put(:flash, %{})
        end)

      {:noreply, socket} =
        EntityLinkerComponent.handle_event("save", %{}, socket)

      assert socket.assigns.linked_entities == []
      assert socket.assigns.linkable_entities == [threat]

      assert (Composer.get_threat!(threat.id)
              |> Valentine.Repo.preload(:mitigations)).mitigations == []
    end

    test "links an assumption to a threat", %{
      assumption: assumption,
      threat: threat,
      socket: socket
    } do
      socket =
        update_in(socket.assigns, fn assigns ->
          assigns
          |> Map.put(:entity, Valentine.Repo.preload(threat, :assumptions))
          |> Map.put(:linked_entities, [assumption])
          |> Map.put(:linkable_entities, [])
          |> Map.put(:source_entity_type, :threat)
          |> Map.put(:target_entity_type, :assumptions)
          |> Map.put(:flash, %{})
        end)

      {:noreply, socket} =
        EntityLinkerComponent.handle_event("save", %{}, socket)

      assert socket.assigns.linked_entities == [assumption]
      assert socket.assigns.linkable_entities == []

      assert (Composer.get_threat!(threat.id)
              |> Valentine.Repo.preload(:assumptions)).assumptions == [assumption]
    end

    test "removes an assumption from a threat", %{
      assumption: assumption,
      threat: threat,
      socket: socket
    } do
      Composer.add_assumption_to_threat(threat, assumption)

      socket =
        update_in(socket.assigns, fn assigns ->
          assigns
          |> Map.put(:entity, Valentine.Repo.preload(threat, :assumptions))
          |> Map.put(:linked_entities, [])
          |> Map.put(:linkable_entities, [assumption])
          |> Map.put(:source_entity_type, :threat)
          |> Map.put(:target_entity_type, :assumptions)
          |> Map.put(:flash, %{})
        end)

      {:noreply, socket} =
        EntityLinkerComponent.handle_event("save", %{}, socket)

      assert socket.assigns.linked_entities == []
      assert socket.assigns.linkable_entities == [assumption]

      assert (Composer.get_threat!(threat.id)
              |> Valentine.Repo.preload(:assumptions)).assumptions == []
    end

    test "links a mitigation to a threat", %{
      mitigation: mitigation,
      threat: threat,
      socket: socket
    } do
      socket =
        update_in(socket.assigns, fn assigns ->
          assigns
          |> Map.put(:entity, Valentine.Repo.preload(threat, :mitigations))
          |> Map.put(:linked_entities, [mitigation])
          |> Map.put(:linkable_entities, [])
          |> Map.put(:source_entity_type, :threat)
          |> Map.put(:target_entity_type, :mitigations)
          |> Map.put(:flash, %{})
        end)

      {:noreply, socket} =
        EntityLinkerComponent.handle_event("save", %{}, socket)

      assert socket.assigns.linked_entities == [mitigation]
      assert socket.assigns.linkable_entities == []

      assert (Composer.get_threat!(threat.id)
              |> Valentine.Repo.preload(:mitigations)).mitigations == [mitigation]
    end

    test "removes a mitigation from a threat", %{
      mitigation: mitigation,
      threat: threat,
      socket: socket
    } do
      Composer.add_mitigation_to_threat(threat, mitigation)

      socket =
        update_in(socket.assigns, fn assigns ->
          assigns
          |> Map.put(:entity, Valentine.Repo.preload(threat, :mitigations))
          |> Map.put(:linked_entities, [])
          |> Map.put(:linkable_entities, [mitigation])
          |> Map.put(:source_entity_type, :threat)
          |> Map.put(:target_entity_type, :mitigations)
          |> Map.put(:flash, %{})
        end)

      {:noreply, socket} =
        EntityLinkerComponent.handle_event("save", %{}, socket)

      assert socket.assigns.linked_entities == []
      assert socket.assigns.linkable_entities == [mitigation]

      assert (Composer.get_threat!(threat.id)
              |> Valentine.Repo.preload(:mitigations)).mitigations == []
    end

    test "save adds a flash message", %{
      assumption: assumption,
      mitigation: mitigation,
      socket: socket
    } do
      socket =
        update_in(socket.assigns, fn assigns ->
          assigns
          |> Map.put(:entity, Valentine.Repo.preload(assumption, :mitigations))
          |> Map.put(:linked_entities, [mitigation])
          |> Map.put(:linkable_entities, [])
          |> Map.put(:source_entity_type, :assumption)
          |> Map.put(:target_entity_type, :mitigations)
          |> Map.put(:flash, %{})
        end)

      {:noreply, socket} =
        EntityLinkerComponent.handle_event("save", %{}, socket)

      assert socket.assigns.flash == %{"info" => "Linked assumption updated"}
    end
  end

  describe "update/2" do
    setup [:setup_component]

    test "updates the socket with a selected_item id", %{mitigation: mitigation, socket: socket} do
      {:ok, socket} =
        EntityLinkerComponent.update(%{selected_item: %{id: mitigation.id}}, socket)

      assert socket.assigns.linked_entities == [mitigation]
      assert socket.assigns.linkable_entities == []
    end

    test "updates the socket with assigns", %{socket: socket} do
      {:ok, socket} =
        EntityLinkerComponent.update(%{foo: "bar"}, socket)

      assert socket.assigns.foo == "bar"
    end
  end
end
