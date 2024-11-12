defmodule ValentineWeb.WorkspaceLive.Threat.Components.StatementExamples do

  def content(:threat_source) do
    %{
      title: "Threat source",
      description: "Who or what is initiating the threat?",
      placeholder: "Enter threat source",
      examples: [
        "a malicious user",
        "an attacker with network access",
        "a compromised admin account"
      ]
    }
  end

  def content(:prerequisites) do
    %{
      title: "Prerequisites",
      description: "What conditions need to be met for the threat to be possible?",
      placeholder: "Enter prerequisites",
      examples: [
        "having valid credentials",
        "access to the internal network",
        "knowledge of the system architecture"
      ]
    }
  end

  def content(:threat_action) do
    %{
      title: "Threat action",
      description: "What action would the threat source take?",
      placeholder: "Enter threat action",
      examples: [
        "exploit a vulnerability in the API",
        "perform a SQL injection attack",
        "intercept network traffic"
      ]
    }
  end

  def content(:threat_impact) do
    %{
      title: "Threat impact",
      description:
        "What are the direct/initial impacts of the threat actions if they were to be successful?",
      placeholder: "Enter threat impact",
      examples: [
        "the actor being able to do anything the user can do",
        "the ability to modify data",
        "unnecessary and excessive costs"
      ]
    }
  end

  def content(:impacted_assets) do
    %{
      title: "Impacted assets",
      description: "What assets would be affected by this threat?",
      placeholder: "Enter impacted assets",
      examples: [
        "user data",
        "system configurations",
        "financial resources"
      ]
    }
  end
end
