defmodule ValentineWeb.WorkspaceControllerTest do
  use ValentineWeb.ConnCase

  import Valentine.ComposerFixtures

  test "GET /workspaces/:workspace_id/export returns a JSON export of the workspace for download",
       %{conn: conn} do
    workspace = workspace_fixture()

    conn = get(conn, ~p"/workspaces/#{workspace.id}/export")

    assert conn.status == 200

    assert List.keyfind(conn.resp_headers, "content-disposition", 0) ==
             {"content-disposition",
              "attachment; filename=\"Workspace_some%20name.json\"; filename*=utf-8''Workspace_some%20name.json"}

    assert List.keyfind(conn.resp_headers, "content-type", 0) ==
             {"content-type", "application/json"}

    json = Jason.decode!(conn.resp_body)

    assert json["workspace"]["id"] == workspace.id
  end
end
