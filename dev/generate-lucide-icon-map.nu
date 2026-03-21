# Script to generate this Gleam code:
# ```gleam
# import saola/internal/lucide_lustre/group_a as ga
# import saola/internal/lucide_lustre/group_z as gz
# import lustre/element
# 
# pub fn get_icon(name: String) {
#   case name {
#     "a-arrow-down" -> ga.a_arrow_down([])
#     "zoom-out" -> gz.zoom_out([])
#     _ -> element.none()
#   }
# }
# ```

def main [] {
  const out_file = 'src/saola/icons.gleam'
  const icon_def_dir = 'src/saola/internal/lucide_lustre'
  
  # Find all group files and extract icon functions with group aliases
  let icon_data = (glob $"($icon_def_dir)/group_*.gleam"
    | each {|file_path|
        let group_letter = ($file_path | path parse | get stem | str replace 'group_' '')
        let alias = $"g($group_letter)"
        let functions = (open --raw $file_path
          | lines
          | where ($it | str contains 'pub fn')
          | parse --regex 'pub fn (?P<name>\w+)\('
          | get name)
        if ($functions | length) > 0 {
          $functions | each {|fn_name|
            {
              function: $fn_name
              group: $group_letter
              alias: $alias
              kebab_name: ($fn_name | str replace '_' '-' --all)
            }
          }
        } else {
          []
        }
      }
    | flatten
    | sort-by kebab_name)
  
  # Generate imports (unique groups)
  let imports = ($icon_data
    | select alias group
    | uniq
    | each {|row|
        $"import saola/internal/lucide_lustre/group_($row.group) as ($row.alias)"
      }
    | str join "\n")
  
  # Generate the case statement lines
  let case_lines = ($icon_data
    | each {|row|
        '    "' + $row.kebab_name + '" -> ' + $row.alias + '.' + $row.function + '([])'
      }
    | str join "\n")
  
  let gleam_code = ([
    "// Auto-generated, do not manually modify!",
    "import lustre/element",
    "",
    $imports,
    "",
    "/// Generate SVG element for a Lucide icon name (https://lucide.dev/icons/)."
    "pub fn get_icon(name: String) {",
    "  case name {",
    $case_lines,
    "    _ -> element.none()",
    "  }",
    "}"
  ] | str join "\n")
  
  # Write to the output file
  $gleam_code | save --force $out_file
  
  print $"Generated ($icon_data | length) icon mappings to ($out_file)"
}
