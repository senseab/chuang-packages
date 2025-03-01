{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      ...
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
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
        h3c = import ./h3c { inherit pkgs; };
      };

      nixosModules =
        let
          pkgs-chuang = self.packages."${system}";
        in
        rec {
          chuang-packages =
            { config, lib, ... }:
            {
              imports = [
                (import ./h3c/inode-client/module.nix { inherit lib pkgs-chuang config; })
              ];
            };

          default = chuang-packages;
        };
    };
}
