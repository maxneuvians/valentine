defmodule Valentine.Composer.ThreatTest do
  use ValentineWeb.ConnCase

  alias Valentine.Composer.Threat

  describe "show_statement/1" do
    test "starts with a or an depending on the threat source" do
      threat = %Threat{threat_source: "SQL Injection"}
      assert Threat.show_statement(threat) =~ "A SQL Injection"

      threat = %Threat{threat_source: "Apple"}
      assert Threat.show_statement(threat) =~ "An Apple"
    end

    test "adds threat impact if not nil" do
      threat = %Threat{threat_source: "SQL Injection", threat_impact: "High"}
      assert Threat.show_statement(threat) =~ ", which leads to High"
    end

    test "adds an array of impacted goals" do
      threat = %Threat{
        threat_source: "SQL Injection",
        impacted_goal: ["Confidentiality", "Integrity"]
      }

      assert Threat.show_statement(threat) =~
               ", resulting in reduced Confidentiality and Integrity"
    end

    test "adds an array of impacted assets" do
      threat = %Threat{
        threat_source: "SQL Injection",
        impacted_assets: ["Database", "User Data"]
      }

      assert Threat.show_statement(threat) =~
               "negatively impacting Database and User Data."
    end

    test "returns a complete statement" do
      threat = %Threat{
        threat_source: "SQL Injection",
        prerequisites: "Gain access to the database",
        threat_action: "Delete all records",
        threat_impact: "High",
        impacted_goal: ["Confidentiality", "Integrity"],
        impacted_assets: ["Database", "User Data"]
      }

      assert Threat.show_statement(threat) =~
               "A SQL Injection Gain access to the database can Delete all records, which leads to High, resulting in reduced Confidentiality and Integrity negatively impacting Database and User Data."
    end
  end
end
