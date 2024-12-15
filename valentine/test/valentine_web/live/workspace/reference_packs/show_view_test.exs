defmodule ValentineWeb.WorkspaceLive.ReferencePacks.ShowViewTest do
  use ValentineWeb.ConnCase

  import Phoenix.LiveViewTest
  import Valentine.ComposerFixtures

  setup do
    reference_pack_item = reference_pack_item_fixture()
    workspace = workspace_fixture()

    %{
      reference_pack_item: reference_pack_item,
      workspace_id: workspace.id
    }
  end

  describe "Show" do
    test "lists all reference_pack_items for that reference pack", %{
      conn: conn,
      reference_pack_item: reference_pack_item,
      workspace_id: workspace_id
    } do
      {:ok, _index_live, html} =
        live(
          conn,
          ~p"/workspaces/#{workspace_id}/reference_packs/#{reference_pack_item.collection_id}/#{reference_pack_item.collection_type}"
        )

      assert html =~ "Reference packs"
      assert html =~ reference_pack_item.collection_name

      assert html =~
               Phoenix.Naming.humanize(reference_pack_item.collection_type) <>
                 " pack: " <> reference_pack_item.collection_name

      assert html =~ reference_pack_item.id
    end
  end
end
