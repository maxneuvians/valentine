defmodule Valentine.Seed do
  def run() do
    # Insert CCCS Cloud Medium Profile controls
    {:ok, _} = Application.ensure_all_started(:valentine)

    path = Application.app_dir(:valentine, "priv/repo/seed_data/cccs-cloud-medium-profile.csv")
    # Load CSV from seed_data/cccs-cloud-medium-profile.csv if the table is empty
    controls = Valentine.Composer.list_controls()

    if length(controls) == 0 do
      path
      |> File.stream!()
      |> CSV.decode!(headers: true, escape_max_lines: 20)
      |> Enum.each(fn row ->
        %{
          name: String.trim(row["Title"]),
          description: String.trim(row["Definition"]),
          guidance: String.trim(row["Supplemental Guidance"]),
          nist_id:
            String.trim(
              (fn id ->
                 case Regex.replace(~r/(\w+)-(\d+)\((\d+)\)/, id, "\\1-\\2.\\3") do
                   # Return original if no match
                   ^id -> id
                   result -> result
                 end
               end).(row["ID"])
            ),
          nist_family: String.trim(row["Name"]),
          stride: [],
          tags:
            (fn r ->
               keys = [
                 "CCCS Medium Profile for Cloud",
                 "CSP Full Stack",
                 "CSP Stacked PaaS",
                 "CSP Stacked SaaS",
                 "Client IaaS / PaaS",
                 "Client SaaS"
               ]

               Enum.filter(keys, fn key ->
                 r[key] == "X"
               end)
             end).(row)
        }
        |> Valentine.Composer.create_control()
      end)
      IO.puts("NIST Controls seeded into DB")
    else
      IO.puts("Controls already exist in the database")
    end
  end
end
