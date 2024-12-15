# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Valentine.Repo.insert!(%Valentine.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# Insert CCCS Cloud Medium Profile controls

# Load CSV from seed_data/cccs-cloud-medium-profile.csv
"priv/repo/seed_data/cccs-cloud-medium-profile.csv"
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
