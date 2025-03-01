{ pkgs }:
{
  access-client = pkgs.callPackage ./access-client/package.nix { };
}
