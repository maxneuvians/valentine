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

  describe "stride" do
    test "displays STRIDE if stride is not set" do
      threat = %Threat{}
      html = Threat.stride_banner(threat)
      assert html == "STRIDE"
    end

    test "displays STRIDE is an empty list" do
      threat = %Threat{stride: []}
      {:safe, html} = Threat.stride_banner(threat)
      assert html == "STRIDE"
    end

    test "displays highlighted STRIDE if all are set" do
      threat = %Threat{
        stride: [
          :spoofing,
          :tampering,
          :repudiation,
          :information_disclosure,
          :denial_of_service,
          :elevation_of_privilege
        ]
      }

      {:safe, html} =
        Threat.stride_banner(threat)

      assert html ==
               "<span class=\"Label--accent\">S</span><span class=\"Label--accent\">T</span><span class=\"Label--accent\">R</span><span class=\"Label--accent\">I</span><span class=\"Label--accent\">D</span><span class=\"Label--accent\">E</span>"
    end
  end
end
