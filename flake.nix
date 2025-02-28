{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
      packages-inode = with pkgs; [
        libgcc
        libxcrypt-legacy
        libuuid
        libpng12
        libjpeg
        libudev0-shim
        libz
        atk
        ell
        bash
        coreutils
        glib
        cairo
        ncurses5
        pango
        gtk2
        gdk-pixbuf
        freetype
        fontconfig
        xorg.libSM
        xorg.libX11
        xorg.libXxf86vm
      ];
      inherit (pkgs) mkShell;
    in
    {
      formatter.${system} = treefmtEval.config.build.wrapper;
      devShell."${system}" = mkShell {
        nativeBuildInputs = with pkgs; [
          tokei
          nil
        ];
        buildInputs = packages-inode;
      };

      packages."${system}" = {
        h3c-inode-client = pkgs.callPackage ./h3c-inode-client/package.nix { };
      };

      nixosModules = rec {
        default = chuang-packages;
        chuang-packages = {
          imports = [
            ./h3c-inode-client/module.nix
          ];
        };
      };
    };
}
