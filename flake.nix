{
  description = "Devshell with pregenerated nix-index database";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    # The pregenerated database flake
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-index-database }:
    let
      system = "x86_64-linux"; # Change to your system, e.g., "aarch64-darwin"
      pkgs = nixpkgs.legacyPackages.${system};
      # The database file provided by the flake
      db = nix-index-database.packages.${system}.nix-index-database;
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        nativeBuildInputs = [ 
          pkgs.nix-index # Provides the 'nix-locate' command
          pkgs.comma
        ];

        # This runs every time you enter 'nix develop'
        shellHook = ''
          # Create a symlink to the pregenerated database in a standard location
          # so that nix-locate can find it without running a local scan.
          mkdir -p ~/.cache/nix-index
          ln -sf ${db} ~/.cache/nix-index/files
          
          # point nix-locate to the db explicitly if it doesn't pick it up
          export NIX_INDEX_DATABASE=~/.cache/nix-index

          echo "Nix-index database loaded from: $NIX_INDEX_DATABASE"
          echo "You can now run 'nix-locate <file>' instantly."
          echo "or try the comma syntax: , cowsay 'It works!'"
        '';
      };
    };
}
