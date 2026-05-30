{
  lib,
  writeShellApplication,
  fzf,
  nix,
  util-linux,
  packageList,
}:

let
  packageListFile = builtins.toFile "llm-agents-packages.tsv" packageList;
in
writeShellApplication {
  name = "llm-agents-launcher";

  runtimeInputs = [
    fzf
    nix
    util-linux # column
  ];

  text = ''
    tmpdir=$(mktemp -d)
    trap 'rm -rf "$tmpdir"' EXIT

    awk -F $'\t' '
      {
        category = $3
        print $1 "\t" $2 "\t" category
      }
    ' "${packageListFile}" > "$tmpdir/packages.tsv"

    cut -f3 "$tmpdir/packages.tsv" | sort -u > "$tmpdir/categories.txt"

    selected_category="''${DEFAULT_CATEGORY:-}"
    if [[ -z "$selected_category" ]]; then
      selected_category=$(cat "$tmpdir/categories.txt" | fzf \
        --header="Select a category (ESC to cancel)" \
        --preview-window=hidden \
        --no-multi \
        --height=~40% \
        --layout=reverse) || exit 0
    fi

    awk -F $'\t' -v category="$selected_category" '$3 == category { print $1 "\t" $2 }' "$tmpdir/packages.tsv" \
      | column -t -s $'\t' > "$tmpdir/category-packages.txt"

    if [[ ! -s "$tmpdir/category-packages.txt" ]]; then
      echo "No packages found in category: $selected_category" >&2
      exit 1
    fi

    selected=$(cat "$tmpdir/category-packages.txt" | fzf \
      --header="Select an AI tool from $selected_category (ESC to cancel)" \
      --preview-window=hidden \
      --no-multi \
      --height=~40% \
      --layout=reverse) || exit 0

    # Extract package name (first word)
    pkg_name=$(echo "$selected" | awk '{print $1}')

    if [[ -z $pkg_name ]]; then
      exit 0
    fi

    echo "→ Running: nix run github:numtide/llm-agents.nix#$pkg_name"
    exec nix run "github:numtide/llm-agents.nix#$pkg_name"
  '';

  meta = with lib; {
    description = "Interactive fzf launcher for llm-agents.nix packages";
    license = licenses.mit;
    mainProgram = "llm-agents-launcher";
    platforms = platforms.all;
  };

  passthru = {
    hideFromDocs = true;
  };
}
